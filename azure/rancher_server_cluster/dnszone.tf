# Provision a DNS Zone and associated records

resource "azurerm_dns_zone" "rancher_server" {
  name                = local.rancher_server_hostname
  resource_group_name = module.rancher_server.rancher_server_resource_group.name
}

resource "azurerm_dns_a_record" "rancher_server_hostname" {
  name                = "@"
  zone_name           = azurerm_dns_zone.rancher_server.name
  resource_group_name = module.rancher_server.rancher_server_resource_group.name
  ttl                 = 300
  target_resource_id  = module.rancher_server_cluster.rancher_server_cluster_outbound_ip.id
}

resource "azurerm_dns_a_record" "rancher_server_hostname_wildcard" {
  name                = "*"
  zone_name           = azurerm_dns_zone.rancher_server.name
  resource_group_name = module.rancher_server.rancher_server_resource_group.name
  ttl                 = 300
  target_resource_id  = module.rancher_server_cluster.rancher_server_cluster_outbound_ip.id
}