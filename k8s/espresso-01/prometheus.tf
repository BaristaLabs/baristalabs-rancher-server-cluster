# Provision Prometheus

resource "helm_release" "prometheus_stack" {
  name       = "prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "35.2.0"

  namespace = kubernetes_namespace.monitoring.metadata[0].name

  values = [ 
    file("${path.module}/values/prometheus_stack_values.yaml")
  ]
}

# Provision the ingress routes
data "kubectl_path_documents" "prometheus_stack_ingress" {
  pattern = "${path.module}/specs/prometheus_stack_ingress_routes.yaml"

  vars = {
    grafana_hostname = local.espresso_hostnames.grafana
    alertmanager_hostname = local.espresso_hostnames.alertmanager
  }
}

resource "kubectl_manifest" "prometheus_stack_ingress" {
  for_each = toset(data.kubectl_path_documents.prometheus_stack_ingress.documents)

  yaml_body = each.value

  override_namespace = kubernetes_namespace.monitoring.metadata[0].name

  depends_on = [
    module.espresso_ingress,
    helm_release.prometheus_stack
  ]
}
