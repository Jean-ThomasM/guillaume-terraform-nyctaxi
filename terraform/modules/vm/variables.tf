variable "resource_group_name" {
  description = "Nom du groupe de ressources"
  type        = string
}

variable "location" {
  description = "Localisation Azure"
  type        = string
}

variable "public_key" {
    type = string
    description = "public ssh key"
}

