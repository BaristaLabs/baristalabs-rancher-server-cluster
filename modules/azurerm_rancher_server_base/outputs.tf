output "rancher_server_resource_group" {
  value = azurerm_resource_group.rancher_server
}

output "rancher_server_vnet" {
  value = azurerm_virtual_network.rancher_server_network
}

output "rancher_server_subnet" {
  value = azurerm_subnet.rancher_server_subnet
}

output "rancher_server_aks_subnet" {
  value = azurerm_subnet.rancher_server_aks_subnet
}

output "rancher_server_application_insights" {
  value = var.use_log_analytics ? azurerm_application_insights.rancher_server_monitoring[0] : null
}

output "rancher_server_log_analytics_workspace" {
  value = var.use_log_analytics ? azurerm_log_analytics_workspace.rancher_server_monitoring[0] : null
}
