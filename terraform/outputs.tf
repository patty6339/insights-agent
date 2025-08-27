output "service_url" {
  value = google_cloud_run_v2_service.insight.uri
}

output "ci_deployer_sa_email" {
  value = google_service_account.ci_deployer.email
}

output "wif_provider_name" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}
