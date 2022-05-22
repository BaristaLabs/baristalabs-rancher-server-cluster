### Provision domain level routing
resource "kubernetes_namespace" "domain" {
  metadata {

    labels = {
      creator = "rancher_server_terraform"
      kind    = "domain"
    }

    name = local.rancher_server_namespaces.domain_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }
}

data "kubectl_path_documents" "domain_routes" {
  pattern = "${path.module}/specs/domain_routes.yaml"

  vars = {
    hostname = local.root_hostname
  }
}

resource "kubectl_manifest" "domain_routes" {
  for_each  = toset(data.kubectl_path_documents.domain_routes.documents)
  yaml_body = each.value

  override_namespace = kubernetes_namespace.domain.metadata[0].name
  
  depends_on = [
    module.cert_manager
  ]
}
