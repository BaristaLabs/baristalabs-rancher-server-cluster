# Set up the locals to use for the Espresso-01 environment
locals {
  hostname = "baristalabs.io"
  creator_name = "espresso_terraform"

  # Namespaces
  espresso_namespaces = {
    "cert_manager_namespace" = "cert-manager"
    "traefik_namespace"      = "traefik-system"
    "dapr_namespace"         = "dapr-system"
    "prometheus_namespace"   = "prometheus"
    "jaeger_namespace"       = "jaeger"
    "redis_namespace"        = "redis"

    "whoami_namespace"       = "whoami"
  }

  # Hostnames
  espresso_hostnames = {
    grafana = "grafana.${local.hostname}"
    alertmanager = "alertmanager.${local.hostname}"
    
    whoami          = "whoami.${local.hostname}"
    whoami_internal = "whoami.espresso.local"
  }

  web_node_port       = 30070
  websecure_node_port = 30071

  cert_admin_email = "sean@baristalabs.io"

  tags = merge(var.tags, { Creator = "terraform-baristalabs", Environment = "espresso-01" })
}
