resource "helm_release" "monitoring_elasticsearch" {
  name       = "rancher-monitoring-elasticsearch"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "elasticsearch"
  version    = "18.2.7"

  namespace = "cattle-monitoring-system"

  values = [ 
    file("${path.module}/values/rancher_monitoring_elasticsearch_values.yaml")
  ]

  depends_on = [
    rancher2_app_v2.rancher_monitoring
  ]
}

# resource "helm_release" "jaeger_operator" {
#   name       = "jaeger-operator"
#   repository = "https://jaegertracing.github.io/helm-charts"
#   chart      = "jaeger-operator"
#   version    = "2.30.0"

#   namespace = "cattle-monitoring-system"

#   values = [ 
#     file("${path.module}/values/jaeger_operator_values.yaml")
#   ]

#   depends_on = [
#     module.cert_manager,
#     helm_release.monitoring_elasticsearch
#   ]
# }

# resource "helm_release" "jaeger" {
#   name       = "jaeger"
#   repository = "https://jaegertracing.github.io/helm-charts"
#   chart      = "jaeger"
#   version    = "0.56.6"

#   namespace = "cattle-monitoring-system"

#   values = [ 
#     file("${path.module}/values/jaeger_values.yaml")
#   ]

#   depends_on = [
#     module.cert_manager,
#     helm_release.monitoring_elasticsearch,
#     helm_release.jaeger_operator
#   ]
# }