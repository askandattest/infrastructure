resource "google_compute_managed_ssl_certificate" "default" {
  provider = google-beta

  name = var.app_name

  managed {
    domains = [var.domain_name]
  }
}

resource "kubernetes_ingress" "default" {
  metadata {
    name = "${var.app_name}-ingress"

    annotations = {
      "ingress.gcp.kubernetes.io/pre-shared-cert" = google_compute_managed_ssl_certificate.default.name
    }
  }

  spec {
    backend {
      service_name = var.app_name
      service_port = 80
    }
  }
}
