### Provision an espresso-01 forwarding service
resource "kubernetes_namespace" "espresso_01" {
  metadata {

    labels = {
      creator = "rancher_server_terraform"
      kind    = "espresso-01"
    }

    name = local.rancher_server_namespaces.espresso_01_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }
}

data "kubectl_path_documents" "espresso_01_service" {
  pattern = "${path.module}/specs/espresso-01-service.yaml"
}

resource "kubectl_manifest" "espresso_01_service" {
  for_each  = toset(data.kubectl_path_documents.espresso_01_service.documents)
  yaml_body = each.value

  override_namespace = kubernetes_namespace.espresso_01.metadata[0].name
  
  depends_on = [
    module.cert_manager
  ]
}

data "kubectl_path_documents" "espresso_01_forward" {
  for_each = local.espresso_01_hostnames

  pattern = "${path.module}/specs/espresso-01-forward.yaml"

  vars = {
    name = each.key
    url  = each.value
  }
}

locals {
  espresso_01_forward_documents = flatten([
    for host_name, host in data.kubectl_path_documents.espresso_01_forward : host.documents
  ])
}

resource "kubectl_manifest" "espresso_01_forward" {
  for_each  = toset(local.espresso_01_forward_documents)
  yaml_body = each.value

  override_namespace = kubernetes_namespace.espresso_01.metadata[0].name
  
  depends_on = [
    module.cert_manager,
    kubectl_manifest.espresso_01_service
  ]
}