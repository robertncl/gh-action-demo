# GitHub Actions Workflow Templates

This repository contains workflow templates for different project archetypes. All workflows are configured to run on `workflow_dispatch` (manual trigger) for maximum control.

## Available Templates

### 1. Maven CI Pipeline (`maven-ci.yaml`)

**Purpose**: Continuous Integration for Java/Maven projects

**Features**:
- Multi-JDK testing (Java 8, 11, 17, 21)
- Maven build, test, and package
- Code quality checks (SonarQube, SpotBugs, Checkstyle)
- Security scanning (OWASP Dependency Check)
- Artifact generation and upload

**Required Secrets**:
- `SONAR_HOST_URL`: SonarQube server URL
- `SONAR_TOKEN`: SonarQube authentication token

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

**Required Secrets**:
- `IOS_P12_BASE64`: Base64 encoded iOS certificate
- `IOS_P12_PASSWORD`: iOS certificate password
- `APPSTORE_ISSUER_ID`: App Store Connect issuer ID
- `APPSTORE_API_KEY_ID`: App Store Connect API key ID
- `APPSTORE_API_PRIVATE_KEY`: App Store Connect private key

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

**Required Secrets**:
- `ANDROID_KEYSTORE_BASE64`: Base64 encoded Android keystore
- `ANDROID_KEYSTORE_PASSWORD`: Android keystore password
- `ANDROID_KEY_ALIAS`: Android key alias
- `ANDROID_KEY_PASSWORD`: Android key password
- `PLAY_STORE_CONFIG_JSON`: Google Play Console service account JSON

**Usage**:
```bash
# Trigger manually from GitHub Actions tab
# Or via GitHub CLI:
gh workflow run react-native-android.yaml
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

## Contributing

To add new workflow templates:

1. Create a new YAML file in `.github/workflows/`
2. Follow the naming convention: `{technology}-{purpose}.yaml`
3. Include comprehensive documentation
4. Test the workflow with a sample project
5. Update this README with the new template details 