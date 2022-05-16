# Create a number of random strings to make the tfstate storage account resources unique and harder to determine externally.
resource "random_string" "tfstate_storage_account_nonce" {
  length  = 24
  upper   = false
  lower   = true
  number  = true
  special = false
}

# Create a number of random strings to make the rancher server devops resources unique and harder to determine externally.
resource "random_string" "devops_storage_nonce" {
  length  = 24
  upper   = false
  lower   = true
  number  = true
  special = false
}

resource "random_string" "key_vault_nonce" {
  length  = 24
  upper   = false
  lower   = true
  number  = true
  special = false
}

locals {
  unique_tfstate_storage_account_nonce = substr(random_string.tfstate_storage_account_nonce.result, 0, 24 - (length(var.rancher_server_devops_tfstate_storage_account_name)))
  unique_assets_storage_account_nonce  = substr(random_string.devops_storage_nonce.result, 0, 24 - (length(var.rancher_server_devops_assets_storage_account_name)))
  unique_key_vault_nonce               = substr(random_string.key_vault_nonce.result, 0, 24 - (length(var.rancher_server_devops_key_vault_name) + 11))
  tags                                 = merge(var.tags, { Creator = "terraform-baristalabs-rancher-server", Environment = "rancher_server_devops" })
}

## Create a resource group to hold Rancher Server DevOps resources.
resource "azurerm_resource_group" "rancher_server_devops" {
  name     = var.rancher_server_devops_resource_group_name
  location = var.az_region

  tags = local.tags
}

## Create a storage account to hold Terraform State.
resource "azurerm_storage_account" "rancher_server_devops_tfstate" {
  name                     = "${var.rancher_server_devops_tfstate_storage_account_name}${local.unique_tfstate_storage_account_nonce}"
  resource_group_name      = azurerm_resource_group.rancher_server_devops.name
  location                 = azurerm_resource_group.rancher_server_devops.location
  account_tier             = "Standard"
  account_replication_type = var.rancher_server_devops_tfstate_storage_account_replication_type
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = local.tags
}

## Create a storage container to hold Terraform State.
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.rancher_server_devops_tfstate.name
  container_access_type = "private"
}

## Create a storage account to hold DevOps assets.
resource "azurerm_storage_account" "rancher_server_devops_assets" {
  name                     = "${var.rancher_server_devops_assets_storage_account_name}${local.unique_assets_storage_account_nonce}"
  resource_group_name      = azurerm_resource_group.rancher_server_devops.name
  location                 = azurerm_resource_group.rancher_server_devops.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = local.tags
}

resource "azurerm_storage_container" "rancher_server_devops_assets" {
  name                  = "assets"
  storage_account_name  = azurerm_storage_account.rancher_server_devops_assets.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "rancher_server_assets" {
  for_each = var.rancher_server_devops_assets_path == null ? toset([]) : fileset(abspath(var.rancher_server_devops_assets_path), var.rancher_server_devops_assets_glob)

  name                   = each.value
  storage_account_name   = azurerm_storage_account.rancher_server_devops_assets.name
  storage_container_name = azurerm_storage_container.rancher_server_devops_assets.name
  type                   = "Block"
  source                 = "${abspath(var.rancher_server_devops_assets_path)}/${each.value}"
}

resource "azurerm_storage_container" "rancher_server_build_artifacts" {
  name                  = "build-artifacts"
  storage_account_name  = azurerm_storage_account.rancher_server_devops_assets.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "rancher_server_modules" {
  name                  = "modules"
  storage_account_name  = azurerm_storage_account.rancher_server_devops_assets.name
  container_access_type = "private"
}

# Create a managed identity
resource "azurerm_user_assigned_identity" "rancher_server_devops" {
  resource_group_name = azurerm_resource_group.rancher_server_devops.name
  location            = azurerm_resource_group.rancher_server_devops.location

  name = var.rancher_server_devops_managed_identity_name

  tags = local.tags
}

# Create a common Key Vault
resource "azurerm_key_vault" "rancher_server_devops" {
  name                = "kv-${var.rancher_server_devops_key_vault_name}-${local.unique_key_vault_nonce}-devops"
  location            = var.az_region
  resource_group_name = azurerm_resource_group.rancher_server_devops.name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = var.rancher_server_devops_key_vault_soft_delete_retention_days
  purge_protection_enabled   = var.rancher_server_devops_key_vault_purge_protection_enabled

  network_acls {
    default_action = "Allow"
    bypass         = "None"
  }

  tags = local.tags
}

# Grant full permissions to the indicated principal
resource "azurerm_key_vault_access_policy" "rancher_server_devops_service_principal_policy" {
  count = var.rancher_server_devops_service_principal_object_id == null ? 0 : 1

  key_vault_id = azurerm_key_vault.rancher_server_devops.id
  tenant_id    = var.tenant_id
  object_id    = var.rancher_server_devops_service_principal_object_id

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]

  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Purge",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update",
  ]

  storage_permissions = [
    "Backup",
    "Delete",
    "DeleteSAS",
    "Get",
    "GetSAS",
    "List",
    "ListSAS",
    "Purge",
    "Recover",
    "RegenerateKey",
    "Restore",
    "Set",
    "SetSAS",
    "Update"
  ]
}

# Grant read rights to the Rancher Server DevOps Managed Identity
resource "azurerm_key_vault_access_policy" "rancher_server_devops_managed_identity" {
  key_vault_id = azurerm_key_vault.rancher_server_devops.id
  tenant_id    = var.tenant_id
  object_id    = azurerm_user_assigned_identity.rancher_server_devops.principal_id

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
  ]

  certificate_permissions = [
    "Get",
  ]

  storage_permissions = [
    "Get",
  ]
}

# TODO: Evaluate this as a possible pattern - it also opens up a can of worms.
# // Create a virtual network that acts as a hub vnet
# resource "azurerm_virtual_network" "rancher_server_devops_vnet" {
#   name                = "vnet-blrs-devops"
#   address_space       = [var.rancher_server_environment_vnet_cidr]
#   location            = azurerm_resource_group.rancher_server_environment.location
#   resource_group_name = azurerm_resource_group.rancher_server_environment.name

#   tags = local.tags
# }

resource "azurerm_key_vault_secret" "rancher_server_devops_assets_storage_account_connection_string" {
  count = var.rancher_server_devops_service_principal_object_id == null ? 0 : 1

  name         = "rancher-server-devops-assets-storage-blob-connectionstring"
  value        = azurerm_storage_account.rancher_server_devops_assets.primary_blob_connection_string
  key_vault_id = azurerm_key_vault.rancher_server_devops.id

  tags = local.tags

  depends_on = [azurerm_key_vault_access_policy.rancher_server_devops_service_principal_policy]
}

resource "azurerm_key_vault_secret" "rancher_server_devops_assets_storage_account_url" {
  count = var.rancher_server_devops_service_principal_object_id == null ? 0 : 1

  name         = "rancher-server-devops-assets-storage-account-url"
  value        = azurerm_storage_account.rancher_server_devops_assets.primary_blob_endpoint
  key_vault_id = azurerm_key_vault.rancher_server_devops.id

  tags = local.tags

  depends_on = [azurerm_key_vault_access_policy.rancher_server_devops_service_principal_policy]
}

data "azurerm_storage_account_blob_container_sas" "rancher_server_devops_assets_sas" {
  connection_string = azurerm_storage_account.rancher_server_devops_assets.primary_connection_string
  container_name    = azurerm_storage_container.rancher_server_devops_assets.name
  https_only        = true

  start  = formatdate("YYYY-MM-DD", timestamp())
  expiry = formatdate("YYYY-MM-DD", timeadd(timestamp(), "17520h"))

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = true
  }
}

resource "azurerm_key_vault_secret" "rancher_server_devops_assets_sas_token" {
  count = var.rancher_server_devops_service_principal_object_id == null ? 0 : 1

  name         = "rancher-server-devops-assets-sas-token"
  value        = data.azurerm_storage_account_blob_container_sas.rancher_server_devops_assets_sas.sas
  key_vault_id = azurerm_key_vault.rancher_server_devops.id

  tags = local.tags

  depends_on = [azurerm_key_vault_access_policy.rancher_server_devops_service_principal_policy]
}

resource "azurerm_management_lock" "rancher_server_devops_resource_group_lock" {
  count = var.rancher_server_devops_enable_tfstate_delete_lock == true ? 1 : 0

  name       = "rancher-server-devops"
  scope      = azurerm_storage_account.rancher_server_devops_tfstate.id
  lock_level = "CanNotDelete"
  notes      = "These resources support Ranchser Server DevOps"
  depends_on = [
    azurerm_storage_account.rancher_server_devops_tfstate,
    azurerm_storage_account.rancher_server_devops_assets,
    azurerm_user_assigned_identity.rancher_server_devops,
    azurerm_key_vault.rancher_server_devops,
  ]
}