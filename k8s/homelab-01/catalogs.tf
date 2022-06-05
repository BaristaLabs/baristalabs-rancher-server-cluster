resource "rancher2_catalog_v2" "k8s-at-home" {
  cluster_id = var.cluster_id
  name       = "k8s-at-home"
  url        = "https://k8s-at-home.com/charts/"
}

resource "rancher2_catalog_v2" "nextcloud" {
  cluster_id = var.cluster_id
  name       = "nextcloud"
  url        = "https://nextcloud.github.io/helm/"
}

resource "rancher2_catalog_v2" "bitnami" {
  cluster_id = var.cluster_id
  name       = "bitnami"
  url        = "https://charts.bitnami.com/bitnami"
}

resource "rancher2_catalog_v2" "elastic" {
  cluster_id = var.cluster_id
  name       = "elastic"
  url        = "https://helm.elastic.co"
}

resource "rancher2_catalog_v2" "mojo2600" {
  cluster_id = var.cluster_id
  name       = "mojo2600"
  url        = "https://mojo2600.github.io/pihole-kubernetes/"
}

resource "rancher2_catalog_v2" "oauth2-proxy" {
  cluster_id = var.cluster_id
  name       = "oauth2-proxy"
  url        = "https://oauth2-proxy.github.io/manifests"
}

resource "rancher2_catalog_v2" "gitea-charts" {
  cluster_id = var.cluster_id
  name       = "gitea-charts"
  url        = "https://dl.gitea.io/charts/"
}

resource "rancher2_catalog_v2" "nats" {
  cluster_id = var.cluster_id
  name       = "nats"
  url        = "https://nats-io.github.io/k8s/helm/charts/"
}
