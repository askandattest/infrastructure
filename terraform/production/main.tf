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

module "network" {
  source = "../modules/network"
  name   = "private-network"
}

module "postgres" {
  source     = "../modules/postgres"
  name       = "production"
  zone       = var.zone
  region     = var.region
  project_id = var.project_id
  network    = module.network.name
}

module "container_registry" {
  source     = "../modules/container_registry"
  admin_user = "nick@neonlaw.com"
  project_id = var.project_id
}

module "kubernetes_cluster" {
  source  = "../modules/google_kubernetes_engine"
  name    = "production"
  region  = var.region
  network = module.network.name
}

provider "kubernetes" {
  load_config_file = false

  host     = module.kubernetes_cluster.host
  username = module.kubernetes_cluster.master_username
  password = module.kubernetes_cluster.master_password

  client_certificate     = base64decode(module.kubernetes_cluster.client_certificate)
  client_key             = base64decode(module.kubernetes_cluster.client_key)
  cluster_ca_certificate = base64decode(module.kubernetes_cluster.cluster_ca_certificate)

}

module "interface_deployment" {
  source    = "../modules/kubernetes_deployment"
  app_name  = "interface"
  image_url = "${module.container_registry.name}/interface:latest"
}

module "interface_service" {
  source    = "../modules/kubernetes_service"
  app_name  = "interface"
  node_port = 30116
}

module "kubernetes_ingress" {
  source      = "../modules/kubernetes_ingress"
  app_name    = "interface"
  domain_name = "www.neonlaw.com"
}
