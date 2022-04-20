resource "kubernetes_namespace" "traefik_ingress" {
  metadata {

    labels = {
      creator = "baristalabs_rancher_server",
      kind    = "traefik"
    }

    name = var.ingress_namespace
  }
}

locals {
  traefik_additional_arguments = [
    # "--entrypoints.web.http.redirections.entryPoint.to=:443",
    # "--entrypoints.web.http.redirections.entryPoint.scheme=https",
    # "--entrypoints.websecure.http.tls=true",
    "--metrics.prometheus=true",
    "--metrics.prometheus.buckets=0.1,0.3,1.2,5.0",
    
    # To enable greater control of which X-Forwarded-* headers to trust:
    #"--entryPoints.web.forwardedHeaders.insecure=false",
    #"--entryPoints.web.forwardedHeaders.trustedIPs=${join(",",var.azure_frontdoor_backend_cidr_block_associations)}"
  ]
}

// See https://docs.microsoft.com/en-us/azure/dev-spaces/how-to/ingress-https-traefik
// https://github.com/traefik/traefik-helm-chart
resource "helm_release" "traefik_ingress" {
  name       = "traefik-ingress"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "10.19.4"

  namespace = kubernetes_namespace.traefik_ingress.metadata[0].name

  verify = false

  values = [ 
    file("${path.module}/values/traefik_values.yaml")
  ]

  set {
    name  = "additionalArguments"
    value = "{${join(",", local.traefik_additional_arguments)}}"
  }

  dynamic "set" {
    for_each = var.kubernetes_ingress_public_ip == null ? [] : [1]

    content {
      name  = "service.spec.loadBalancerIP"
      value = var.kubernetes_ingress_public_ip
    }
  }

  set {
    name   = "deployment.replicas"
    value  = var.kubernetes_ingress_replicas
  }
}

# Define the certificates for the environment
resource "kubernetes_secret" "naked_domain_cert" {
  metadata {
    name      = var.naked_domain_cert.name
    namespace = kubernetes_namespace.traefik_ingress.metadata[0].name
  }

  data = {
    "tls.crt" = var.naked_domain_cert.pem
    "tls.key" = var.naked_domain_cert.key
  }

  type = "kubernetes.io/tls"
}

resource "kubernetes_secret" "wildcard_domain_cert" {
  metadata {
    name      = var.wildcard_domain_cert.name
    namespace = kubernetes_namespace.traefik_ingress.metadata[0].name
  }

  data = {
    "tls.crt" = var.wildcard_domain_cert.pem
    "tls.key" = var.wildcard_domain_cert.key
  }

  type = "kubernetes.io/tls"
}

# Provision the base configuration
data "kubectl_path_documents" "traefik_config" {
  pattern = "${path.module}/specs/*.yaml"

  vars = {
    traefik_default_cert_secret_name  = var.naked_domain_cert.name
    traefik_wildcard_cert_secret_name = var.wildcard_domain_cert.name
  }
}

resource "kubectl_manifest" "traefik_config" {
  for_each = toset(data.kubectl_path_documents.traefik_config.documents)

  yaml_body = each.value

  override_namespace = kubernetes_namespace.traefik_ingress.metadata[0].name
}
