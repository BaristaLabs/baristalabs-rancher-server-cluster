variable "tailscale_ephemeral_auth_key" {
  type        = string
  description = "The ephemeral auth key provided by tailscale available in your Tailscale account"
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to all resources that are created"
  default     = {}
}
