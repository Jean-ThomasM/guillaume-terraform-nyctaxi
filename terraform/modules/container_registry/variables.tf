# variables.tf module container_registry
variable "acr_sku" {
    type = string
}

variable "resource_group_name" {
    type = string
}

variable "location" {
    type = string   
}

variable "acr_admin_enabled" {
    type = bool
}

variable "acr_name" {
    type = string
}