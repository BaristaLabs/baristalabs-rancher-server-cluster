# Provision Tailscale resources
resource "kubernetes_namespace" "tailscale" {
  metadata {

    labels = {
      creator = "rancher_server_terraform",
      kind    = "tailscale"
    }

    name = local.rancher_server_namespaces.tailscale_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "helm_release" "tailscale_subnet_router" {
  name       = "tailscale-subnet-router"
  repository = "https://charts.visonneau.fr"
  chart      = "tailscale-relay"

  namespace = kubernetes_namespace.tailscale.metadata[0].name

  values = [ 
    file("${path.module}/values/tailscale-subnet-router_values.yaml")
  ]

  set {
    name  = "config.authKey"
    value = var.tailscale_auth_key
  }
}