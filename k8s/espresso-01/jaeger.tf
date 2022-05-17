# resource "kubernetes_namespace" "jaeger" {
#   metadata {

#     labels = {
#       creator = local.creator_name
#       kind    = "jaegar"
#     }

#     name = local.espresso_namespaces.jaeger_namespace
#   }
# }

# resource "helm_release" "jaeger_operator" {
#   name       = "jaeger-operator"
#   repository = "https://jaegertracing.github.io/helm-charts"
#   chart      = "jaeger-operator"
#   version    = "2.30.0"
# }

# resource "helm_release" "jaeger" {
#   name       = "jaeger"
#   repository = "https://jaegertracing.github.io/helm-charts"
#   chart      = "jaeger"
#   version    = "0.56.5"

#   namespace = kubernetes_namespace.redis.metadata[0].name
#   values = [ 
#     file("${path.module}/values/jaegar_values.yaml")
#   ]
# }