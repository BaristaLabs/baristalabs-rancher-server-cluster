### Provision the traefik namespace
resource "kubernetes_namespace" "traefik_ingress" {
  metadata {

    labels = {
      creator = local.creator_name
      kind    = "traefik"
    }

    name = local.homelab_namespaces.traefik_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

### Provision a traefik-based ingress
module "homelab_ingress" {
  source = "../../modules/kubernetes_ingress_traefik"

  ingress_name      = "homelab-ingress"
  ingress_namespace = kubernetes_namespace.traefik_ingress.metadata[0].name

  traefik_service_account_name = "homelab-ingress-traefik"

  service_type        = "NodePort"

  web_node_port       = local.web_node_port
  websecure_node_port = local.websecure_node_port

  tailscale_ephemeral_auth_key = var.tailscale_ephemeral_auth_key

  traefik_additional_arguments = [
    "--ping",
    "--entryPoints.web.forwardedHeaders.insecure",
    "--entryPoints.websecure.forwardedHeaders.insecure",
  ]
}

# Provision the base traefik configuration
data "kubectl_path_documents" "traefik_config" {
  pattern = "${path.module}/specs/traefik_*.yaml"

  vars = {
    TRAEFIK_INSTANCE = "homelab-ingress"
    TRAEFIK_NAMESPACE = kubernetes_namespace.traefik_ingress.metadata[0].name
  }
}

resource "kubectl_manifest" "traefik_config" {
  count = length(
    flatten(
      toset([
        for f in fileset(".", data.kubectl_path_documents.traefik_config.pattern) : split("\n---\n", file(f))
        ]
      )
    )
  )

  yaml_body = element(data.kubectl_path_documents.traefik_config.documents, count.index)

  override_namespace = kubernetes_namespace.traefik_ingress.metadata[0].name

  depends_on = [
    module.homelab_ingress
  ]
}
