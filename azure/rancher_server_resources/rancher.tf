### Provision rancher
resource "kubernetes_namespace" "rancher" {
  metadata {

    labels = {
      creator = "baristalabs_rancher_server",
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

  rancher_hostname = local.rancher_server_hostnames.rancher
  rancher_replicas = 3

  naked_domain_cert    = data.azurerm_key_vault_certificate_data.naked_domain_cert
}


### Expose Ingress Routes
data "kubectl_path_documents" "rancher_ingress_routes" {
  pattern = "${path.module}/specs/rancher_ingress_routes.yaml"

  vars = {
    rancher_hostname = local.rancher_server_hostnames.rancher
  }
}

resource "kubectl_manifest" "rancher_ingress_routes" {
    for_each  = toset(data.kubectl_path_documents.rancher_ingress_routes.documents)
    yaml_body = each.value

    override_namespace = kubernetes_namespace.rancher.metadata[0].name

    depends_on = [
      module.rancher_server_ingress,
      module.rancher_server
    ]
}
