# Provision Loki
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  version    = "2.6.4"

  namespace = kubernetes_namespace.monitoring.metadata[0].name

  values = [ 
    file("${path.module}/values/loki_stack_values.yaml")
  ]

  depends_on = [
    helm_release.prometheus_stack
  ]
}