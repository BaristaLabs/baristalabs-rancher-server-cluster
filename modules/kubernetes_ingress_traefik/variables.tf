variable "traefik_additional_arguments" {
  type = list(string)
  description = "indicates the additional arguments to pass to traefik"
  default = [
    "--ping",
    "--entrypoints.web.http.redirections.entrypoint.priority=1",
    "--entrypoints.web.http.redirections.entrypoint.scheme=https",
    "--entrypoints.web.http.redirections.entryPoint.to=:443"
  ]
}

variable "ingress_namespace" {
  type = string
  description = "the name of the ingress namespace such as traefik-ingress"
}

variable "service_type" {
  type = string
  default = "LoadBalancer"
}

variable "kubernetes_ingress_public_ip" {
  type        = string
  description = "kubernetes ingress public ip"
  default     = null
}

variable "tailscale_ephemeral_auth_key" {
  type        = string
  description = "The ephemeral auth key provided by tailscale available in your Tailscale account"
}
