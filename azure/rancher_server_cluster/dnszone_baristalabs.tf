# Provision a DNS Zone and associated records

resource "azurerm_dns_zone" "baristalabs" {
  name                = local.baristalabs_hostname
  resource_group_name = module.rancher_server.rancher_server_resource_group.name
}

resource "azurerm_dns_a_record" "baristalabs_hostname" {
  name                = "@"
  zone_name           = azurerm_dns_zone.baristalabs.name
  resource_group_name = module.rancher_server.rancher_server_resource_group.name
  ttl                 = 300
  target_resource_id  = module.rancher_server_cluster.rancher_server_cluster_outbound_ip.id
}

resource "azurerm_dns_a_record" "baristalabs_hostname_wildcard" {
  name                = "*"
  zone_name           = azurerm_dns_zone.baristalabs.name
  resource_group_name = module.rancher_server.rancher_server_resource_group.name
  ttl                 = 300
  target_resource_id  = module.rancher_server_cluster.rancher_server_cluster_outbound_ip.id
}

# grant the kubernetes service account access to the DNS zone
resource "azurerm_role_assignment" "baristalabs_dns_zone_contributor" {
  scope                = azurerm_dns_zone.baristalabs.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = module.rancher_server_cluster.rancher_server_cluster.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}