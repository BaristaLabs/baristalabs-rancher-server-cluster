resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.8.0"

  namespace = var.cert_manager_namespace

  set {
    name = "installCRDs"
    value = "true"
  }
  set {
    name  = "replicaCount"
    value = var.cert_manager_replicas
  }
}