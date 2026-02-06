resource "azurerm_log_analytics_workspace" "this" {
  name                = var.log_an_wsp_name
  resource_group_name = var.resource_group_name
  location = var.location
  sku                 = var.log_an_wsp_sku
  retention_in_days   = var.log_an_wsp_retention
}