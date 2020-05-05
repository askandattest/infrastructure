resource "google_sql_database_instance" "postgres" {
  name             = var.name
  region           = var.region
  database_version = var.postgres_version

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      require_ssl     = false
      private_network = var.network
    }
  }
}
