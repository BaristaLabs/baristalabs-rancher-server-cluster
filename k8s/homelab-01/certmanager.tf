### Provision cert-manager
resource "kubernetes_namespace" "cert_manager" {
  metadata {

    labels = {
      creator = "rancher_server_terraform",
      kind    = "cert_manager"
    }

    name = local.homelab_namespaces.cert_manager_namespace
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

  cert_manager_namespace = local.homelab_namespaces.cert_manager_namespace
  cert_manager_replicas  = 3
}

### Provision the base cert manager configuration
data "kubectl_path_documents" "cert_manager_config" {
  pattern = "${path.module}/specs/cert_manager_*.yaml"
}

resource "kubectl_manifest" "cert_manager_config" {
  for_each  = toset(data.kubectl_path_documents.cert_manager_config.documents)
  yaml_body = each.value

  override_namespace = kubernetes_namespace.cert_manager.metadata[0].name

  depends_on = [
    module.homelab_ingress,
    module.cert_manager
  ]
}
