### Provision rancher
resource "kubernetes_namespace" "rancher" {
  metadata {

    labels = {
      creator = "rancher_server_terraform",
      kind    = "rancher"
    }

    name = local.rancher_server_namespaces.rancher_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

module "rancher_server" {
  source = "../../modules/kubernetes_rancher"

  rancher_namespace = kubernetes_namespace.rancher.metadata[0].name

  rancher_hostname = data.terraform_remote_state.rancher_server_cluster.outputs.rancher_server_cluster_hostname
  rancher_replicas = 3

  depends_on = [
    module.cert_manager
  ]
}


### Expose Ingress Routes
data "kubectl_path_documents" "rancher_ingress_routes" {
  pattern = "${path.module}/specs/rancher_ingress_routes.yaml"

  vars = {
    rancher_hostname = data.terraform_remote_state.rancher_server_cluster.outputs.rancher_server_cluster_hostname
  }
}

resource "kubectl_manifest" "rancher_ingress_routes" {
    for_each  = toset(data.kubectl_path_documents.rancher_ingress_routes.documents)
    yaml_body = each.value

    override_namespace = kubernetes_namespace.rancher.metadata[0].name

    depends_on = [
      kubectl_manifest.cert_manager_config,
      module.rancher_server_ingress,
      module.rancher_server
    ]
}
