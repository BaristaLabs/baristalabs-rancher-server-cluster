### Provision a whoami service
resource "kubernetes_namespace" "whoami" {
  metadata {

    labels = {
      creator = local.creator_name
      kind    = "whoami"
    }

    name = local.espresso_namespaces.whoami_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}


data "kubectl_path_documents" "whoami" {
  pattern = "${path.module}/specs/whoami.yaml"

  vars = {
    whoami_hostname = local.espresso_hostnames.whoami
  }
}

resource "kubectl_manifest" "whoami" {
  for_each  = toset(data.kubectl_path_documents.whoami.documents)
  yaml_body = each.value

  override_namespace = kubernetes_namespace.whoami.metadata[0].name
}