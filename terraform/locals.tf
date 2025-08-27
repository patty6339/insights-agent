locals {
  repo_image_name = "insight-agent"
  location_repo   = "${var.region}-docker.pkg.dev/${var.project_id}/${var.ar_repo}/${local.repo_image_name}"
}
