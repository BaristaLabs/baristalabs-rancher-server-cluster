variable "cert_manager_namespace" {
  type        = string
  description = "the name of the cert manager namespace such as traefik-ingress"
}

variable "cert_manager_replicas" {
  type        = number
  description = "indicates the number of replicas to use"
}
