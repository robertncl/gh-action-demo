AKS uptime workflow

File format

Provide a JSON array of objects with the fields:

- subscriptionId
- resourceGroup
- clusterName
- namespace
- deploymentName
- kubeContextName (optional)

Example: see `clusters.json`.

Required secrets

Configure repository or org-level secrets for Azure OIDC login:

- AZURE_CLIENT_ID
- AZURE_TENANT_ID
- AZURE_SUBSCRIPTION_ID

Usage

Trigger the workflow manually and provide the path to your clusters JSON. The job logs into Azure, fetches kubeconfig for each entry, checks the last change timestamp for each deployment, and performs a rollout restart if older than the threshold (default 30 days).


