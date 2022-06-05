# Provision Prometheus

resource "rancher2_app_v2" "rancher_monitoring" {
  cluster_id = var.cluster_id
  name          = "rancher-monitoring"
  namespace     = "cattle-monitoring-system"
  repo_name     = "rancher-charts"
  chart_name    = "rancher-monitoring"
  chart_version = "100.1.2+up19.0.3"
  values = file("${path.module}/values/rancher_monitoring_values.yaml")
}

# Provision the ingress routes
data "kubectl_path_documents" "rancher_monitoring_ingress" {
  pattern = "${path.module}/specs/rancher_monitoring_ingress_routes.yaml"

  vars = {
    grafana_hostname = local.homelab_hostnames.grafana
    alertmanager_hostname = local.homelab_hostnames.alertmanager
  }
}

resource "kubectl_manifest" "rancher_monitoring_ingress" {
  for_each = toset(data.kubectl_path_documents.rancher_monitoring_ingress.documents)

  yaml_body = each.value

  override_namespace = "cattle-monitoring-system"

  depends_on = [
    module.homelab_ingress,
    rancher2_app_v2.rancher_monitoring
  ]
}
