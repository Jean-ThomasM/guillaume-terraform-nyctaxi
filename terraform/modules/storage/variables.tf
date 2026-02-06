# variables.tf module storage

variable  "storage_name" {
    type = string
}

variable "resource_group_name" {
    type = string
}

variable "location" {
    type = string   
}

variable "blob_containers_list" {
  type = list(string)
}

variable "account_tier" {
    type = string
}

variable "account_replication_type" {
    type = string
}

variable "storage_kind" {
    type = string
}