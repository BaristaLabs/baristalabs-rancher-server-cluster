// See https://docs.microsoft.com/en-us/azure/dev-spaces/how-to/ingress-https-traefik
// https://github.com/traefik/traefik-helm-chart

locals {
  traefik_additional_arguments = [
    "--ping",
    "--entrypoints.web.http.redirections.entrypoint.priority=1",
    "--entrypoints.web.http.redirections.entrypoint.scheme=https",
    "--entrypoints.web.http.redirections.entryPoint.to=:443"
  ]
}

resource "helm_release" "traefik_ingress" {
  name       = "traefik-ingress"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "10.19.4"

  namespace = var.ingress_namespace

  verify = false

  values = [ 
    file("${path.module}/values/traefik_values.yaml")
  ]

  set {
    name  = "service.type"
    value = var.service_type == null ? "LoadBalancer" : var.service_type
  }

  set {
    name  = "additionalArguments"
    value = "{${join(",", local.traefik_additional_arguments)}}"
  }

  dynamic "set" {
    for_each = var.kubernetes_ingress_public_ip == null ? [] : [1]

    content {
      name  = "service.spec.loadBalancerIP"
      value = var.kubernetes_ingress_public_ip
    }
  }
}