# Provision Tailscale resources
resource "kubernetes_namespace" "tailscale" {
  metadata {

    labels = {
      creator = "rancher_server_terraform",
      kind    = "tailscale"
    }

    name = local.tailscale_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "kubernetes_secret" "tailscale_auth_key" {
  metadata {
    name      = "tailscale-subnet-router-secrets"
    namespace = kubernetes_namespace.tailscale.metadata[0].name
  }

  data = {
    AUTH_KEY = var.tailscale_auth_key
  }
}

resource "helm_release" "tailscale_subnet_router" {
  name       = "tailscale-subnet-router"
  repository = "https://gtaylor.github.io/helm-charts"
  chart      = "tailscale-subnet-router"

  namespace = kubernetes_namespace.tailscale.metadata[0].name

  values = [ 
    file("${path.module}/values/tailscale-subnet-router_values.yaml")
  ]

  set {
    name  = "image.repository"
    value = local.tailscale_image_repository
  }

  set {
    name  = "image.tag"
    value = local.tailscale_image_tag
  }

  depends_on = [
    kubernetes_secret.tailscale_auth_key
  ]

}