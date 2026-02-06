

resource "azurerm_container_app" "this" {
  name                         = var.aca_name
  container_app_environment_id = var.cae_env_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  secret {
    name  = "acr-password"
    value = var.acr_admin_password
  }
  secret {
    name  = "storage-connection"
    value = var.storage_connection_string
  }
  secret {
    name  = "postgres-password"
    value = var.postgres_password
  }

  registry {
    server               = var.acr_login_server
    username             = var.acr_admin_username
    password_secret_name = "acr-password"
  }

  template {
    container {
      name   = var.aca_cont_name
      image  = var.aca_image
      cpu    = var.aca_cpu
      memory = var.aca_memory

      env {
        name        = "AZURE_STORAGE_CONNECTION_STRING"
        secret_name = "storage-connection"
      }
      env {
        name  = "AZURE_CONTAINER_NAME"
        value = var.azure_container_name
      }
      env {
        name  = "POSTGRES_HOST"
        value = var.postgres_host
      }
      env {
        name  = "POSTGRES_PORT"
        value = tostring(var.postgres_port)
      }
      env {
        name  = "POSTGRES_DB"
        value = var.postgres_db
      }
      env {
        name  = "POSTGRES_USER"
        value = var.postgres_user
      }
      env {
        name        = "POSTGRES_PASSWORD"
        secret_name = "postgres-password"
      }
      env {
        name  = "POSTGRES_SSL_MODE"
        value = var.postgres_ssl_mode
      }
      env {
        name  = "START_DATE"
        value = var.start_date
      }
      env {
        name  = "END_DATE"
        value = var.end_date
      }
    }
  }
}
 
