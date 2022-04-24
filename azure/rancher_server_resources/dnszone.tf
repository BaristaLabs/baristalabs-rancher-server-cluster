# Provision a DNS Zone and associated records

resource "azurerm_dns_zone" "rancher_server" {
  name                = local.rancher_server_hostnames.rancher
  resource_group_name = data.terraform_remote_state.rancher_server_cluster.outputs.rancher_server_resource_group_name
}

resource "azurerm_dns_a_record" "rancher_server_hostname" {
  name                = "@"
  zone_name           = azurerm_dns_zone.rancher_server.name
  resource_group_name = data.terraform_remote_state.rancher_server_cluster.outputs.rancher_server_resource_group_name
  ttl                 = 300
  records             = [data.terraform_remote_state.rancher_server_cluster.outputs.rancher_server_cluster_ip]
}

resource "azurerm_dns_a_record" "rancher_server_hostname_wildcard" {
  name                = "*"
  zone_name           = azurerm_dns_zone.rancher_server.name
  resource_group_name = data.terraform_remote_state.rancher_server_cluster.outputs.rancher_server_resource_group_name
  ttl                 = 300
  records             = [data.terraform_remote_state.rancher_server_cluster.outputs.rancher_server_cluster_ip]
}