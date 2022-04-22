resource "kubernetes_namespace" "whoami" {
  metadata {

    labels = {
      creator = "baristalabs_rancher_server"
      kind    = "whoami"
    }

    name = var.whoami_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }
}

resource "kubectl_manifest" "whoami" {
  for_each  = toset(var.whoami_documents)
  yaml_body = each.value

  override_namespace = kubernetes_namespace.whoami.metadata[0].name
}
