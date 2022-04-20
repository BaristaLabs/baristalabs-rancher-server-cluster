output "whoami_namespace" {
  value = kubernetes_namespace.whoami.metadata[0].name
}