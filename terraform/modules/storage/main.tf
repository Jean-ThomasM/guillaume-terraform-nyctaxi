# main.tf module storage

resource "azurerm_storage_account" "this" {
    name = var.storage_name
    resource_group_name = var.resource_group_name
    location = var.location
    account_tier = var.account_tier
    account_replication_type = var.account_replication_type
}

resource "azurerm_storage_container" "this" {
    for_each = toset(var.blob_containers_list)
    name = each.key
    storage_account_name = azurerm_storage_account.this.name
    container_access_type = "private"
  
}

