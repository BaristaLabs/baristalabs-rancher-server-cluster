### Provision the traefik namespace
resource "kubernetes_namespace" "traefik_ingress" {
  metadata {

    labels = {
      creator = "espresso_terraform",
      kind    = "traefik"
    }

    name = local.espresso_namespaces.traefik_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }
}

### Provision a traefik-based ingress
module "espresso_ingress" {
  source = "../../modules/kubernetes_ingress_traefik"

  ingress_name      = "espresso-ingress"
  ingress_namespace = kubernetes_namespace.traefik_ingress.metadata[0].name

  traefik_service_account_name = "espresso-ingress-traefik"

  service_type        = "NodePort"
  web_node_port       = local.web_node_port
  websecure_node_port = local.websecure_node_port

  tailscale_ephemeral_auth_key = var.tailscale_ephemeral_auth_key

  traefik_additional_arguments = [
    "--ping",
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
    module.espresso_ingress
  ]
}
