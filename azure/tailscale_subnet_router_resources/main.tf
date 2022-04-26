# Set up the locals to use for the Tailscale environment
locals {
  hostname = "baristalabs.io"

  # Namespaces
  tailscale_namespace  = "tailscale"

  tailscale_image_repository = "baristalabs/tailscale-k8s"
  tailscale_image_tag = "latest"

  tags = merge(var.tags, { Creator = "terraform-baristalabs-rancher-server", Environment = "rancher_server_01" })
}
