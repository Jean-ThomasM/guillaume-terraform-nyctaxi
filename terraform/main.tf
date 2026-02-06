# main.tf racine

module "storage_module" {
    source = "./modules/storage"
    storage_name = "st${var.user_prefix}${var.project_name}${random_string.this.result}"
    resource_group_name = data.azurerm_resource_group.this.name
    location = data.azurerm_resource_group.this.location
    account_replication_type = var.account_replication_type
    account_tier = var.account_tier
    blob_containers_list = var.blob_containers_list
    storage_kind = var.storage_kind

}

module "acr_module" {
    source = "./modules/container_registry"
    acr_name = "acr${var.user_prefix}${var.project_name}${random_string.this.result}"
    resource_group_name = data.azurerm_resource_group.this.name
    location = data.azurerm_resource_group.this.location
    acr_sku = var.acr_sku
    acr_admin_enabled = var.acr_admin_enabled
}

module "cosmosdb_postgre_module" {
    source = "./modules/cosmos_db_postgres"
    resource_group_name = data.azurerm_resource_group.this.name
    location = data.azurerm_resource_group.this.location
    cosmosdb_cluster_name = "cdb${var.user_prefix}${var.project_name}${random_string.this.result}"
    admin_username = var.cosmos_db_admin_username
    admin_password = var.cosmosdb_password
    cosmosdb_storage_mb = var.cosmosdb_storage_mb
    cosmosdb_vcore_count = var.cosmosdb_vcore_count
    cosmosdb_node_count = var.cosmosdb_node_count
    cosmosdb_server_edition = var.cosmosdb_server_edition
    cosmosdb_firewall_name = var.cosmosdb_firewall_name
    allowed_ips = concat([module.container_apps_environment.static_ip_address], var.allowed_ips)
}


module "log_analytics_workspace" {
  source = "./modules/log_analytics_workspace"
  log_an_wsp_name = "logwsp${var.user_prefix}${var.project_name}${random_string.this.result}"
  resource_group_name = data.azurerm_resource_group.this.name
  location = data.azurerm_resource_group.this.location
  log_an_wsp_retention = var.log_an_wsp_retention
  log_an_wsp_sku = var.log_an_wsp_sku
}

module "container_apps_environment" {
    source = "./modules/container_apps_environment"
    resource_group_name = data.azurerm_resource_group.this.name
    location = data.azurerm_resource_group.this.location
    aca_env_name = "caenv${var.user_prefix}${var.project_name}"
    aca_env_logs_destination = var.aca_env_logs_destination
    log_analytics_workspace_id = module.log_analytics_workspace.workspace_id
}
module "container_apps" {
    source = "./modules/container_apps"
    resource_group_name = data.azurerm_resource_group.this.name
    aca_name = "ca-${var.project_name}-pipeline-${var.environment}"
    cae_env_id = module.container_apps_environment.azurerm_container_app_environment_id
    aca_image = "${module.acr_module.container_registry_login_server}/${var.container_image_name}:${var.container_image_tag}"
    aca_cpu = var.aca_cpu
    aca_memory = var.aca_memory
    aca_max_replicas = var.aca_max_replicas
    aca_min_replicas = var.aca_min_replicas
    aca_cont_name = "cont-${var.project_name}-pipeline"
    azure_container_name = var.azure_container_name
    postgres_host = module.cosmosdb_postgre_module.cosmosdb_host 
    postgres_user = module.cosmosdb_postgre_module.cosmosdb_admin_username
    postgres_password = var.cosmosdb_password
    postgres_db = var.postgres_db
    postgres_port = var.postgres_port
    postgres_ssl_mode = "require"
    storage_connection_string = module.storage_module.storage_connection_string
    acr_login_server = module.acr_module.container_registry_login_server
    acr_admin_username = module.acr_module.acr_admin_username
    acr_admin_password = module.acr_module.acr_admin_password
    start_date = var.start_date
    end_date = var.end_date
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
