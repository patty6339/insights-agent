# Pat-insights Project Documentation

## Project Overview

**Pat-insights** is a minimal FastAPI microservice that provides text analysis capabilities through a single REST endpoint. This MVP demonstrates modern cloud-native development practices with secure CI/CD deployment to Google Cloud Platform.

## Core Functionality

### API Endpoint
- **POST /analyze** - Analyzes text input and returns:
  - Original text
  - Word count
  - Character count (with spaces)
  - Character count (without spaces)
  - Analysis note

### Example Request/Response
```bash
curl -X POST "https://your-service-url/analyze" \
  -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello world!"}'
```

```json
{
  "original_text": "Hello world!",
  "word_count": 2,
  "character_count": 12,
  "character_count_no_spaces": 11,
  "note": "MVP analysis; extend here with sentiment/LLM later."
}
```

## Project Structure

```
pat-insights/
├── app/                    # FastAPI application
│   ├── main.py            # API implementation
│   ├── requirements.txt   # Python dependencies
│   └── tests/
│       └── test_app.py    # Unit tests
├── terraform/             # Infrastructure as Code
│   ├── main.tf           # Main Terraform config
│   ├── variables.tf      # Input variables
│   ├── apis.tf           # GCP API enablement
│   ├── artifact_registry.tf # Container registry
│   ├── cloud_run.tf      # Cloud Run service
│   ├── iam.tf            # Service accounts & permissions
│   ├── wif.tf            # Workload Identity Federation
│   └── terraform.tfvars.example # Configuration template
├── .github/workflows/
│   └── cicd.yml          # GitHub Actions CI/CD pipeline
├── Dockerfile            # Container image definition
├── Makefile             # Local development commands
└── ruff.toml            # Python linting configuration
```

## Technology Stack

### Application
- **FastAPI**: Modern Python web framework with automatic OpenAPI docs
- **Pydantic**: Data validation and serialization
- **Uvicorn**: ASGI server for production deployment

### Infrastructure
- **Google Cloud Run**: Serverless container platform
- **Artifact Registry**: Container image storage
- **Terraform**: Infrastructure provisioning
- **GitHub Actions**: CI/CD automation

### Security Features
- **Workload Identity Federation**: Keyless authentication from GitHub to GCP
- **IAM-based access control**: No public access, requires authentication
- **Non-root container**: Security-hardened Docker image
- **Minimal base image**: Reduced attack surface

## Development Workflow

### Local Development
1. **Install dependencies**: `pip install -r app/requirements.txt`
2. **Run tests**: `pytest app/tests/`
3. **Start server**: `uvicorn app.main:app --reload`
4. **Access docs**: http://localhost:8000/docs

### CI/CD Pipeline
1. **Trigger**: Push to `main` branch
2. **Test**: Lint with Ruff, run pytest
3. **Build**: Create Docker image with commit SHA tag
4. **Deploy**: Push to Artifact Registry, update Cloud Run via Terraform

## Expected Behavior

### Successful Deployment
- Service accessible only with valid GCP identity token
- Automatic scaling from 0 to handle traffic
- Container logs available in Cloud Logging
- OpenAPI documentation at `/docs` endpoint

### Error Handling
- **422**: Invalid input (empty text, malformed JSON)
- **400**: Processing errors
- **401/403**: Authentication/authorization failures

## Configuration Requirements

### GitHub Secrets
- `GCP_PROJECT_ID`: Your GCP project ID
- `GCP_REGION`: Deployment region (e.g., us-central1)
- `GCP_WIF_PROVIDER`: Workload Identity Federation provider
- `GCP_SA_EMAIL`: Service account email for CI/CD
- `GCP_ARTIFACT_REPO`: Artifact Registry repository name

### Terraform Variables
Copy `terraform/terraform.tfvars.example` and configure:
- `project_id`: GCP project ID
- `region`: Deployment region
- `github_owner`: GitHub username/organization
- `github_repo`: Repository name

## Extension Points

The current MVP provides a foundation for advanced text analysis:

1. **Sentiment Analysis**: Integrate ML models for emotion detection
2. **Language Detection**: Multi-language support
3. **Entity Recognition**: Extract names, places, organizations
4. **Summarization**: Generate text summaries
5. **Batch Processing**: Handle multiple texts simultaneously

## Security Considerations

- Service is **not publicly accessible** - requires IAM authentication
- All infrastructure provisioned with least-privilege principles
- Container runs as non-root user (UID 10001)
- No long-lived service account keys in CI/CD
- Regular security updates via base image rebuilds

## Monitoring & Observability

- **Cloud Run metrics**: Request count, latency, error rate
- **Container logs**: Application and system logs in Cloud Logging
- **Health checks**: Built-in Cloud Run health monitoring
- **Tracing**: Request tracing available via Cloud Trace integration

## Cost Optimization

- **Scale-to-zero**: No charges when idle
- **Pay-per-request**: Only charged for actual usage
- **Minimal resources**: 1 CPU, 512MB memory default
- **Efficient container**: Multi-stage build reduces image size