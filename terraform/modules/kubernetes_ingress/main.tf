resource "kubernetes_ingress" "primary" {
  metadata {
    name = "${var.app_name}-ingress"

    annotations = {
      "ingress.gcp.kubernetes.io/pre-shared-cert" = var.app_name
    }
  }

  spec {
    backend {
      service_name = var.app_name
      service_port = 80
    }
  }
}
