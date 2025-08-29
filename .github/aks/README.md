AKS uptime workflow

File format

Provide a CSV file with the header:

subscriptionId,resourceGroup,clusterName,namespace,deploymentName[,kubeContextName]

Notes:

- Lines starting with `#` are ignored
- `kubeContextName` (6th column) is optional, used only for logging
- Example entries are provided in `clusters.csv`

Required secrets

Configure repository or org-level secrets for Azure OIDC login:

- AZURE_CLIENT_ID
- AZURE_TENANT_ID
- AZURE_SUBSCRIPTION_ID

Usage

Trigger the workflow manually and provide the path to your clusters CSV. The job logs into Azure, fetches kubeconfig for each entry, checks the last change timestamp for each deployment, and performs a rollout restart if older than the threshold (default 30 days).


