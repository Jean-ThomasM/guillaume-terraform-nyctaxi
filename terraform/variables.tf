# variables.tf racine

variable "project_name" {
  type = string
}

variable "user_prefix" {
  type = string
}

variable "azure_resource_group" {
    description = "The name of the resource group"
    type        = string
}

variable "environment" {
  type = string
  default = "dev"
}

variable "blob_containers_list" {
  type = list(string)
}

variable "location" {
  type = string
}

# module storage
variable "account_tier" {
    type = string
}

variable "account_replication_type" {
    type = string
}

variable "storage_kind" {
    type = string
}

variable "tags" {
  type = map(string)
}

variable "start_date" {
  type = string
}

variable "end_date" {
  type = string
}

variable "cosmos_db_admin_username" {
  type = string
}

# module container_registry

variable "acr_sku" {
    type = string
}

variable "acr_admin_enabled" {
    type = bool
}

variable "container_image_name" {
  type = string
}

variable "container_image_tag" {
  type = string
}

# cosmos db postgres
variable "cosmosdb_password" {
    type = string
    sensitive = true
}

variable "cosmosdb_storage_mb" {
    type = number
}

variable "cosmosdb_vcore_count" {
    type = number
}

variable "cosmosdb_node_count" {
    type = number
}

variable "cosmosdb_server_edition" {
    type = string
}

variable "cosmosdb_firewall_name" {
    type = string
}

variable "allowed_ips" {
  type    = list(string)
  default = []
}

# module log analytics workspace
variable "log_an_wsp_sku" {
    type = string
}

variable "log_an_wsp_retention" {
    type = number
}

# container apps environment
variable "aca_env_logs_destination" {
    type = string
}

# container apps
variable "aca_cpu" {
    type = number
}

variable "aca_memory" {
    type = string
}


variable "aca_max_replicas" {
    type = number
}

variable "aca_min_replicas" {
    type = number
}

variable "azure_container_name" {
    type = string
}

variable "postgres_db" {
  type = string
  default = "citus"
}

variable "postgres_port" {
  type = number
  default = 5432
}

variable "subscription_id" {
    type = string
}
