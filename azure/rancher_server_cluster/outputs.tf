output "rancher_server_name" {
  value = local.environment
}

output "rancher_server_resource_group_name" {
  value = module.rancher_server.rancher_server_resource_group.name
}

output "rancher_server_application_insights" {
  value     = module.rancher_server.rancher_server_application_insights
  sensitive = true
}

output "rancher_server_cluster_name" {
  value = module.rancher_server_cluster.rancher_server_cluster.name
}

output "rancher_server_cluster_hostname" {
  value = trim(azurerm_dns_a_record.rancher_server_hostname.fqdn, ".")
}

output "rancher_server_cluster_dns_name_servers" {
  value = azurerm_dns_zone.domain.name_servers
}

output "rancher_server_cluster_ip_id" {
  value = module.rancher_server_cluster.rancher_server_cluster_outbound_ip.id
}

output "rancher_server_cluster_ip" {
  value = module.rancher_server_cluster.rancher_server_cluster_outbound_ip.ip_address
}

output "rancher_server_cluster_worker_resource_group_name" {
  value = module.rancher_server_cluster.rancher_server_cluster_worker_resource_group.name
}

output "rancher_server_cluster_worker_resource_group_location" {
  value = module.rancher_server_cluster.rancher_server_cluster_worker_resource_group.location
}

output "rancher_server_cluster_kubelet_identity" {
  value = module.rancher_server_cluster.rancher_server_cluster.kubelet_identity[0].object_id
}

output "rancher_server_cluster_kubelet_client_id" {
  value = module.rancher_server_cluster.rancher_server_cluster.kubelet_identity[0].client_id
}

output "rancher_server_cluster_identity" {
  value = module.rancher_server_cluster.rancher_server_cluster.identity[0].principal_id
}

output "domain_dns_zone" {
  value = azurerm_dns_zone.domain
}

output "treasuryecm_domain_dns_zone" {
  value = azurerm_dns_zone.treasuryecm_domain
}
