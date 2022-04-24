output "rancher_server_dns_name_servers" {
  value = azurerm_dns_zone.rancher_server.name_servers
}