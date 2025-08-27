# Optional: Create a project if requested
resource "google_project" "project" {
  count           = var.create_project ? 1 : 0
  project_id      = var.project_id
  name            = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
}

data "google_project" "current" {
  project_id = var.project_id
}
