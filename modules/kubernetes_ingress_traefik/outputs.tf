output "ingress_namespace" {
  value = kubernetes_namespace.traefik_ingress.metadata[0].name
}