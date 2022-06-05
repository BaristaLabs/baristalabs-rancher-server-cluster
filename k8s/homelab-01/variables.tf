variable "cluster_id" {
  type        = string
  description = "The rancher id of the homelab cluster"
}

variable "cluster_api_url" {
  type        = string
  description = "The url to the rancher server api - e.x. https://rancher.my-domain.com/v3"
}

variable "cluster_token_key" {
  type        = string
  description = "A Rancher API Token Key that has access to the cluster"
}

variable "tailscale_ephemeral_auth_key" {
  type        = string
  description = "The ephemeral auth key provided by tailscale available in your Tailscale account"
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to all resources that are created"
  default     = {}
}
