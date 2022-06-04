# Adds a CoreDNS deployment running as an external DNS service.
# This supports Tailscale's DNS service.

### Provision the CoreDNS namespace
resource "kubernetes_namespace" "coredns_external" {
  metadata {

    labels = {
      creator = "rancher_server_terraform",
      kind    = "coredns_external"
    }

    name = local.rancher_server_namespaces.coredns_external_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }
}

### Provision CoreDNS in external mode
resource "helm_release" "coredns_external" {
  name       = "coredns-external"
  repository = "https://coredns.github.io/helm"
  chart      = "coredns"

  version = "1.19.4"

  namespace = kubernetes_namespace.coredns_external.metadata[0].name

  values = [ 
    file("${path.module}/values/coredns-external_values.yaml")
  ]
}