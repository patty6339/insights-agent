# Insight-Agent Project Cost Analysis

## Free Tier Services

The following GCP services used in this project are covered by Google Cloud's Always Free tier:

- **Cloud Run**: 2 million requests/month + 360,000 GB-seconds compute time
- **Artifact Registry**: 0.5 GB storage free
- **Cloud Build**: 120 build-minutes/day (used by GitHub Actions)
- **IAM & Workload Identity Federation**: Free
- **Cloud Logging**: 50 GB/month free

## Expected Costs for MVP Usage

Your project will likely stay **completely free** for development and testing because:

1. **Cloud Run**: With scale-to-zero and minimal traffic, you'll stay well under the 2M request limit
2. **Artifact Registry**: Your Docker images (~100-200MB each) fit easily in 0.5GB free storage
3. **GitHub Actions**: Uses your GitHub minutes, not GCP build minutes

## Potential Charges (Only if Free Tier Exceeded)

- **Cloud Run**: $0.40 per million requests after free tier
- **Artifact Registry**: $0.10/GB/month after 0.5GB
- **Egress**: $0.12/GB for data leaving GCP (minimal for API responses)

## Cost Monitoring Recommendations

1. **Enable billing alerts** at $1-5 thresholds in GCP Console
2. **Use GCP Pricing Calculator** for future estimates: https://cloud.google.com/products/calculator
3. **Monitor usage** in GCP Console billing section
4. **Review monthly** billing reports for any unexpected charges

## Bottom Line

For an MVP with light testing and development usage, you should incur **$0 monthly costs**. Only significant production traffic or storing many large container images would generate charges.