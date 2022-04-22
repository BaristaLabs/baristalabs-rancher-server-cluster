// See https://docs.microsoft.com/en-us/azure/dev-spaces/how-to/ingress-https-traefik
resource "kubernetes_secret" "naked_domain_cert" {
  metadata {
    name      = var.naked_domain_cert.name
    namespace = var.rancher_namespace
  }

  data = {
    "tls.crt" = var.naked_domain_cert.pem
    "tls.key" = var.naked_domain_cert.key
  }

  type = "kubernetes.io/tls"

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }
}

resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/stable"
  chart      = "rancher"
  version    = "2.6.4"

  namespace = var.rancher_namespace

  values = [ 
    file("${path.module}/values/rancher_values.yaml")
  ]

  set {
    name  = "hostname"
    value = var.rancher_hostname
  }

  set {
    name  = "replicas"
    value = var.rancher_replicas
  }
}