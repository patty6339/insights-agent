variable "project_id" {
  type        = string
  description = "Existing GCP project id. If create_project=true, this will be the desired id."
}

variable "region" {
  type        = string
  description = "Region for Cloud Run & Artifact Registry (e.g., us-central1)."
  default     = "us-central1"
}

variable "ar_repo" {
  type        = string
  description = "Artifact Registry repo id."
  default     = "insight-agent"
}

variable "service_name" {
  type        = string
  description = "Cloud Run service name."
  default     = "insight-agent"
}

variable "image" {
  type        = string
  description = "Fully qualified container image (passed by CI)."
  default     = "us-central1-docker.pkg.dev/placeholder/insight-agent/insight-agent:dev"
}

variable "invoker_members" {
  description = "Optional list of IAM members allowed to invoke (e.g., serviceAccount:xyz). Leave empty to keep private to deployer."
  type        = list(string)
  default     = []
}

variable "create_project" {
  type        = bool
  description = "If true, create a new project under org & billing."
  default     = false
}

variable "org_id" {
  type        = string
  description = "Organization ID (required if create_project=true)."
  default     = null
}

variable "billing_account" {
  type        = string
  description = "Billing account ID (required if create_project=true)."
  default     = null
}

# GitHub OIDC/WIF
variable "github_owner" {
  type        = string
  description = "GitHub org/user name (for OIDC)."
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name (for OIDC)."
}
