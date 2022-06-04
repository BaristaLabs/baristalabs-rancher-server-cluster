resource "kubernetes_namespace" "redis" {
  metadata {

    labels = {
      creator = local.creator_name
      kind    = "redis"
    }

    name = local.homelab_namespaces.redis_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "helm_release" "bitnami_redis" {
  name       = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "16.9.5"

  namespace = kubernetes_namespace.redis.metadata[0].name
  
  values = [ 
    file("${path.module}/values/redis_values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.redis
  ]
}