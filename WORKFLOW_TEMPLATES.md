# GitHub Actions Workflow Templates

This repository contains workflow templates for different project archetypes. All workflows are configured to run on `workflow_dispatch` (manual trigger) for maximum control.

## Available Templates

### 1. Maven CI Pipeline (`maven-ci.yaml`)

**Purpose**: Continuous Integration for Java/Maven projects

**Features**:
- Multi-JDK testing (Java 8, 11, 17, 21)
- Maven build, test, and package
- Code quality checks (SonarQube, SpotBugs, Checkstyle)
- Security scanning (Veracode Static Analysis and SCA)
- Artifact generation and upload

**Required Secrets**:
- `SONAR_HOST_URL`: SonarQube server URL
- `SONAR_TOKEN`: SonarQube authentication token
- `VERACODE_ID`: Veracode API ID
- `VERACODE_KEY`: Veracode API Key

**Usage**:
```bash
# Trigger manually from GitHub Actions tab
# Or via GitHub CLI:
gh workflow run maven-ci.yaml
```

### 2. Maven CD Pipeline (`maven-cd.yaml`)

**Purpose**: Continuous Deployment for Java/Maven projects

**Features**:
- Staging deployment (develop branch)
- Production deployment (main branch)
- GitHub releases creation
- Docker image building and pushing
- Environment-specific configurations

**Required Secrets**:
- `STAGING_HOST`, `STAGING_USER`, `STAGING_KEY`: Staging environment credentials
- `PROD_HOST`, `PROD_USER`, `PROD_KEY`: Production environment credentials
- `DOCKER_USERNAME`, `DOCKER_PASSWORD`: Docker registry credentials

**Usage**:
```bash
# Trigger manually from GitHub Actions tab
# Or via GitHub CLI:
gh workflow run maven-cd.yaml
```

### 3. React Native iOS Build (`react-native-ios.yaml`)

**Purpose**: iOS app building and deployment for React Native projects

**Features**:
- Multi-Xcode version testing
- iOS simulator builds and tests
- Code signing and provisioning profiles
- App Store Connect integration
- TestFlight deployment
- Security scanning with Veracode Static Analysis and SCA

**Required Secrets**:
- `IOS_P12_BASE64`: Base64 encoded iOS certificate
- `IOS_P12_PASSWORD`: iOS certificate password
- `APPSTORE_ISSUER_ID`: App Store Connect issuer ID
- `APPSTORE_API_KEY_ID`: App Store Connect API key ID
- `APPSTORE_API_PRIVATE_KEY`: App Store Connect private key
- `VERACODE_ID`: Veracode API ID
- `VERACODE_KEY`: Veracode API Key

**Usage**:
```bash
# Trigger manually from GitHub Actions tab
# Or via GitHub CLI:
gh workflow run react-native-ios.yaml
```

### 4. React Native Android Build (`react-native-android.yaml`)

**Purpose**: Android app building and deployment for React Native projects

**Features**:
- Multi-API level testing (21, 24, 29, 33)
- Android build and test automation
- APK and AAB generation
- Google Play Store deployment
- Code signing
- Security scanning with Veracode Static Analysis and SCA

**Required Secrets**:
- `ANDROID_KEYSTORE_BASE64`: Base64 encoded Android keystore
- `ANDROID_KEYSTORE_PASSWORD`: Android keystore password
- `ANDROID_KEY_ALIAS`: Android key alias
- `ANDROID_KEY_PASSWORD`: Android key password
- `PLAY_STORE_CONFIG_JSON`: Google Play Console service account JSON
- `VERACODE_ID`: Veracode API ID
- `VERACODE_KEY`: Veracode API Key

**Usage**:
```bash
# Trigger manually from GitHub Actions tab
# Or via GitHub CLI:
gh workflow run react-native-android.yaml
```

### 5. Azure AKS Deployment (`azure-aks-deployment.yaml`)

**Purpose**: Complete Azure Kubernetes Service deployment pipeline

**Features**:
- Docker image building and pushing to Azure Container Registry
- Multi-environment deployments (staging/production)
- Blue-green and canary deployment strategies
- Infrastructure as Code with Terraform
- Monitoring and alerting setup (Prometheus/Grafana)
- Automatic cleanup of old images
- Health checks and smoke tests

**Required Secrets**:
- `AZURE_CREDENTIALS`: Azure service principal credentials
- `AZURE_REGISTRY_NAME`: Azure Container Registry name
- `AKS_CLUSTER_NAME`: AKS cluster name
- `AKS_RESOURCE_GROUP`: AKS resource group name
- `IMAGE_NAME`: Docker image name (optional, defaults to 'myapp')

**Usage**:
```bash
# Deploy to staging
gh workflow run azure-aks-deployment.yaml -f environment=staging

# Deploy to production with blue-green strategy
gh workflow run azure-aks-deployment.yaml -f environment=production -f deployment_strategy=blue-green

# Deploy with custom image tag
gh workflow run azure-aks-deployment.yaml -f environment=production -f image_tag=v1.2.3
```

### 6. Angular Azure Web App Deployment (`angular-azure-webapp.yaml`)

**Purpose**: Complete Angular application build and deployment to Azure Web App

**Features**:
- Angular application building with multiple configurations
- Multi-environment deployments (staging/production)
- Blue-green deployment using Azure Web App slots
- Performance testing with load testing and curl-based metrics
- Security scanning with Veracode Static Analysis and SCA
- Application Insights monitoring setup
- Build optimization and compression
- Comprehensive testing and verification

**Required Secrets**:
- `AZURE_CREDENTIALS`: Azure service principal credentials
- `AZURE_WEBAPP_NAME`: Azure Web App name
- `AZURE_RESOURCE_GROUP`: Azure resource group name
- `AZURE_LOCATION`: Azure region
- `APPINSIGHTS_KEY`: Application Insights instrumentation key
- `APPINSIGHTS_CONNECTION_STRING`: Application Insights connection string
- `VERACODE_ID`: Veracode API ID
- `VERACODE_KEY`: Veracode API Key

**Usage**:
```bash
# Deploy to staging
gh workflow run angular-azure-webapp.yaml -f environment=staging

# Deploy to production with blue-green strategy
gh workflow run angular-azure-webapp.yaml -f environment=production -f deploy_slot=true

# Deploy with custom build configuration
gh workflow run angular-azure-webapp.yaml -f environment=production -f build_configuration=staging
```

## Setup Instructions

### For Maven Projects

1. **Copy the workflow files**:
   ```bash
   cp .github/workflows/maven-ci.yaml your-project/.github/workflows/
   cp .github/workflows/maven-cd.yaml your-project/.github/workflows/
   ```

2. **Configure your project**:
   - Update `pom.xml` with your project details
   - Add required Maven plugins (SonarQube, SpotBugs, Checkstyle)
   - Configure deployment environments

3. **Set up secrets**:
   - Go to your repository Settings → Secrets and variables → Actions
   - Add all required secrets listed above

### For React Native Projects

1. **Copy the workflow files**:
   ```bash
   cp .github/workflows/react-native-ios.yaml your-project/.github/workflows/
   cp .github/workflows/react-native-android.yaml your-project/.github/workflows/
   ```

2. **Configure your project**:
   - Update bundle IDs and package names
   - Configure signing certificates
   - Set up App Store Connect and Google Play Console

3. **Set up secrets**:
   - Add iOS and Android signing secrets
   - Configure App Store Connect and Google Play Console credentials

## Customization

### Environment Variables

All workflows use environment variables for easy customization:

```yaml
env:
  NODE_VERSION: '18'
  JAVA_VERSION: '17'
  MAVEN_OPTS: -Dfile.encoding=UTF-8
```

### Matrix Strategies

Workflows use matrix strategies for comprehensive testing:

- **Maven CI**: Multiple Java versions (8, 11, 17, 21)
- **iOS Build**: Multiple Xcode versions (15.0, 14.3)
- **Android Build**: Multiple API levels (21, 24, 29, 33)

### Caching

All workflows implement caching for faster builds:

- **Maven**: `~/.m2` cache
- **Node.js**: `npm` cache
- **Android**: Gradle cache
- **iOS**: CocoaPods cache

## Best Practices

1. **Manual Triggers**: All workflows use `workflow_dispatch` for controlled execution
2. **Artifact Management**: Build artifacts are uploaded and can be downloaded by dependent jobs
3. **Security**: Sensitive operations require proper secrets configuration
4. **Parallel Execution**: Jobs are designed to run in parallel where possible
5. **Error Handling**: Jobs use `if: always()` for artifact uploads to ensure they complete even on failure

## Troubleshooting

### Common Issues

1. **Missing Secrets**: Ensure all required secrets are configured in repository settings
2. **Build Failures**: Check logs for specific error messages and verify dependencies
3. **Signing Issues**: Verify certificates and provisioning profiles are correctly configured
4. **Deployment Failures**: Check environment credentials and network connectivity

### Debug Mode

To enable debug output, add this to your workflow:

```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

## Example Trigger Workflows

### 1. Maven Trigger Example (`example-maven-trigger.yaml`)

**Purpose**: Demonstrates how to trigger Maven CI/CD workflows with different scenarios

**Features**:
- Manual trigger with environment and Java version selection
- Automatic triggering on push/PR to main/develop
- Conditional deployment based on branch
- Workflow completion monitoring

**Usage**:
```bash
# Manual trigger with custom parameters
gh workflow run example-maven-trigger.yaml -f environment=production -f java_version=17

# Automatic trigger on push/PR
git push origin main
```

### 2. React Native Trigger Example (`example-react-native-trigger.yaml`)

**Purpose**: Demonstrates how to trigger React Native iOS/Android builds

**Features**:
- Platform selection (iOS, Android, or both)
- Build type selection (debug, release, or both)
- Optional app store uploads
- Parallel platform builds
- Cross-platform release creation

**Usage**:
```bash
# Build both platforms
gh workflow run example-react-native-trigger.yaml -f platform=both -f build_type=release

# Build iOS only with store upload
gh workflow run example-react-native-trigger.yaml -f platform=ios -f upload_store=true
```

### 3. Universal Trigger Example (`example-universal-trigger.yaml`)

**Purpose**: Automatically detects project type and triggers appropriate workflows

**Features**:
- Automatic project type detection
- Support for Maven, React Native iOS, Android, or both
- Manual override options
- Comprehensive project analysis

**Usage**:
```bash
# Auto-detect and trigger
gh workflow run example-universal-trigger.yaml

# Force specific project type
gh workflow run example-universal-trigger.yaml -f project_type=maven
```

### 4. Azure AKS Trigger Example (`example-azure-aks-trigger.yaml`)

**Purpose**: Demonstrates Azure AKS deployment with comprehensive checks and rollback

**Features**:
- Pre-deployment validation (Dockerfile, K8s manifests)
- Azure AKS deployment triggering
- Post-deployment verification and health checks
- Automatic rollback on failure
- Performance testing
- Resource cleanup

**Usage**:
```bash
# Deploy to staging with rolling strategy
gh workflow run example-azure-aks-trigger.yaml -f environment=staging -f deployment_strategy=rolling

# Deploy to production with blue-green strategy
gh workflow run example-azure-aks-trigger.yaml -f environment=production -f deployment_strategy=blue-green

# Deploy with infrastructure changes
gh workflow run example-azure-aks-trigger.yaml -f environment=production -f deploy_infrastructure=true
```

### 5. Angular Azure Web App Trigger Example (`example-angular-azure-trigger.yaml`)

**Purpose**: Demonstrates Angular Azure Web App deployment with comprehensive validation and monitoring

**Features**:
- Pre-deployment Angular project validation
- Angular Azure Web App deployment triggering
- Post-deployment verification and performance testing
- Performance testing with load testing and curl-based metrics
- Security scanning with Veracode Static Analysis and SCA
- Bundle size analysis
- Application Insights monitoring
- Automatic rollback on failure

**Usage**:
```bash
# Deploy to staging
gh workflow run example-angular-azure-trigger.yaml -f environment=staging

# Deploy to production with blue-green deployment
gh workflow run example-angular-azure-trigger.yaml -f environment=production -f deploy_slot=true

# Deploy with custom build configuration
gh workflow run example-angular-azure-trigger.yaml -f environment=production -f build_configuration=staging
```

## Contributing

To add new workflow templates:

1. Create a new YAML file in `.github/workflows/`
2. Follow the naming convention: `{technology}-{purpose}.yaml`
3. Include comprehensive documentation
4. Test the workflow with a sample project
5. Update this README with the new template details 