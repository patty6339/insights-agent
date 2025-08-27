resource "google_artifact_registry_repository" "docker_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.ar_repo
  description   = "Containers for Insight-Agent"
  format        = "DOCKER"

  depends_on = [google_project_service.services]
}
