resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/stable"
  chart      = "rancher"
  version    = var.rancher_version

  namespace = var.rancher_namespace

  reuse_values = true

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