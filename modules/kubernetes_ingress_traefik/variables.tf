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
