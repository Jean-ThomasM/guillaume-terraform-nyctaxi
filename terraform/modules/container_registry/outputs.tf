# outputs.tf module container_registry

output "container_registry_name" {
  value = azurerm_container_registry.this.name
}

output "acr_admin_username" {
  value = azurerm_container_registry.this.admin_username
}

output "acr_admin_password" {
  value = azurerm_container_registry.this.admin_password
  sensitive = true
}

output "container_registry_login_server" {
  value = azurerm_container_registry.this.login_server
}