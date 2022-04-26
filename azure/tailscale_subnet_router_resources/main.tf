# Set up the locals to use for the Tailscale environment
locals {
  hostname = "baristalabs.io"

  # Namespaces
  tailscale_namespace  = "tailscale"

  tags = merge(var.tags, { Creator = "terraform-baristalabs-rancher-server", Environment = "rancher_server_01" })
}
