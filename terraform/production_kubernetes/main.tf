data "terraform_remote_state" "production_gcp" {
  backend = "remote"

  config = {
    hostname     = "app.terraform.io"
    organization = "ask-and-attest"
    workspaces = {
      name = "production-gcp"
    }
  }
}

provider "kubernetes" {
  load_config_file = false

  host     = data.terraform_remote_state.production_gcp.outputs.gke_host
  username = data.terraform_remote_state.production_gcp.outputs.gke_username
  password = data.terraform_remote_state.production_gcp.outputs.gke_password

  client_certificate     = base64decode(data.terraform_remote_state.production_gcp.outputs.gke_client_certificate)
  client_key             = base64decode(data.terraform_remote_state.production_gcp.outputs.gke_client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.production_gcp.outputs.gke_cluster_ca_certificate)
}

module "interface_deployment" {
  source    = "../modules/interface_deployment"
  app_name  = "interface"
  image_url = "${data.terraform_remote_state.production_gcp.outputs.container_registry}/interface:latest"
}

module "interface_service" {
  source      = "../modules/kubernetes_service"
  app_name    = "interface"
  target_port = 80
}

module "kubernetes_ingress" {
  source      = "../modules/kubernetes_ingress"
  app_name    = "interface"
  domain_name = "www.askandattest.com"
}

module "sql_proxy_kubernetes_secret" {
  source       = "../modules/kubernetes_secret"
  secret_name  = "sql-proxy-service-account-token"
  secret_value = var.sql_proxy_gcp_credentials
}

module "third_party_saas_kubernetes_secret" {
  source              = "../modules/third_party_saas_kubernetes_secret"
  secret_name         = "third-party-saas"
  auth0_client_id     = var.auth0_client_id
  auth0_client_secret = var.auth0_client_secret
}

module "api_deployment" {
  source                       = "../modules/logic_deployment"
  app_name                     = "api"
  image_url                    = "${data.terraform_remote_state.production_gcp.outputs.container_registry}/logic:latest"
  command                      = "./app.sh"
  database_name                = "logic"
  project_id                   = data.terraform_remote_state.production_gcp.outputs.project_id
  region                       = data.terraform_remote_state.production_gcp.outputs.region
  sql_proxy_secret_name        = module.sql_proxy_kubernetes_secret.name
  third_party_saas_secret_name = module.third_party_saas_kubernetes_secret.name
  master_database_password     = var.master_database_password
}

module "api_service" {
  source      = "../modules/kubernetes_service"
  app_name    = "api"
  target_port = 3000
}

module "api_ingress" {
  source      = "../modules/kubernetes_ingress"
  app_name    = "api"
  domain_name = "api.askandattest.com"
}