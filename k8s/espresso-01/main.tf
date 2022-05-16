# Set up the locals to use for the Espresso-01 environment
locals {
  hostname = "baristalabs.io"

  # Namespaces
  espresso_namespaces = {
    "cert_manager_namespace" = "cert-manager"
    "traefik_namespace"      = "traefik-system"
    "whoami_namespace"       = "whoami"
  }

  # Hostnames
  espresso_hostnames = {
    "whoami" = "whoami.${local.hostname}"
  }

  web_node_port       = 30070
  websecure_node_port = 30071

  cert_admin_email = "sean@baristalabs.io"

  tags = merge(var.tags, { Creator = "terraform-baristalabs", Environment = "espresso-01" })
}
