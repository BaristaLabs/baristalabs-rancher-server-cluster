### Provision the traefik namespace
resource "kubernetes_namespace" "traefik_ingress" {
  metadata {

    labels = {
      creator = "rancher_server_terraform",
      kind    = "traefik"
    }

    name = local.rancher_server_namespaces.traefik_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }
}

### Provision a traefik-based ingress
module "rancher_server_ingress" {
  source = "../../modules/kubernetes_ingress_traefik"

  ingress_namespace = kubernetes_namespace.traefik_ingress.metadata[0].name

  kubernetes_ingress_public_ip = data.terraform_remote_state.rancher_server_cluster.outputs.rancher_server_cluster_ip
  kubernetes_ingress_replicas  = 1

  depends_on = [
    module.cert_manager
  ]
}

# Provision the base traefik configuration
data "kubectl_path_documents" "traefik_config" {
  pattern = "${path.module}/specs/traefik_*.yaml"
}

resource "kubectl_manifest" "traefik_config" {
  for_each = toset(data.kubectl_path_documents.traefik_config.documents)

  yaml_body = each.value

  override_namespace = kubernetes_namespace.traefik_ingress.metadata[0].name

  depends_on = [
    module.rancher_server_ingress
  ]
}
