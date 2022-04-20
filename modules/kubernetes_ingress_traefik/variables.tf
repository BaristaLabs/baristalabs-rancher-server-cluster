variable "ingress_namespace" {
  type = string
  description = "the name of the ingress namespace such as traefik-ingress"
}

variable "kubernetes_ingress_public_ip" {
  type        = string
  description = "kubernetes ingress public ip"
  default     = null
}

variable "kubernetes_ingress_replicas" {
  type        = number
  description = "indicates the number of replicas to use"
}

variable "naked_domain_cert" {
  type = object({
    name = string
    pem = string
    key = string
  })
  description = "a naked domain certificate to store as a secret associated with the ingress"
}

variable "wildcard_domain_cert" {
  type = object({
    name = string
    pem = string
    key = string
  })
  description = "a wildcard domain certificate to store as a secret associated with the ingress"
}