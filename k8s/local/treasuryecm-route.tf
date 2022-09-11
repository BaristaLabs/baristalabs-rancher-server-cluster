### Provision an treasuryecm forwarding service
resource "kubernetes_namespace" "treasuryecm" {
  metadata {

    labels = {
      creator = "rancher_server_terraform"
      kind    = "treasuryecm"
    }

    name = "treasuryecm"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }
}
data "kubectl_path_documents" "treasuryecm_route" {
  pattern = "${path.module}/specs/treasuryecm-route.yaml"
}

resource "kubectl_manifest" "treasuryecm_route" {
  for_each  = toset(data.kubectl_path_documents.treasuryecm_route.documents)
  yaml_body = each.value

  override_namespace = kubernetes_namespace.treasuryecm.metadata[0].name
  
  depends_on = [
    module.cert_manager
  ]
}