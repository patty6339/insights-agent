# Runtime SA for Cloud Run
resource "google_service_account" "runtime" {
  account_id   = "insight-agent-run"
  display_name = "Insight-Agent Cloud Run runtime"
}

# CI deployer SA (used via WIF)
resource "google_service_account" "ci_deployer" {
  account_id   = "insight-agent-ci"
  display_name = "CI/CD deployer (GitHub OIDC)"
}

# Grant CI SA minimal perms to build/deploy
resource "google_project_iam_member" "ci_roles" {
  for_each = toset([
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/artifactregistry.writer",
    "roles/storage.admin"
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.ci_deployer.email}"
}
