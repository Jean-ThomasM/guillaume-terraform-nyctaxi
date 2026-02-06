variable "resource_group_name" {
    type = string
}

variable "aca_name" {
    type = string
}

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

variable "cae_env_id" {
    type = string
}

variable "aca_image" {
    type = string
}

variable "aca_cont_name" {
    type = string
}

variable "acr_login_server" {
    type = string
}

variable "acr_admin_username" {
    type = string
}

variable "acr_admin_password" {
    type = string
    sensitive = true
}

variable "storage_connection_string" {
    type = string
    sensitive = true
}

variable "azure_container_name" {
    type = string
}

variable "postgres_host" {
    type = string
}

variable "postgres_user" {
    type = string
}

variable "postgres_password" {
    type = string
    sensitive = true
}

variable "postgres_db" {
    type = string
}

variable "postgres_port" {
    type = number
}

variable "postgres_ssl_mode" {
    type = string
}

variable "start_date" {
    type = string
}

variable "end_date" {
    type = string
}