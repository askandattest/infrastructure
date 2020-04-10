output "port" {
  value = kubernetes_service.primary.spec[0].port[0].node_port
}
