# Provision Loki
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  version    = "2.8.2"

  namespace = "cattle-monitoring-system"

  values = [ 
    file("${path.module}/values/loki_stack_values.yaml")
  ]

  depends_on = [
    rancher2_app_v2.rancher_monitoring
  ]
}