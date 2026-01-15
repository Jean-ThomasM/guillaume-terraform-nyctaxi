# main.tf racine

module "storage_module" {
    source = "./modules/storage"
    storage_name = "st${var.user_prefix}${var.project_name}${random_string.this.result}"
    resource_group_name = data.azurerm_resource_group.this.name
    location = data.azurerm_resource_group.this.location
    account_replication_type = var.account_replication_type
    account_tier = var.account_tier
    blob_containers_list = var.blob_containers_list

}

module "acr_module" {
    source = "./modules/container_registry"
    acr_name = "acr${var.user_prefix}${var.project_name}${random_string.this.result}"
    resource_group_name = data.azurerm_resource_group.this.name
    location = data.azurerm_resource_group.this.location
    acr_sku = var.acr_sku
    acr_admin_enabled = var.acr_admin_enabled
}

# module "vm_module" {
#     source = "./modules/vm"
#     resource_group_name = var.resource_group_name
#     location = var.location
#     public_key = file("~/.ssh/id_rsa.pub")
# }

# module "webapp_module" {
#     source = "./modules/webapp"
#     webapp_name = "webapp-datacorp-jtmiquelot"
#     resource_group_name = var.resource_group_name
#     location = var.location
# }

data "azurerm_resource_group" "this" {
    name = var.azure_resource_group
}

resource "random_string" "this" {
  length  = 5
  lower   = true
  numeric = true
  special = false
  upper   = false
}
