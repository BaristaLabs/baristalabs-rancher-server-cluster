variable "tailscale_auth_key" {
  type        = string
  description = "The auth key provided by tailscale available in your Tailscale account"
}

variable "rancher_server_cluster_name" {
  type        = string
  description = "The name of the rancher server kubernetes cluster - this should match the value of the context in kubeconfig"
  default     = "aks-rancher-server-01"
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to all resources that are created"
  default     = {}
}
