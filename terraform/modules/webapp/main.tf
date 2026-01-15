resource "azurerm_service_plan" "plan" {
    name = "datacorp-plan"
    resource_group_name = var.resource_group_name
    location = var.location
    os_type = "Linux"
    sku_name = "F1"
}

resource "azurerm_linux_web_app" "app" {
    name = var.webapp_name
    resource_group_name = var.resource_group_name
    location = var.location
    service_plan_id = azurerm_service_plan.plan.id
    site_config {
        always_on = false
    }
}