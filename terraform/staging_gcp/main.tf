provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  credentials = var.gcp_credentials
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  credentials = var.gcp_credentials
}

module "networking_service_connection" {
  source     = "../modules/networking_service_connection"
  project_id = var.project_id
}

module "postgres" {
  source        = "../modules/postgres"
  zone          = var.zone
  region        = var.region
  project_id    = var.project_id
  database_name = "ask-and-attest-staging"
}

module "container_registry" {
  source     = "../modules/container_registry"
  admin_user = "charlie@askandattest.com"
  project_id = var.project_id
}

module "kubernetes_cluster" {
  source     = "../modules/google_container_cluster"
  region     = var.region
  project_id = var.project_id
}

module "api-ssl-certificate" {
  source           = "../modules/ssl_certificate"
  certificate_name = "api"
  domain_name      = "api.askandattest.net"
}

module "www-ssl-certificate" {
  source           = "../modules/ssl_certificate"
  certificate_name = "interface"
  domain_name      = "www.askandattest.net"
}
