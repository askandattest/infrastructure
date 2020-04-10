output "name" {
  value       = google_compute_network.private_network.self_link
  description = "The URI of the created private network on GCP"
}
