variable "rancher_namespace" {
  type        = string
  description = "the name of the rancher namespace such as traefik-ingress"
}

variable "rancher_version" {
  type        = string
  description = "the rancher version to use"
  default     = "2.6.6"
}

variable "rancher_hostname" {
  type        = string
  description = "indicates the rancher hostname"
}

variable "rancher_replicas" {
  type        = number
  description = "indicates the number of replicas to use"
}
