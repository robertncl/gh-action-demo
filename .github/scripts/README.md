# AKS Uptime Check Scripts

This directory contains scripts for checking AKS cluster uptime and performing automated restarts with verification.

## Scripts

### `check-aks-uptime.sh`

The main script that checks AKS cluster deployments and performs rollout restarts when needed.

**Features:**
- Reads cluster configuration from JSON files
- Checks deployment age against configurable thresholds
- Performs rollout restarts for stale deployments
- **NEW**: Verifies restart completion with comprehensive status checking

**Usage:**
```bash
./check-aks-uptime.sh <clusters_file> [days_threshold] [verify_restart] [max_wait_time]
```

**Parameters:**
- `clusters_file`: JSON file containing cluster configurations
- `days_threshold`: Number of days after which to restart (default: 30)
- `verify_restart`: Enable/disable restart verification (default: true)
- `max_wait_time`: Maximum seconds to wait for restart completion (default: 300)

**Environment Variables:**
- `VERIFY_RESTART_ENV`: Override verify_restart parameter
- `MAX_WAIT_TIME_ENV`: Override max_wait_time parameter  
- `CHECK_INTERVAL_ENV`: Override check interval (default: 10 seconds)

### `test-restart-verification.sh`

Test script to verify the restart verification functionality works correctly.

**Usage:**
```bash
./test-restart-verification.sh
```

**Requirements:**
- Active Kubernetes context
- `kubectl` configured and accessible
- Sufficient permissions to create/delete namespaces and deployments

## Restart Verification

The restart verification feature ensures that deployments are fully ready after a restart operation. It performs the following checks:

### Status Monitoring
- **Available Replicas**: Ensures all desired replicas are available
- **Updated Replicas**: Verifies all replicas are running the new version
- **Ready Replicas**: Confirms all replicas are ready to serve traffic
- **Unavailable Replicas**: Monitors for stuck or failed replicas

### Rollout Status
- Uses `kubectl rollout status` to check completion
- Detects successful rollouts and failures
- Provides detailed progress information

### Timeout Handling
- Configurable maximum wait time (default: 5 minutes)
- Configurable check interval (default: 10 seconds)
- Graceful timeout with final status reporting

### Error Detection
- Deployment not found errors
- Rollout failures
- Stuck deployments with unavailable replicas
- Timeout scenarios

## Example Configuration

**clusters.json:**
```json
[
  {
    "subscriptionId": "your-subscription-id",
    "resourceGroup": "your-resource-group", 
    "clusterName": "your-aks-cluster",
    "namespace": "default",
    "deploymentName": "web-app",
    "kubeContextName": "optional-context-name"
  }
]
```

## Example Usage

**Basic usage with verification:**
```bash
./check-aks-uptime.sh clusters.json 30 true 300
```

**Disable verification:**
```bash
./check-aks-uptime.sh clusters.json 30 false
```

**Custom timeout:**
```bash
./check-aks-uptime.sh clusters.json 30 true 600
```

**Using environment variables:**
```bash
export VERIFY_RESTART_ENV=true
export MAX_WAIT_TIME_ENV=600
export CHECK_INTERVAL_ENV=15
./check-aks-uptime.sh clusters.json
```

## Testing

Run the test script to verify functionality:
```bash
./test-restart-verification.sh
```

The test script will:
1. Create a test namespace and deployment
2. Test the verification function with a real restart
3. Verify timeout behavior
4. Clean up test resources

## Error Handling

The script continues processing other deployments even if one fails verification. Failed verifications are logged as errors but don't stop the overall process.

## Dependencies

- `az` (Azure CLI)
- `kubectl` 
- `jq`
- `python3` (for human-readable time formatting)
- `date` (GNU date for timestamp parsing)

## Security Notes

- The script uses non-admin credentials for AKS access
- Credentials are overwritten to avoid context bloat
- All kubectl operations are scoped to specific namespaces
- No sensitive data is logged or stored
