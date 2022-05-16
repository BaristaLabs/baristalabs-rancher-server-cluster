locals {
  tags = merge(var.tags, { Creator = "terraform-baristalabs-rancher-server", "Environment" = "${var.environment_prefix}-${var.environment}" })
}

resource "azurerm_resource_group" "rancher_server" {
  name     = "rg-${var.environment_prefix}-${var.environment}"
  location = var.az_region

  tags = local.tags
}

# Create Azure Monitor Resources
resource "azurerm_application_insights" "rancher_server_monitoring" {
  count = var.use_application_insights ? 1 : 0

  name                = "appi-${var.environment_prefix}-${var.environment}"
  location            = azurerm_resource_group.rancher_server.location
  resource_group_name = azurerm_resource_group.rancher_server.name
  application_type    = "web"

  tags = local.tags
}

## Add the app insights id and instrumentation key as AKV Secrets
resource "azurerm_key_vault_secret" "rancher_server_ai_app_id" {
  count = var.use_application_insights ? 1 : 0

  name         = "${var.environment_prefix}-${var.environment}-ai-app-id"
  value        = azurerm_application_insights.rancher_server_monitoring[0].app_id
  key_vault_id = var.rancher_server_devops_key_vault.id

  tags = local.tags
}

resource "azurerm_key_vault_secret" "rancher_server_ai_instrumentation_key" {
  count = var.use_application_insights ? 1 : 0

  name         = "${var.environment_prefix}-${var.environment}-ai-instrumentation-key"
  value        = azurerm_application_insights.rancher_server_monitoring[0].instrumentation_key
  key_vault_id = var.rancher_server_devops_key_vault.id

  tags = local.tags
}

## Create the Log Analytics Workspace for the environment
resource "azurerm_log_analytics_workspace" "rancher_server_monitoring" {
  count = var.use_log_analytics ? 1 : 0

  name                = "log-${var.environment_prefix}-${var.environment}"
  location            = azurerm_resource_group.rancher_server.location
  resource_group_name = azurerm_resource_group.rancher_server.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention

  tags = local.tags
}

resource "azurerm_log_analytics_solution" "rancher_server_monitoring_containers" {
  count = var.use_container_insights ? 1 : 0

  solution_name         = "Containers"
  workspace_resource_id = azurerm_log_analytics_workspace.rancher_server_monitoring[0].id
  workspace_name        = azurerm_log_analytics_workspace.rancher_server_monitoring[0].name
  location              = azurerm_resource_group.rancher_server.location
  resource_group_name   = azurerm_resource_group.rancher_server.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }
}

resource "azurerm_key_vault_secret" "rancher_server_log_workspace_id" {
  count = var.use_log_analytics ? 1 : 0

  name         = "${var.environment_prefix}-${var.environment}-log-workspace-id"
  value        = azurerm_log_analytics_workspace.rancher_server_monitoring[0].workspace_id
  key_vault_id = var.rancher_server_devops_key_vault.id

  tags = local.tags
}

resource "azurerm_key_vault_secret" "rancher_server_log_key" {
  count = var.use_log_analytics ? 1 : 0

  name         = "${var.environment_prefix}-${var.environment}-log-key"
  value        = azurerm_log_analytics_workspace.rancher_server_monitoring[0].primary_shared_key
  key_vault_id = var.rancher_server_devops_key_vault.id

  tags = local.tags
}

// Create a virtual network to hold Rancher Server resources
resource "azurerm_virtual_network" "rancher_server_network" {
  name                = "vnet-${var.environment_prefix}-${var.environment}"
  address_space       = [var.rancher_server_vnet_cidr]
  location            = azurerm_resource_group.rancher_server.location
  resource_group_name = azurerm_resource_group.rancher_server.name

  tags = local.tags
}

// Peer the virtual network to the VPN Resource Group
resource "azurerm_virtual_network_peering" "rancher_server_peer" {
  count = var.use_vnet_peer ? 1 : 0

  name                = "vnet-peering-${var.environment_prefix}-${var.environment}-to-${var.peer_virtual_network_name}"
  resource_group_name = azurerm_resource_group.rancher_server.name

  virtual_network_name      = azurerm_virtual_network.rancher_server_network.name
  remote_virtual_network_id = var.peer_virtual_network_id

  use_remote_gateways     = true
  allow_forwarded_traffic = false
  allow_gateway_transit   = false
}

resource "azurerm_virtual_network_peering" "peer_to_rancher_server" {
  count = var.use_vnet_peer ? 1 : 0

  name                = "vnet-peering-${var.peer_virtual_network_name}-to-${var.environment_prefix}-${var.environment}"
  resource_group_name = var.peer_virtual_network_resource_group_name

  virtual_network_name      = var.peer_virtual_network_name
  remote_virtual_network_id = azurerm_virtual_network.rancher_server_network.id

  use_remote_gateways     = false
  allow_forwarded_traffic = true
  allow_gateway_transit   = true
}

resource "azurerm_network_security_group" "rancher_server_network" {
  name                = "nsg-${var.environment_prefix}-${var.environment}"
  location            = azurerm_resource_group.rancher_server.location
  resource_group_name = azurerm_resource_group.rancher_server.name

  tags = local.tags
}

resource "azurerm_network_security_rule" "rancher_server_network_allow_http" {
  name                        = "${var.environment_prefix}-${var.environment}-http"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = var.only_allow_frontdoor_traffic ? "AzureFrontDoor.Backend" : (var.rancher_server_ip_whitelist == null ? "*" : null)
  source_address_prefixes     = var.only_allow_frontdoor_traffic ? null : (var.rancher_server_ip_whitelist == null ? null : var.rancher_server_ip_whitelist)
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rancher_server.name
  network_security_group_name = azurerm_network_security_group.rancher_server_network.name
}


resource "azurerm_network_security_rule" "rancher_server_network_allow_https" {
  name                        = "${var.environment_prefix}-${var.environment}-https"
  priority                    = 501
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = var.only_allow_frontdoor_traffic ? "AzureFrontDoor.Backend" : (var.rancher_server_ip_whitelist == null ? "*" : null)
  source_address_prefixes     = var.only_allow_frontdoor_traffic ? null : (var.rancher_server_ip_whitelist == null ? null : var.rancher_server_ip_whitelist)
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rancher_server.name
  network_security_group_name = azurerm_network_security_group.rancher_server_network.name
}

## Define a subnet for the environment
resource "azurerm_subnet" "rancher_server_subnet" {
  name                 = var.rancher_server_subnet_name
  resource_group_name  = azurerm_resource_group.rancher_server.name
  virtual_network_name = azurerm_virtual_network.rancher_server_network.name
  address_prefixes     = [var.rancher_server_subnet_cidr]
  service_endpoints    = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"]
}

resource "azurerm_subnet_network_security_group_association" "rancher_server_network_environment" {
  subnet_id                 = azurerm_subnet.rancher_server_subnet.id
  network_security_group_id = azurerm_network_security_group.rancher_server_network.id
}

# Create the subnet for aks resources
resource "azurerm_subnet" "rancher_server_aks_subnet" {
  name                 = var.rancher_server_aks_subnet_name
  virtual_network_name = azurerm_virtual_network.rancher_server_network.name
  resource_group_name  = azurerm_resource_group.rancher_server.name
  address_prefixes     = [var.rancher_server_aks_subnet_cidr]
  service_endpoints    = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"]
}


resource "azurerm_subnet_network_security_group_association" "rancher_server_aks_environment" {
  subnet_id                 = azurerm_subnet.rancher_server_aks_subnet.id
  network_security_group_id = azurerm_network_security_group.rancher_server_network.id
}
