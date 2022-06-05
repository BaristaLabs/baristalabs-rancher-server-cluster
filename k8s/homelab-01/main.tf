# Set up the locals to use for the Homelab-01 environment
locals {
  hostname = "baristalabs.io"
  creator_name = "homelab_terraform"

  # Namespaces
  homelab_namespaces = {
    "cert_manager_namespace" = "cert-manager"
    "traefik_namespace"      = "traefik-system"
    "dapr_namespace"         = "dapr-system"

    "redis_namespace"        = "redis"

    "whoami_namespace"       = "whoami"
  }

  # Hostnames
  homelab_hostnames = {
    grafana = "grafana.${local.hostname}"
    alertmanager = "alertmanager.${local.hostname}"
    
    whoami          = "whoami.${local.hostname}"
    whoami_internal = "whoami.homelab.local"
  }

  web_node_port       = 30070
  websecure_node_port = 30071

  cert_admin_email = "sean@baristalabs.io"

  tags = merge(var.tags, { Creator = "terraform-baristalabs", Environment = "homelab-01" })
}
