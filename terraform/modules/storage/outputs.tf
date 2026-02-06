# outputs.tf module storage

output "storage_connection_string" {
    value = azurerm_storage_account.this.primary_connection_string
    sensitive = true
}