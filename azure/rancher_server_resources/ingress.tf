### Provision a traefik-based ingress
module "rancher_server_ingress" {
  source = "../../modules/kubernetes_ingress_traefik"

  ingress_namespace = local.rancher_server_namespaces.ingress_namespace

  kubernetes_ingress_public_ip = data.terraform_remote_state.rancher_server_cluster.outputs.rancher_server_cluster_ip
  kubernetes_ingress_replicas  = 1

  naked_domain_cert    = data.azurerm_key_vault_certificate_data.naked_domain_cert
  wildcard_domain_cert = data.azurerm_key_vault_certificate_data.wildcard_domain_cert
}

### Expose Ingress Routes
data "kubectl_path_documents" "ingress_routes" {
  pattern = "${path.module}/specs/ingress_routes.yaml"
}

resource "kubectl_manifest" "ingress_routes" {
    for_each  = toset(data.kubectl_path_documents.ingress_routes.documents)
    yaml_body = each.value

    depends_on = [
      module.rancher_server_ingress
    ]
}
