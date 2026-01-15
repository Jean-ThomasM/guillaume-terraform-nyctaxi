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

variable "account_tier" {
    type = string
}

variable "account_replication_type" {
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

variable "container_apps_cpu" {
  type = number
}

variable "container_apps_memory" {
  type = string
}

variable "container_apps_min_replicas" {
  type = number
}

variable "container_apps_max_replicas" {
  type = number
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