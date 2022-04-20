locals {
  tags = merge(var.tags, { Creator = "terraform-baristalabs-rancher-server", "Environment" = "${var.environment_prefix}-${var.environment}" })
}

# Create some random strings for resource names
resource "random_string" "rancher_server_cluster_admin_username_suffix" {
  length  = 6
  upper   = false
  lower   = true
  number  = true
  special = false
}

resource "random_password" "rancher_server_cluster_admin_password" {
  length  = 32
  upper   = true
  lower   = true
  number  = true
  special = true
}

resource "tls_private_key" "rancher_server_cluster_admin_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the resources.

resource "azurerm_kubernetes_cluster" "rancher_server" {
  name                = "aks-${var.environment_prefix}-${var.environment}"
  resource_group_name = var.rancher_server_resource_group.name
  location            = var.rancher_server_resource_group.location
  dns_prefix          = var.rancher_server_cluster_dns_prefix == null ? "${var.environment_prefix}-${var.environment}" : "${var.rancher_server_cluster_dns_prefix}-${var.environment_prefix}-${var.environment}"
  node_resource_group = "rg-${var.environment_prefix}-${var.environment}-worker"

  kubernetes_version = var.rancher_server_cluster_version
  sku_tier           = var.rancher_server_cluster_sku_tier

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  linux_profile {
    admin_username = "admin_${random_string.rancher_server_cluster_admin_username_suffix.result}"
    ssh_key {
      key_data = tls_private_key.rancher_server_cluster_admin_ssh_key.public_key_openssh
    }
  }

  windows_profile {
    admin_username = "admin_${random_string.rancher_server_cluster_admin_username_suffix.result}"
    admin_password = "admin_${random_password.rancher_server_cluster_admin_password.result}"
  }

  default_node_pool {
    name           = "agentpool"
    node_count     = var.rancher_server_cluster_agent_node_count
    vm_size        = var.rancher_server_cluster_agent_node_size
    vnet_subnet_id = var.rancher_server_aks_subnet.id

    orchestrator_version = var.rancher_server_cluster_version

    zones    = var.rancher_server_cluster_azs
    type                  = "VirtualMachineScaleSets"
    enable_node_public_ip = false

    #only_critical_addons_enabled = true
  }

  dynamic "oms_agent" {
    for_each = var.rancher_server_log_analytics_workspace == null ? [] : [1]

    content {
      log_analytics_workspace_id = var.rancher_server_log_analytics_workspace == null ? null : var.rancher_server_log_analytics_workspace.id
    }
  }

  network_profile {
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
    network_plugin     = "azure"
    dns_service_ip     = "10.0.40.10"
    docker_bridge_cidr = "172.17.0.1/16" # 65,536 IPs 172.17.0.0 - 172.17.255.255
    service_cidr       = "10.0.40.0/22"  # 1,024 IPs 10.0.40.0 - 10.0.43.255
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }

  tags = local.tags
}

# Set permissions on the created managed identity
resource "azurerm_role_assignment" "aks" {
  count = var.rancher_server_log_analytics_workspace == null ? 0 : 1

  scope                = azurerm_kubernetes_cluster.rancher_server.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_kubernetes_cluster.rancher_server.oms_agent[0].oms_agent_identity[0].object_id
}

resource "azurerm_role_assignment" "aks_subnet" {
  scope                = var.rancher_server_aks_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.rancher_server.identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_rg" {
  scope                = var.rancher_server_subnet.id
  role_definition_name = "Reader"
  principal_id         = azurerm_kubernetes_cluster.rancher_server.identity[0].principal_id
}

resource "azurerm_role_assignment" "mio" {
  scope                = var.rancher_server_resource_group.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.rancher_server.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "vmc" {
  scope                = var.rancher_server_resource_group.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_kubernetes_cluster.rancher_server.kubelet_identity[0].object_id
}

## Add Kubernetes items as AKV Secrets
resource "azurerm_key_vault_secret" "rancher_server_cluster_host" {
  name         = "${var.environment_prefix}-${var.environment}-cluster-host"
  value        = azurerm_kubernetes_cluster.rancher_server.kube_config.0.host
  key_vault_id = var.rancher_server_devops_key_vault.id

  tags = local.tags
}

resource "azurerm_key_vault_secret" "rancher_server_cluster_client_certificate" {
  name         = "${var.environment_prefix}-${var.environment}-kubernetes-client-certificate"
  value        = azurerm_kubernetes_cluster.rancher_server.kube_config.0.client_certificate
  key_vault_id = var.rancher_server_devops_key_vault.id

  tags = local.tags
}

resource "azurerm_key_vault_secret" "rancher_server_cluster_client_key" {
  name         = "${var.environment_prefix}-${var.environment}-kubernetes-client-key"
  value        = azurerm_kubernetes_cluster.rancher_server.kube_config.0.client_key
  key_vault_id = var.rancher_server_devops_key_vault.id

  tags = local.tags
}

resource "azurerm_key_vault_secret" "rancher_server_cluster_ca_certificate" {
  name         = "${var.environment_prefix}-${var.environment}-kubernetes-cluster-ca-certificate"
  value        = azurerm_kubernetes_cluster.rancher_server.kube_config.0.cluster_ca_certificate
  key_vault_id = var.rancher_server_devops_key_vault.id

  tags = local.tags
}

resource "azurerm_key_vault_secret" "rancher_server_cluster_admin_username" {
  name         = "${var.environment_prefix}-${var.environment}-kubernetes-admin-username"
  value        = "admin_${random_string.rancher_server_cluster_admin_username_suffix.result}"
  key_vault_id = var.rancher_server_devops_key_vault.id

  tags = local.tags
}

resource "azurerm_key_vault_secret" "rancher_server_cluster_admin_password" {
  name         = "${var.environment_prefix}-${var.environment}-kubernetes-admin-password"
  value        = "admin_${random_password.rancher_server_cluster_admin_password.result}"
  key_vault_id = var.rancher_server_devops_key_vault.id

  tags = local.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "rancher_server_cluster_node_pool" {
  for_each = var.rancher_server_user_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.rancher_server.id
  vm_size               = each.value.node_size
  node_count            = each.value.node_count

  zones = var.rancher_server_cluster_azs

  orchestrator_version = var.rancher_server_cluster_version

  vnet_subnet_id  = var.rancher_server_aks_subnet.id
  os_type         = each.value.os_type
  os_disk_size_gb = each.value.os_disk_size_gb

  node_labels = {
    "rancher_server_layer" = each.value.layer_name
  }

  node_taints = each.value.node_taints

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }

  tags = local.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "rancher_server_cluster_spot_node_pool" {
  for_each = var.rancher_server_spot_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.rancher_server.id
  vm_size               = each.value.node_size
  node_count            = each.value.node_count

  zones = var.rancher_server_cluster_azs

  orchestrator_version = var.rancher_server_cluster_version
  
  priority             = "Spot"
  eviction_policy      = "Delete"
  spot_max_price       = each.value.spot_max_price

  vnet_subnet_id = var.rancher_server_aks_subnet.id

  os_type         = each.value.os_type
  os_disk_size_gb = each.value.os_disk_size_gb

  node_labels = {
    # This label must be present on spot pools
    "kubernetes.azure.com/scalesetpriority" = "spot"
    "rancher_server_layer" = each.value.layer_name
  }

  node_taints = setunion(each.value.node_taints, [
    # This taint must be present on spot pools
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ])

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }

  tags = local.tags
}

# Retrieve the resource group that holds the nodes
data "azurerm_resource_group" "rancher_server_worker" {
  name = azurerm_kubernetes_cluster.rancher_server.node_resource_group

  depends_on = [azurerm_kubernetes_cluster.rancher_server]
}

locals {
  first_outbound_ip_segments = split("/", tolist(azurerm_kubernetes_cluster.rancher_server.network_profile[0].load_balancer_profile[0].effective_outbound_ips)[0])
}

data "azurerm_public_ip" "rancher_server_cluster_outbound_ip" {
  name                = local.first_outbound_ip_segments[length(local.first_outbound_ip_segments) - 1]
  resource_group_name = azurerm_kubernetes_cluster.rancher_server.node_resource_group
}