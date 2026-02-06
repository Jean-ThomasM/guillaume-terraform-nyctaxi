variable "resource_group_name" {
    type = string
}

variable "location" {
    type = string   
}

variable "cosmosdb_cluster_name" {
    type = string
}

variable "admin_username" {
    type = string
}

variable "admin_password" {
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
    type = list(string)
}
