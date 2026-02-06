# outputs.tf module container_apps_environment

output "azurerm_container_app_environment_id" {
  description = "L'ID unique de l'environnement pour lier les apps."
  value       = azurerm_container_app_environment.this.id
}

output "static_ip_address" {
  value = azurerm_container_app_environment.this.static_ip_address
}