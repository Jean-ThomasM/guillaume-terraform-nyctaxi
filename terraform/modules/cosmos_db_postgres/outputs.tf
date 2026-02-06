# outputs.tf module cosmos_db_postgres

output "cosmosdb_host" {
    description = "Host Cosmos DB"
    value       = azurerm_cosmosdb_postgresql_cluster.this.servers[0].fqdn
}

output "cosmosdb_admin_username" {
    value = var.admin_username
}