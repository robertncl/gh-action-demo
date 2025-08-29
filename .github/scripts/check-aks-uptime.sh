#!/usr/bin/env bash

set -euo pipefail

# check-aks-uptime.sh
# Reads a clusters file and, for each AKS cluster + deployment entry, checks when the
# deployment last progressed. If older than threshold days, performs a rollout restart.
#
# File format (CSV with header):
# subscriptionId,resourceGroup,clusterName,namespace,deploymentName[,kubeContextName]
# - Lines starting with '#' and blank lines are ignored
# - Optional 6th column kubeContextName will be used for informative logs only
#
# Usage:
#   ./check-aks-uptime.sh <clusters_file> [days_threshold]

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <clusters_file> [days_threshold]" >&2
  exit 2
fi

CLUSTERS_FILE="$1"
DAYS_THRESHOLD="${2:-30}"

if [[ ! -f "$CLUSTERS_FILE" ]]; then
  echo "Clusters file not found: $CLUSTERS_FILE" >&2
  exit 3
fi

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI (az) is required." >&2
  exit 4
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required." >&2
  exit 5
fi

# Convert threshold to seconds for comparison
THRESHOLD_SECONDS=$(( DAYS_THRESHOLD * 24 * 60 * 60 ))

echo "Using threshold: ${DAYS_THRESHOLD} days (${THRESHOLD_SECONDS}s)"

line_no=0
while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
  line_no=$(( line_no + 1 ))
  line="${raw_line%%[$'\r\n']*}"

  # Skip header, comments, and blank lines
  if [[ -z "$line" || "$line" =~ ^# ]]; then
    continue
  fi
  if [[ $line_no -eq 1 && "$line" =~ subscriptionId,resourceGroup,clusterName,namespace,deploymentName ]]; then
    continue
  fi

  IFS=',' read -r subscription_id resource_group cluster_name namespace deployment_name kube_context_name <<<"$line"

  if [[ -z "${subscription_id:-}" || -z "${resource_group:-}" || -z "${cluster_name:-}" || -z "${namespace:-}" || -z "${deployment_name:-}" ]]; then
    echo "[WARN] Skipping line $line_no due to missing required fields: $line" >&2
    continue
  fi

  context_label="${kube_context_name:-${cluster_name}}"
  echo "\n=== Processing ${context_label} :: ${namespace}/${deployment_name} (sub: ${subscription_id}, rg: ${resource_group}, aks: ${cluster_name}) ==="

  # Fetch kube credentials for the specific cluster (non-admin). Overwrite to avoid context bloat.
  az aks get-credentials \
    --subscription "$subscription_id" \
    --resource-group "$resource_group" \
    --name "$cluster_name" \
    --overwrite-existing 1>/dev/null

  # Determine the last rollout/progress timestamp for the deployment
  # Prefer the Progressing condition's lastUpdateTime; fallback to restartedAt annotation; then to deployment creationTimestamp
  progressing_last_update=$(kubectl get deploy "$deployment_name" -n "$namespace" -o jsonpath='{range .status.conditions[?(@.type=="Progressing")]}{.lastUpdateTime}{"\n"}{end}' 2>/dev/null | tail -n 1 || true)
  restarted_at=$(kubectl get deploy "$deployment_name" -n "$namespace" -o jsonpath='{.spec.template.metadata.annotations.kubectl\.kubernetes\.io/restartedAt}' 2>/dev/null || true)
  creation_ts=$(kubectl get deploy "$deployment_name" -n "$namespace" -o jsonpath='{.metadata.creationTimestamp}' 2>/dev/null || true)

  last_change_ts=""
  if [[ -n "$progressing_last_update" ]]; then
    last_change_ts="$progressing_last_update"
  elif [[ -n "$restarted_at" ]]; then
    last_change_ts="$restarted_at"
  else
    last_change_ts="$creation_ts"
  fi

  if [[ -z "$last_change_ts" ]]; then
    echo "[WARN] Could not determine last change time for ${namespace}/${deployment_name}. Skipping."
    continue
  fi

  # Convert RFC3339 to epoch seconds using GNU date
  if ! last_change_epoch=$(date -u -d "$last_change_ts" +%s 2>/dev/null); then
    echo "[WARN] Unable to parse timestamp '$last_change_ts' for ${namespace}/${deployment_name}. Skipping."
    continue
  fi

  now_epoch=$(date -u +%s)
  age_seconds=$(( now_epoch - last_change_epoch ))

  # Describe in logs
  human_age=$(python3 - <<'PY'
import os
import sys
secs=int(os.environ.get('AGE_SECONDS','0'))
days=secs//86400
hrs=(secs%86400)//3600
mins=(secs%3600)//60
print(f"{days}d {hrs}h {mins}m")
PY
  )
  echo "Last change: ${last_change_ts} (age: ${human_age})"

  if (( age_seconds >= THRESHOLD_SECONDS )); then
    echo "Age >= threshold. Performing rollout restart for ${namespace}/${deployment_name}..."
    # Perform rollout restart
    if kubectl rollout restart deployment/"$deployment_name" -n "$namespace"; then
      echo "Restart triggered for ${namespace}/${deployment_name}."
    else
      echo "[ERROR] Failed to restart ${namespace}/${deployment_name}." >&2
    fi
  else
    echo "Age < threshold. No action for ${namespace}/${deployment_name}."
  fi
done < "$CLUSTERS_FILE"

echo "\nAll entries processed."


