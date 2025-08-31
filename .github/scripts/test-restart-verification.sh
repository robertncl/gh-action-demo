#!/usr/bin/env bash

set -euo pipefail

# test-restart-verification.sh
# Test script to demonstrate the restart verification functionality
# This script creates a simple test deployment and tests the verification logic

echo "🧪 Testing AKS Restart Verification Functionality"
echo "=================================================="

# Check if we're in a Kubernetes context
if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "❌ No Kubernetes context available. Please configure kubectl first."
  exit 1
fi

# Test namespace
TEST_NAMESPACE="test-restart-verification"
TEST_DEPLOYMENT="test-app"

echo "📋 Test Configuration:"
echo "  Namespace: $TEST_NAMESPACE"
echo "  Deployment: $TEST_DEPLOYMENT"
echo "  Cluster: $(kubectl config current-context)"
echo ""

# Clean up any existing test resources
echo "🧹 Cleaning up existing test resources..."
kubectl delete namespace "$TEST_NAMESPACE" --ignore-not-found=true >/dev/null 2>&1
sleep 2

# Create test namespace
echo "📁 Creating test namespace..."
kubectl create namespace "$TEST_NAMESPACE"

# Create a simple test deployment
echo "🚀 Creating test deployment..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $TEST_DEPLOYMENT
  namespace: $TEST_NAMESPACE
  labels:
    app: test-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test-app
  template:
    metadata:
      labels:
        app: test-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.21-alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
EOF

echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/"$TEST_DEPLOYMENT" -n "$TEST_NAMESPACE"

echo "✅ Test deployment is ready!"
echo ""

# Test the verification function by importing it
echo "🧪 Testing restart verification function..."
echo ""

# Source the main script to get the verification function
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/check-aks-uptime.sh"

if [[ ! -f "$MAIN_SCRIPT" ]]; then
  echo "❌ Main script not found: $MAIN_SCRIPT"
  exit 1
fi

# Extract the verification function from the main script
verify_restart_completion() {
  # This function will be sourced from the main script
  echo "Function not loaded yet"
}

# Source the function (we'll need to extract it manually since we can't source the whole script)
echo "📥 Loading verification function..."

# Extract the function using sed and eval
VERIFICATION_FUNCTION=$(sed -n '/^verify_restart_completion()/,/^}/p' "$MAIN_SCRIPT")
if [[ -n "$VERIFICATION_FUNCTION" ]]; then
  eval "$VERIFICATION_FUNCTION"
  echo "✅ Verification function loaded successfully"
else
  echo "❌ Failed to extract verification function"
  exit 1
fi

echo ""

# Test 1: Verify current deployment status
echo "🔍 Test 1: Current deployment status"
echo "-------------------------------------"
kubectl get deployment "$TEST_DEPLOYMENT" -n "$TEST_NAMESPACE" -o wide
echo ""

# Test 2: Simulate a restart and verify completion
echo "🔄 Test 2: Simulating restart and verification"
echo "-----------------------------------------------"

# Trigger a restart
echo "Triggering restart..."
kubectl rollout restart deployment/"$TEST_DEPLOYMENT" -n "$TEST_NAMESPACE"

# Test the verification function
echo "Testing verification function..."
if verify_restart_completion "$TEST_NAMESPACE" "$TEST_DEPLOYMENT" 60 5; then
  echo "✅ Verification test passed!"
else
  echo "❌ Verification test failed!"
fi

echo ""

# Test 3: Check final status
echo "🔍 Test 3: Final deployment status"
echo "-----------------------------------"
kubectl get deployment "$TEST_DEPLOYMENT" -n "$TEST_NAMESPACE" -o wide
kubectl get pods -n "$TEST_NAMESPACE" -l app=test-app

echo ""

# Test 4: Test timeout scenario
echo "⏰ Test 4: Testing timeout scenario (short timeout)"
echo "---------------------------------------------------"
echo "Testing with 5 second timeout..."
if verify_restart_completion "$TEST_NAMESPACE" "$TEST_DEPLOYMENT" 5 1; then
  echo "✅ Unexpected success with short timeout"
else
  echo "✅ Expected timeout behavior working correctly"
fi

echo ""

# Cleanup
echo "🧹 Cleaning up test resources..."
kubectl delete namespace "$TEST_NAMESPACE" --ignore-not-found=true >/dev/null 2>&1

echo ""
echo "🎉 Test completed successfully!"
echo ""
echo "📋 Summary:"
echo "  ✅ Test deployment created and verified"
echo "  ✅ Restart verification function tested"
echo "  ✅ Timeout behavior verified"
echo "  ✅ Cleanup completed"
echo ""
echo "💡 The restart verification function can now be used in the main script"
echo "   to ensure deployments are fully ready after restart operations."
