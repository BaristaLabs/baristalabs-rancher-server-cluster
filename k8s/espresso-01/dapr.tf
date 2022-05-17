# Provision Dapr
resource "kubernetes_namespace" "dapr_namespace" {
  metadata {

    labels = {
      creator = local.creator_name
    }

    name = local.espresso_namespaces.dapr_namespace
  }
}

resource "helm_release" "dapr" {
  name       = "dapr"
  repository = "https://dapr.github.io/helm-charts/"
  chart      = "dapr"
  version    = "1.7.2"

  namespace = kubernetes_namespace.dapr_namespace.metadata[0].name

  set {
    name = "global.ha.enabled"
    value = "true"
  }
}

# TODO: Enable tracing with Jaeger
# data "kubectl_path_documents" "dapr_open_telemetry" {
#   pattern = "${path.module}/specs/open-telemetry-collector-jaeger.yaml"
# }

# resource "kubectl_manifest" "dapr_open_telemetry" {
#   for_each  = toset(data.kubectl_path_documents.dapr_open_telemetry.documents)
#   yaml_body = each.value

#   override_namespace = kubernetes_namespace.dapr_namespace.metadata[0].name
# }