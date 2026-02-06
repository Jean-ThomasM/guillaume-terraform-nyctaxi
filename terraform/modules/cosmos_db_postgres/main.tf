resource "azurerm_cosmosdb_postgresql_cluster" "this" {
  name                            = var.cosmosdb_cluster_name
  resource_group_name = var.resource_group_name
  location = var.location
  administrator_login_password    = var.admin_password
  coordinator_storage_quota_in_mb = var.cosmosdb_storage_mb
  coordinator_vcore_count         = var.cosmosdb_vcore_count
  node_count                      = var.cosmosdb_node_count
  coordinator_server_edition = var.cosmosdb_server_edition
}

resource "azurerm_cosmosdb_postgresql_firewall_rule" "allowed" {
  for_each         = toset(var.allowed_ips)
  name             = "${var.cosmosdb_firewall_name}-${replace(each.value, ".", "-")}"
  cluster_id       = azurerm_cosmosdb_postgresql_cluster.this.id
  start_ip_address = each.value
  end_ip_address   = each.value
}
