resource "kubernetes_deployment" "logic" {
  metadata {
    name = var.app_name
    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        volume {
          name = var.sql_proxy_secret_name

          secret {
            secret_name = var.sql_proxy_secret_name
          }
        }

        volume {
          name = var.third_party_saas_secret_name

          secret {
            secret_name = var.third_party_saas_secret_name
          }
        }

        container {
          image = var.image_url
          name  = var.app_name
          env {
            name  = "DATABASE_URL"
            value = "postgres://postgres:${var.master_database_password}@127.0.0.1:5432/ask-and-attest"
          }
          command = [var.command]

          volume_mount {
            name       = var.third_party_saas_secret_name
            read_only  = true
            mount_path = "/secrets/"
          }
        }

        container {
          name    = "cloud-sql-proxy"
          image   = "gcr.io/cloudsql-docker/gce-proxy:1.17"
          command = ["/cloud_sql_proxy", "-ip_address_types=PRIVATE", "-instances=${var.project_id}:${var.region}:${var.database_name}=tcp:5432", "-credential_file=/credentials/credentials.json"]

          volume_mount {
            name       = var.sql_proxy_secret_name
            read_only  = true
            mount_path = "/credentials/"
          }
        }
      }
    }
  }
}
