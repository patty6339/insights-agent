resource "google_cloud_run_v2_service" "insight" {
  name     = var.service_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL" # Not publicly accessible because we won't bind allUsers.

  template {
    service_account = google_service_account.runtime.email

    containers {
      image = var.image
      ports {
        container_port = 8080
      }
      resources {
        limits = {
          memory = "256Mi"
          cpu    = "1"
        }
      }
      env {
        name  = "APP_ENV"
        value = "prod"
      }
    }
    scaling {
      min_instance_count = 0
      max_instance_count = 5
    }
  }

  depends_on = [
    google_project_service.services,
    google_artifact_registry_repository.docker_repo
  ]
}

# Grant specific principals invoke (optional, keeps service private to these identities)
resource "google_cloud_run_v2_service_iam_member" "invokers" {
  for_each = toset(var.invoker_members)
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.insight.name
  role     = "roles/run.invoker"
  member   = each.value
}
