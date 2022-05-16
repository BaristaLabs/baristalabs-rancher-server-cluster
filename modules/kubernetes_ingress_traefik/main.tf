// See https://docs.microsoft.com/en-us/azure/dev-spaces/how-to/ingress-https-traefik
// https://github.com/traefik/traefik-helm-chart

resource "kubernetes_role" "tailscale" {
  metadata {
    name      = "tailscale"
    namespace = var.ingress_namespace
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create", "get", "update"]
  }
}

resource "kubernetes_role_binding" "tailscale" {
  metadata {
    name      = "tailscale"
    namespace = var.ingress_namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.tailscale.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.traefik_service_account_name == null ? "traefik-ingress" : var.traefik_service_account_name
    namespace = var.ingress_namespace
  }

  depends_on = [
    helm_release.traefik_ingress
  ]
}

resource "kubernetes_secret" "tailscale_auth_key" {
  metadata {
    name      = "tailscale-auth"
    namespace = var.ingress_namespace
  }

  data = {
    AUTH_KEY = var.tailscale_ephemeral_auth_key
  }
}

resource "helm_release" "traefik_ingress" {
  name       = var.ingress_name
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "10.19.5"

  namespace = var.ingress_namespace

  verify = false

  values = [
    file("${path.module}/values/traefik_values.yaml")
  ]

  set {
    name  = "service.type"
    value = var.service_type == null ? "LoadBalancer" : var.service_type
  }

  set {
    name  = "additionalArguments"
    value = "{${join(",", var.traefik_additional_arguments)}}"
  }

  dynamic "set" {
    for_each = var.kubernetes_ingress_public_ip == null ? [] : [1]

    content {
      name  = "service.spec.loadBalancerIP"
      value = var.kubernetes_ingress_public_ip
    }
  }

  dynamic "set" {
    for_each = var.web_node_port == null ? [] : [1]

    content {
      name  = "ports.web.nodePort"
      value = var.web_node_port
    }
  }

  dynamic "set" {
    for_each = var.websecure_node_port == null ? [] : [1]

    content {
      name  = "ports.websecure.nodePort"
      value = var.websecure_node_port
    }
  }
}