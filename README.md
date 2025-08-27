# Insight-Agent (MVP)

A tiny FastAPI service with one endpoint `POST /analyze` that counts words and characters.
Deployed to **Cloud Run**, images stored in **Artifact Registry**, all infra in **Terraform**, and CI/CD via **GitHub Actions** using **Workload Identity Federation** (no SA keys).

## Architecture Overview

[GitHub Actions] --OIDC--> [GCP WIF] -> [CI Service Account]
| |
|---- docker build/push ----------> Artifact Registry
|---- terraform apply ------------> Cloud Run Service
^
(Authenticated clients) --- ID Token ----- |


- **Cloud Run**: serverless container runtime for the API.
- **Artifact Registry**: stores the built Docker image.
- **IAM & WIF**: secure CI auth without keys; Cloud Run is **not public** (no `allUsers` invoker).
- **Terraform**: provisions APIs, AR repo, SAs, WIF, Cloud Run.

## Design Decisions

- **FastAPI** for quick JSON API, automatic validation & OpenAPI.
- **Cloud Run** chosen for speed, scale-to-zero, low ops overhead.
- **Security**: 
  - No `allUsers` binding → Service is **not publicly accessible**.
  - Requests must be **authenticated** (IAM `run.invoker`).
  - GitHub CI uses **OIDC + WIF**; no long-lived SA keys.
  - Container runs as **non-root**, minimal base image.
- **Pipeline**: push to `main` → lint/test → build & push → terraform apply with new image digest tag.

## Setup & Deployment (Step-by-step)

1. **Prereqs**
   - GCP project with billing enabled; `gcloud` & Terraform installed.

2. **Configure variables**
   - Copy `terraform/terraform.tfvars.example` → `terraform/terraform.tfvars`
   - Fill `project_id`, `region`, `github_owner`, `github_repo`.

3. **Bootstrap Terraform locally (one-time)**
   ```bash
   cd terraform
   terraform init
   terraform apply -var-file="terraform.tfvars"
    ```

## Local Dev

make test
make build
make run
# curl localhost:8080/analyze -d '{"text":"hello world"}' -H 'content-type: application/json'

@@Extending Security (optional)

Restrict invokers by setting invoker_members to specific SAs:

invoker_members = [
  "serviceAccount:consumer@your-project.iam.gserviceaccount.com"
]


- For internal-only network access, place Cloud Run behind a regional internal HTTP(S) load balancer with a Serverless NEG (adds LB resources, certs, and subnet). The current setup uses IAM auth to ensure the service is not public.
