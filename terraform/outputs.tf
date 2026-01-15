# outputs.tf racine

output "container_registry_name" {
  value = module.acr_module.container_registry_name
}

output "acr_admin_username" {
  value = module.acr_module.acr_admin_username
}

output "acr_admin_password" {
  value = module.acr_module.acr_admin_password
  sensitive = true
}

output "container_registry_login_server" {
  value = module.acr_module.container_registry_login_server
}