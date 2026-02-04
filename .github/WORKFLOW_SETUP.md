# GitHub Actions Workflow Setup Guide

## Overview
This document provides setup instructions for the Terraform CI workflow.

## Prerequisites

1. **GitHub Repository**: Your code must be in a GitHub repository
2. **Azure Service Principal**: Create a service principal for authentication
3. **GitHub Secrets**: Configure required secrets in your repository

## Step 1: Create Azure Service Principal

```bash
az ad sp create-for-rbac --name "github-actions-terraform" \
  --role Contributor \
  --scopes /subscriptions/{subscription-id}
```

## Step 2: Configure GitHub Secrets

Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):

### 2a. Create Snyk Account & Get Token

1. Sign up for free at [Snyk.io](https://app.snyk.io/signup)
2. Go to Account Settings → Auth Token
3. Copy your API token

### 2b. Add Secrets

- **SNYK_TOKEN**: Your Snyk API token from https://app.snyk.io/account/settings

Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):

### Required Secrets:
- **AZURE_CREDENTIALS**: JSON output from the service principal creation
  ```json
  {
    "clientId": "<client-id>",
    "clientSecret": "<client-secret>",
    "subscriptionId": "<subscription-id>",
    "tenantId": "<tenant-id>"
  }
  ```

- **ARM_SUBSCRIPTION_ID**: Your Azure subscription ID
- **ARM_TENANT_ID**: Your Azure tenant ID
- **ARM_CLIENT_ID**: Service principal client ID
- **ARM_CLIENT_SECRET**: Service principal client secret
- **SNYK_TOKEN**: Your Snyk API token (get from https://app.snyk.io/account/settings)

## Step 3: Workflow Triggers

The workflow automatically triggers on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Changes to Terraform files (*.tf, *.tftpl)
- Manual workflow dispatch via GitHub Actions

## Step 4: Environment Variables

Update `TF_VERSION` in the workflow file to match your Terraform version:

```yaml
env:
  TF_VERSION: 1.6.0  # Update this to your version
```

## Step 5: Working Directory

The workflow assumes the Terraform files are in the `Jenkins VM Pipeline` directory. 
Update `WORKING_DIR` if your structure is different:

```yaml
env:
  WORKING_DIR: ./Jenkins\ VM\ Pipeline
```

## Workflow Jobs

### 1. **terraform-validate**
   - Validates Terraform syntax
   - Checks code formatting
   - Runs terraform validate command

### 2. **terraform-plan**
   - Authenticates with Azure
   - Initializes Terraform
   - Generates Terraform plan
   - Uploads plan as artifact

### 3. **bootstrap-tests**
   - Runs unit tests on Bootstrap script
   - Performs ShellCheck analysis

### 4. **security-scan**
   - Runs TFLint for Terraform best practices
   - Performs Snyk IaC security scan for vulnerabilities
   - Uploads SARIF results to GitHub Security tab

### 5. **summary**
   - Generates workflow summary

## Running Tests Locally

### Bootstrap Unit Tests:
```bash
bash ./tests/bootstrap_tests.sh
```

### Bootstrap Integration Tests:
```bash
bash ./tests/bootstrap_integration_test.sh
```

### ShellCheck:
```bash
shellcheck -x "./Jenkins VM Pipeline/Bootstrap.tftpl"
```

## Troubleshooting

### Azure Authentication Failed
- Verify all ARM_* secrets are correctly set
- Check service principal has Contributor role
- Ensure subscription ID is correct

### Terraform Plan Failed
- Check if Azure resources already exist
- Verify provider.tf credentials
- Review Terraform syntax with `terraform validate`

### Bootstrap Tests Failed
- Ensure Bootstrap.tftpl has correct permissions
- Check shell syntax with `bash -n Bootstrap.tftpl`
- Verify all package repositories are accessible

## Best Practices

1. **Always review the plan** before merging to main
2. **Use develop branch** for testing changes
3. **Keep secrets secure** and rotate regularly
4. **Monitor workflow runs** in GitHub Actions tab
5. **Archive plans** for audit purposes (already configured)

## Additional Security Measures

Consider implementing:
- Branch protection rules
- Required status checks before merge
- Code review requirements
- Automatic plan comments on PRs
- Scheduled security scans

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Azure Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices)
