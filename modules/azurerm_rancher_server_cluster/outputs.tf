output "rancher_server_cluster" {
  value = azurerm_kubernetes_cluster.rancher_server
}

output "rancher_server_cluster_kube_config" {
  value = azurerm_kubernetes_cluster.rancher_server.kube_config_raw
}

output "rancher_server_cluster_admin_ssh_key" {
  value = tls_private_key.rancher_server_cluster_admin_ssh_key
}

output "rancher_server_cluster_worker_resource_group" {
  value = data.azurerm_resource_group.rancher_server_worker
}

output "rancher_server_cluster_outbound_ip" {
  value = data.azurerm_public_ip.rancher_server_cluster_outbound_ip
}

output "rancher_server_cluster_host" {
  value = azurerm_kubernetes_cluster.rancher_server.kube_config.0.host
}

output "rancher_server_cluster_client_certificate" {
  value     = azurerm_kubernetes_cluster.rancher_server.kube_config.0.client_certificate
  sensitive = true
}

output "rancher_server_cluster_client_key" {
  value     = azurerm_kubernetes_cluster.rancher_server.kube_config.0.client_key
  sensitive = true
}

output "rancher_server_cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.rancher_server.kube_config.0.cluster_ca_certificate
  sensitive = true
}