# Pat-insights (MVP)

A secure, serverless FastAPI microservice that analyzes text input, deployed on Google Cloud Platform with Infrastructure as Code and automated CI/CD.

## Architecture Overview

```
┌─────────────────┐    OIDC     ┌─────────────────┐    Impersonate    ┌─────────────────┐
│  GitHub Actions │ ──────────► │ Workload Identity│ ─────────────────► │ Service Account │
│     (CI/CD)     │             │   Federation     │                   │  (ci-deployer)  │
└─────────────────┘             └─────────────────┘                   └─────────────────┘
         │                                                                       │
         │ Build & Push                                                          │ Deploy
         ▼                                                                       ▼
┌─────────────────┐             ┌─────────────────┐    Terraform     ┌─────────────────┐
│ Artifact Registry│             │   Terraform     │ ─────────────────► │   Cloud Run     │
│ (Docker Images) │             │ (Infrastructure)│                   │   (API Service) │
└─────────────────┘             └─────────────────┘                   └─────────────────┘
                                                                               │
                                                                               │ Authenticated
                                                                               │ Requests Only
                                                                               ▼
                                                                    ┌─────────────────┐
                                                                    │   API Clients   │
                                                                    │ (with ID Token) │
                                                                    └─────────────────┘
```

### GCP Services Used:
- **Cloud Run**: Serverless container platform hosting the FastAPI application
- **Artifact Registry**: Secure Docker image storage and management
- **IAM & Workload Identity Federation**: Keyless authentication from GitHub to GCP
- **Cloud APIs**: Enabled programmatically via Terraform

## Design Decisions

### Why Cloud Run?
- **Serverless**: Scale-to-zero when idle, pay only for actual usage
- **Fully managed**: No infrastructure management overhead
- **Container-native**: Direct Docker deployment with automatic HTTPS
- **Built-in security**: IAM integration, private by default

### Security Architecture
- **No public access**: Service requires IAM authentication (no `allUsers` binding)
- **Keyless CI/CD**: Uses OIDC + Workload Identity Federation instead of service account keys
- **Least privilege**: Dedicated service account with minimal required permissions
- **Container security**: Non-root user, minimal base image, security scanning

### CI/CD Pipeline Design
1. **Trigger**: Push to `main` branch
2. **Test**: Lint with Ruff, run pytest
3. **Build**: Create Docker image tagged with commit SHA
4. **Deploy**: Push to Artifact Registry, update Cloud Run via Terraform
5. **Verify**: Confirm deployment success

### Technology Choices
- **FastAPI**: Modern Python framework with automatic OpenAPI docs and validation
- **Terraform**: Infrastructure as Code for reproducible, version-controlled deployments
- **GitHub Actions**: Integrated CI/CD with excellent GCP authentication support
- **Docker**: Containerization for consistent environments and easy deployment

## Setup and Deployment Instructions

### Prerequisites
- Google Cloud Platform account with billing enabled
- GitHub repository
- Local development tools: `gcloud`, `terraform`, `docker`

### Step 1: GCP Project Setup

1. **Create GCP Project**:
   ```bash
   gcloud projects create YOUR-PROJECT-ID
   gcloud config set project YOUR-PROJECT-ID
   ```

2. **Enable billing** via GCP Console

3. **Authenticate locally**:
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

### Step 2: Configure Terraform Variables

1. **Copy configuration template**:
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```

2. **Edit `terraform/terraform.tfvars`**:
   ```hcl
   project_id    = "your-actual-project-id"
   region        = "us-central1"
   github_owner  = "your-github-username"
   github_repo   = "insights-agent"
   ```

### Step 3: Deploy Infrastructure

1. **Initialize and apply Terraform**:
   ```bash
   cd terraform
   terraform init
   terraform apply -var-file="terraform.tfvars"
   ```

2. **Note the outputs** (needed for GitHub secrets):
   ```bash
   terraform output
   ```

### Step 4: Configure GitHub Secrets

In your GitHub repository, go to **Settings** → **Secrets and variables** → **Actions** and add:

| Secret Name | Value | Source |
|-------------|-------|--------|
| `GCP_PROJECT_ID` | Your project ID | From Step 1 |
| `GCP_REGION` | `us-central1` | Your chosen region |
| `GCP_WIF_PROVIDER` | `projects/PROJECT_ID/locations/global/workloadIdentityPools/github-wif/providers/github` | Terraform output |
| `GCP_SA_EMAIL` | `ci-deployer@PROJECT_ID.iam.gserviceaccount.com` | Terraform output |
| `GCP_ARTIFACT_REPO` | `pat-insights` | Repository name |

### Step 5: Test Deployment

1. **Push to main branch** to trigger CI/CD
2. **Monitor GitHub Actions** for deployment status
3. **Test the deployed API**:
   ```bash
   # Get service URL
   gcloud run services describe pat-insights --region=us-central1 --format="value(status.url)"
   
   # Test with authentication
   curl -X POST "https://your-service-url/analyze" \
     -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
     -H "Content-Type: application/json" \
     -d '{"text":"Hello from the cloud!"}'
   ```

## Local Development

```bash
# Install dependencies
pip install -r app/requirements.txt

# Run tests
pytest app/tests/

# Start development server
python app/main.py

# Test locally
curl -X POST "http://localhost:8080/analyze" \
  -H "Content-Type: application/json" \
  -d '{"text":"hello world"}'
```

## API Usage

**Endpoint**: `POST /analyze`

**Request**:
```json
{"text": "I love cloud engineering!"}
```

**Response**:
```json
{
  "original_text": "I love cloud engineering!",
  "word_count": 4,
  "character_count": 25,
  "character_count_no_spaces": 21,
  "note": "MVP analysis; extend here with sentiment/LLM later."
}
```

## Security Considerations

- **Private by default**: Service requires IAM authentication
- **No service account keys**: Uses Workload Identity Federation
- **Minimal permissions**: Service account has only required roles
- **Container security**: Runs as non-root user with minimal base image
- **Network security**: Can be placed behind internal load balancer if needed

## Extending Security (Optional)

Restrict API access to specific service accounts:

```hcl
invoker_members = [
  "serviceAccount:consumer@your-project.iam.gserviceaccount.com"
]
```

For internal-only access, deploy behind a regional internal HTTP(S) load balancer with Serverless NEG.

## Cost Optimization

- **Scale-to-zero**: No charges when idle
- **Pay-per-request**: Only charged for actual usage
- **Free tier eligible**: Stays within GCP free tier for development
- **Efficient container**: Multi-stage Docker build reduces image size

## Troubleshooting

- **Authentication errors**: Ensure billing is enabled and APIs are activated
- **CI/CD failures**: Verify all GitHub secrets are correctly configured
- **Access denied**: Confirm you have proper IAM roles on the GCP project
- **Service unreachable**: Check that you're using an identity token for authentication

- Aligned repo with github repo name

