### Provision cert-manager
resource "kubernetes_namespace" "cert_manager" {
  metadata {

    labels = {
      creator = "rancher_server_terraform",
      kind    = "cert_manager"
    }

    name = local.rancher_server_namespaces.cert_manager_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

module "cert_manager" {
  source = "../../modules/kubernetes_cert_manager"

  cert_manager_namespace = local.rancher_server_namespaces.cert_manager_namespace
  cert_manager_replicas  = 3
}

### Provision the base cert manager configuration
data "kubectl_path_documents" "cert_manager_config" {
  pattern = "${path.module}/specs/cert_manager_*.yaml"

  vars  = {
    CERT_ADMIN_EMAIL = local.cert_admin_email

    AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.current.subscription_id
    RANCHER_AZURE_DNS_ZONE_RESOURCE_GROUP = data.terraform_remote_state.rancher_server_cluster.outputs.rancher_server_dns_zone.resource_group_name
    RANCHER_AZURE_DNS_ZONE = data.terraform_remote_state.rancher_server_cluster.outputs.rancher_server_dns_zone.name
    DOMAIN_AZURE_DNS_ZONE_RESOURCE_GROUP = data.terraform_remote_state.rancher_server_cluster.outputs.baristalabs_dns_zone.resource_group_name
    DOMAIN_AZURE_DNS_ZONE = data.terraform_remote_state.rancher_server_cluster.outputs.baristalabs_dns_zone.name
    MANAGED_IDENTITY_CLIENT_ID = data.terraform_remote_state.rancher_server_cluster.outputs.rancher_server_cluster_kubelet_client_id
  }
}

resource "kubectl_manifest" "cert_manager_config" {
    for_each  = toset(data.kubectl_path_documents.cert_manager_config.documents)
    yaml_body = each.value

    override_namespace = kubernetes_namespace.cert_manager.metadata[0].name

    depends_on = [
      module.rancher_server_ingress,
      module.rancher_server
    ]
}
