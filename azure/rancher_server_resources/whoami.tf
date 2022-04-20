### Provision a whoami service

data "kubectl_path_documents" "whoami" {
  pattern = "${path.module}/specs/whoami.yaml"

  vars = {
    whoami_hostname = local.rancher_server_hostnames.whoami
  }
}

module "whoami_service" {
  source = "../../modules/kubernetes_whoami_service"

  whoami_namespace = local.rancher_server_namespaces.whoami_namespace
  whoami_documents = data.kubectl_path_documents.whoami.documents

  depends_on = [
    module.rancher_server_ingress
  ]
}