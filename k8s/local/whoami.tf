### Provision a whoami service
resource "kubernetes_namespace" "whoami" {
  metadata {

    labels = {
      creator = "rancher_server_terraform"
      kind    = "whoami"
    }

    name = local.rancher_server_namespaces.whoami_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }
}


data "kubectl_path_documents" "whoami" {
  pattern = "${path.module}/specs/whoami.yaml"

  vars = {
    whoami_hostname = local.rancher_server_hostnames.whoami
  }
}

resource "kubectl_manifest" "whoami" {
  for_each  = toset(data.kubectl_path_documents.whoami.documents)
  yaml_body = each.value

  override_namespace = kubernetes_namespace.whoami.metadata[0].name
  
  depends_on = [
    module.cert_manager,
    module.rancher_server_ingress
  ]
}
