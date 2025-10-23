# Microsoft Sentinel Deployment Guide

![SecureHats Banner](./media/sh-banner.png)

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Repository Structure](#repository-structure)
- [GitHub Actions Workflows](#github-actions-workflows)
- [Configuration](#configuration)
- [Deployment Process](#deployment-process)
- [Analytics Rules](#analytics-rules)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## 🎯 Overview

This repository provides an automated Infrastructure as Code (IaC) solution for deploying Microsoft Sentinel and its security content using:

- **Bicep Templates** - Azure infrastructure deployment
- **GitHub Actions** - CI/CD automation
- **YAML-based Analytics Rules** - Security detection rules
- **SecureHats Actions** - Custom deployment and validation actions

### Key Features

✅ Automated Sentinel workspace deployment  
✅ Log Analytics workspace configuration  
✅ Optional Azure Monitor solutions (VM Insights, Container Insights, etc.)  
✅ Analytics rule validation and deployment  
✅ Multi-environment support  
✅ KQL query validation  

---

## 🏗️ Architecture

### Deployment Flow

```
┌─────────────────────┐
│   Push to GitHub    │
│   (main/packages)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  GitHub Actions     │
│  Workflow Trigger   │
└──────────┬──────────┘
           │
           ├─────────────────────┐
           ▼                     ▼
┌──────────────────┐   ┌─────────────────────┐
│ Infrastructure   │   │ Analytics Rules     │
│ Deployment       │   │ Validation          │
│                  │   │                     │
│ 1. Resource Group│   │ 1. KQL Validation   │
│ 2. Log Analytics │   │ 2. Syntax Check     │
│ 3. Sentinel      │   │ 3. YAML to ARM      │
│ 4. Solutions     │   │ 4. Deploy Rules     │
└──────────────────┘   └─────────────────────┘
```

### Azure Resources Deployed

1. **Resource Group** - Container for all Sentinel resources
2. **Log Analytics Workspace** - Data ingestion and storage
3. **Microsoft Sentinel** - Security Information and Event Management (SIEM)
4. **Optional Solutions**:
   - Behavior Analytics Insights
   - Logic Apps Management
   - DNS Analytics
   - Container Insights
   - VM Insights
   - Windows Firewall

---

## ✅ Prerequisites

### Azure Requirements

- **Azure Subscription** with Contributor permissions
- **Service Principal** with the following roles:
  - `Contributor` on target subscription/resource group
  - `Microsoft Sentinel Contributor` (optional, for advanced features)

### GitHub Requirements

- Repository with GitHub Actions enabled
- GitHub Secrets configured (see [Configuration](#configuration))

### Local Development (Optional)

For local testing and validation:

```bash
# Required tools
- Azure CLI (az) v2.50+
- Bicep CLI v0.20+
- PowerShell 7+ (optional)
- Git
```

---

## 📂 Repository Structure

```
sentinel-deploy/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md              # Bug report template
│   │   └── feauture_request.md        # Feature request template
│   └── workflows/
│       ├── deploy-sentinel.yml        # Main deployment workflow
│       └── analytics.yaml             # Analytics validation workflow
│
├── environments/
│   └── nonprod.json                   # Non-production environment config
│
├── media/
│   └── sh-banner.png                  # Repository assets
│
├── packages/
│   └── README.md                      # Packages directory (for custom solutions)
│
├── resources/
│   ├── resourcegroup.bicep            # Resource group deployment template
│   ├── workspace.bicep                # Log Analytics + Sentinel deployment
│   └── solutions.bicep                # Optional Azure solutions
│
├── samples/
│   ├── AWS_*.yaml                     # 54 AWS security detection rules
│   └── readme.md
│
└── README.md                          # Main repository README
```

### Key Directories

- **`.github/workflows/`** - GitHub Actions workflow definitions
- **`environments/`** - Environment-specific configuration files
- **`resources/`** - Bicep infrastructure templates
- **`packages/`** - Custom Sentinel content packages (future use)
- **`samples/`** - Pre-built analytics rules (54 AWS-focused rules)

---

## ⚙️ GitHub Actions Workflows

### 1. Deploy Sentinel Workflow (`deploy-sentinel.yml`)

**Trigger:** Push to paths matching `.github/**`

**Purpose:** Deploys complete Sentinel infrastructure and analytics rules

#### Workflow Jobs

##### Job 1: `set-variables`
- **Runtime:** Ubuntu Latest
- **Purpose:** Load environment configuration from JSON
- **Action Used:** `SecureHats/JsonTo-Variable@v0.1.3`
- **Output:** Environment variables for subsequent jobs

**Configuration Loaded:**
```yaml
- customerSolutions           # List of custom solution packages
- sentinelResourceGroup       # Resource group name
- workspaceName              # Log Analytics workspace name
- location                   # Azure region
- solutionsPath              # Path to solution packages
- pricingTierLogAnalytics    # Pricing tier
- retentionInDays            # Log retention period
- enable* flags              # Feature toggles
```

##### Job 2: `deploy-resources`
- **Runtime:** Ubuntu Latest
- **Depends On:** `set-variables`
- **Purpose:** Deploy Azure infrastructure
- **Action Used:** `azure/arm-deploy@v1`

**Deployment Steps:**

1. **Create Resource Group** (Subscription-level deployment)
   ```yaml
   Template: resources/resourcegroup.bicep
   Parameters:
     - resourceGroupName
     - location
   ```

2. **Create Log Analytics Workspace**
   ```yaml
   Template: resources/workspace.bicep
   Parameters:
     - workspaceName
     - location
     - retentionInDays
     - enable* flags
   ```

3. **Create Sentinel Solutions** (Currently commented out)
   ```yaml
   Template: resources/solutions.bicep
   Note: Uncomment to enable additional solutions
   ```

##### Job 3: `deploy_analytics`
- **Runtime:** Ubuntu Latest
- **Depends On:** `deploy-resources`, `set-variables`
- **Strategy:** Matrix deployment (parallel)
- **Purpose:** Deploy analytics rules from packages

**Deployment Steps:**

1. **Convert YAML to ARM**
   - Action: `SecureHats/YamlTo-Arm@v0.1.7`
   - Input: YAML detection rules
   - Output: ARM template (deployment.json)

2. **Deploy Analytics Rules**
   - Deploys to Sentinel workspace
   - Uses converted ARM templates
   - Runs per solution package

**Matrix Strategy:**
```yaml
# Deploys each package in parallel
matrix:
  package: [keyvault, azure-ad, azure-firewall, cisco-firepower]
```

### 2. Analytics Validation Workflow (`analytics.yaml`)

**Trigger:** Push to paths matching `packages/**`

**Purpose:** Validate analytics rules before deployment

#### Workflow Jobs

##### Job: `pester-test`
- **Runtime:** Ubuntu Latest
- **Purpose:** Validate detection rules

**Validation Steps:**

1. **Validate Deprecated KQL**
   - Action: `SecureHats/kusto-alias@v0.2.0`
   - Checks for deprecated KQL functions
   - Validates query syntax
   - Log Level: Detailed

2. **Validate Sentinel Analytics Rules**
   - Action: `SecureHats/validate-detections@v1.5`
   - Validates YAML structure
   - Checks required fields
   - Validates entity mappings
   - Log Level: Detailed

**Files Validated:**
```yaml
filesPath: ./packages/**
# Recursively validates all YAML files in packages directory
```

---

## 🔧 Configuration

### Environment Configuration File

The `environments/nonprod.json` file contains all deployment parameters:

```json
{
  "LogAnalytics": [
    {
      "sentinelResourceGroup": "rdk-dev-rg",
      "workspaceName": "rdk-tst-workspace",
      "location": "westeurope",
      "pricingTierLogAnalytics": "PerGB2018",
      "retentionInDays": 90
    }
  ],
  "solutions": {
    "enableBehaviorAnalyticsInsights": true,
    "enableLogicAppsManagementInsights": true,
    "enableDnsAnalytics": true,
    "enableContainerInsights": true,
    "enableVMInsights": true,
    "enableWindowsFirewall": true
  },
  "packages": [
    {
      "solutionsPath": "packages",
      "customerSolutions": [
        "keyvault",
        "azure-ad",
        "azure-firewall",
        "cisco-firepower"
      ]
    }
  ]
}
```

### Configuration Parameters

#### LogAnalytics Section

| Parameter | Description | Example | Required |
|-----------|-------------|---------|----------|
| `sentinelResourceGroup` | Azure resource group name | `rdk-dev-rg` | ✅ Yes |
| `workspaceName` | Log Analytics workspace name | `rdk-tst-workspace` | ✅ Yes |
| `location` | Azure region | `westeurope` | ✅ Yes |
| `pricingTierLogAnalytics` | Pricing tier | `PerGB2018` | ✅ Yes |
| `retentionInDays` | Data retention period | `90` | ✅ Yes |

**Supported Pricing Tiers:**
- `PerGB2018` - Pay-as-you-go per GB
- `CapacityReservation` - Commitment tier (100GB/day minimum)

**Retention Days:**
- Minimum: 30 days
- Maximum: 730 days (2 years)
- Default: 90 days

#### Solutions Section

| Parameter | Description | Default |
|-----------|-------------|---------|
| `enableBehaviorAnalyticsInsights` | Enable UEBA (User and Entity Behavior Analytics) | `false` |
| `enableLogicAppsManagementInsights` | Enable Logic Apps monitoring | `false` |
| `enableDnsAnalytics` | Enable DNS query analytics | `false` |
| `enableContainerInsights` | Enable container monitoring | `false` |
| `enableVMInsights` | Enable VM monitoring | `false` |
| `enableWindowsFirewall` | Enable Windows Firewall logs | `false` |

#### Packages Section

| Parameter | Description | Example |
|-----------|-------------|---------|
| `solutionsPath` | Path to solution packages | `packages` |
| `customerSolutions` | Array of package names to deploy | `["keyvault", "azure-ad"]` |

### GitHub Secrets Configuration

Configure the following secrets in **Settings → Secrets and variables → Actions**:

#### Required Secrets

**1. AZURE_CREDENTIALS**

Service Principal credentials in JSON format:

```json
{
  "clientId": "<service-principal-client-id>",
  "clientSecret": "<service-principal-client-secret>",
  "subscriptionId": "<azure-subscription-id>",
  "tenantId": "<azure-tenant-id>"
}
```

**How to create:**

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "sentinel-deploy-sp" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --sdk-auth

# Output will be in the correct format for GitHub secret
```

**2. AZURE_SUBSCRIPTION**

Your Azure subscription ID:

```
<azure-subscription-id>
```

**How to get:**

```bash
az account show --query id -o tsv
```

### Creating Additional Environments

To create additional environments (e.g., production):

1. **Create new configuration file:**
   ```bash
   cp environments/nonprod.json environments/prod.json
   ```

2. **Update values:**
   ```json
   {
     "LogAnalytics": [{
       "sentinelResourceGroup": "rdk-prod-rg",
       "workspaceName": "rdk-prod-workspace",
       "location": "westeurope",
       "retentionInDays": 365
     }]
   }
   ```

3. **Update workflow to use new file:**
   ```yaml
   # In .github/workflows/deploy-sentinel.yml
   - name: Set Variables
     with:
       filePath: './environments/prod.json'  # Change this
   ```

---

## 🚀 Deployment Process

### Automated Deployment (Recommended)

The deployment is fully automated via GitHub Actions:

#### Step 1: Update Configuration

1. Edit `environments/nonprod.json` with your values
2. Commit and push changes

```bash
git add environments/nonprod.json
git commit -m "Update environment configuration"
git push origin main
```

#### Step 2: Trigger Workflow

The workflow automatically triggers when:
- Changes are pushed to `.github/**` paths
- Manual trigger via GitHub UI

**Manual Trigger:**
1. Go to **Actions** tab in GitHub
2. Select **Build and Publish Sentinel Solutions**
3. Click **Run workflow**
4. Select branch and click **Run workflow**

#### Step 3: Monitor Deployment

1. Navigate to **Actions** tab
2. Click on the running workflow
3. Monitor each job:
   - ✅ `set-variables` - Configuration loaded
   - ✅ `deploy-resources` - Infrastructure created
   - ✅ `deploy_analytics` - Rules deployed

#### Step 4: Verify Deployment

After successful deployment:

1. **Azure Portal Verification:**
   ```
   Azure Portal → Resource Groups → <your-rg-name>
   ```

2. **Sentinel Verification:**
   ```
   Azure Portal → Microsoft Sentinel → <workspace-name>
   - Check Analytics rules
   - Verify data connectors
   ```

3. **CLI Verification:**
   ```bash
   # Verify resource group
   az group show --name rdk-dev-rg
   
   # Verify workspace
   az monitor log-analytics workspace show \
     --resource-group rdk-dev-rg \
     --workspace-name rdk-tst-workspace
   
   # List Sentinel solutions
   az resource list \
     --resource-group rdk-dev-rg \
     --resource-type Microsoft.OperationsManagement/solutions
   ```

### Manual Deployment (Alternative)

For testing or troubleshooting, you can deploy manually using Azure CLI:

#### Prerequisites

```bash
# Login to Azure
az login

# Set subscription
az account set --subscription <subscription-id>

# Verify bicep CLI
az bicep version
```

#### Deployment Steps

**1. Deploy Resource Group:**

```bash
az deployment sub create \
  --name sentinel-rg-deployment \
  --location westeurope \
  --template-file ./resources/resourcegroup.bicep \
  --parameters \
    resourceGroupName=rdk-dev-rg \
    location=westeurope
```

**2. Deploy Log Analytics Workspace:**

```bash
az deployment group create \
  --name sentinel-workspace-deployment \
  --resource-group rdk-dev-rg \
  --template-file ./resources/workspace.bicep \
  --parameters \
    workspaceName=rdk-tst-workspace \
    location=westeurope \
    retentionInDays=90 \
    enableBehaviorAnalyticsInsights=true \
    enableLogicAppsManagementInsights=true \
    enableDnsAnalytics=true \
    enableContainerInsights=true \
    enableVMInsights=true \
    enableWindowsFirewall=false
```

**3. Deploy Solutions (Optional):**

```bash
az deployment group create \
  --name sentinel-solutions-deployment \
  --resource-group rdk-dev-rg \
  --template-file ./resources/solutions.bicep \
  --parameters \
    workspaceName=rdk-tst-workspace \
    location=westeurope \
    enableBehaviorAnalyticsInsights=true \
    enableLogicAppsManagementInsights=true
```

**4. Deploy Analytics Rules:**

For each package in `packages/` directory:

```bash
# Example for keyvault package
# (Requires YAML to ARM conversion first)

# Convert YAML to ARM (manual process)
# Then deploy:
az deployment group create \
  --name sentinel-analytics-deployment \
  --resource-group rdk-dev-rg \
  --template-file ./packages/keyvault/deployment.json \
  --parameters workspace=rdk-tst-workspace
```

### Validation Before Deployment

Before deploying, validate your templates:

```bash
# Validate resource group template
az deployment sub validate \
  --location westeurope \
  --template-file ./resources/resourcegroup.bicep \
  --parameters resourceGroupName=rdk-dev-rg location=westeurope

# Validate workspace template
az deployment group validate \
  --resource-group rdk-dev-rg \
  --template-file ./resources/workspace.bicep \
  --parameters workspaceName=rdk-tst-workspace location=westeurope

# Build bicep (check for errors)
az bicep build --file ./resources/workspace.bicep
```

---

## 🔍 Analytics Rules

### Overview

The `samples/` directory contains **54 pre-built analytics rules** focused on AWS security threats. These rules are written in YAML format and follow Microsoft Sentinel's analytics rule schema.

### Analytics Rule Structure

Example structure of a typical rule:

```yaml
id: 0adab960-5565-4978-ba6d-044553e4acc4
name: Successful API executed from a Tor exit node
description: |
  'A successful API execution was detected from an IP address 
   categorized as a TOR exit node by Threat Intelligence.'
severity: High
status: Available
requiredDataConnectors:
  - connectorId: AWS
    dataTypes:
      - AWSCloudTrail
queryFrequency: 1d
queryPeriod: 1d
triggerOperator: gt
triggerThreshold: 0
tactics:
  - Execution
relevantTechniques:
  - T1204
query: |
  let TorNodes = (
    externaldata (TorIP:string)
    [@'https://firewalliplists.gypthecat.com/lists/kusto/kusto-tor-exit.csv.zip']
    with (ignoreFirstRecord=true)
  );
  AWSCloudTrail
  | where SourceIpAddress in (TorNodes) 
  | where isempty(ErrorCode) and isempty(ErrorMessage)
  | extend UserIdentityUserName = iff(isnotempty(UserIdentityUserName), 
      UserIdentityUserName, tostring(split(UserIdentityArn,'/')[-1]))
  | extend timestamp = TimeGenerated, 
      IPCustomEntity = SourceIpAddress, 
      AccountCustomEntity = UserIdentityUserName
entityMappings:
  - entityType: Account
    fieldMappings:
      - identifier: FullName
        columnName: AccountCustomEntity
  - entityType: IP
    fieldMappings:
      - identifier: Address
        columnName: IPCustomEntity
version: 1.0.0
```

### Available Analytics Rules

The repository includes **54 AWS-focused detection rules** covering:

#### Identity & Access Management (IAM)
- `AWS_ConsoleLogonWithoutMFA.yaml` - Detect console logins without MFA
- `AWS_CreatedCRUDIAMtoPrivilegeEscalation.yaml` - Detect IAM policy privilege escalation
- `AWS_FullAdminPolicyAttachedToRolesUsersGroups.yaml` - Detect full admin policy attachments
- `AWS_CredentialHijack.yaml` - Detect credential hijacking attempts

#### Privilege Escalation
- `AWS_CreatedCloudFormationPolicytoPrivilegeEscalation.yaml`
- `AWS_CreatedCRUDDyanmoDBPolicytoPrivilegeEscalation.yaml`
- `AWS_CreatedCRUDKMSPolicytoPrivilegeEscalation.yaml`
- `AWS_CreatedCRUDS3PolicytoPrivilegeEscalation.yaml`
- `AWS_CreatedCURDLambdaPolicytoPrivilegEscalation.yaml`
- `AWS_CreatedDataPipelinePolicytoPrivilegeEscalation.yaml`
- `AWS_CreatedEC2PolicytoPrivilegeEscalation.yaml`
- `AWS_CreatedGluePolicytoPrivilegeEscalation.yaml`
- `AWS_CreatedLambdaPolicytoPrivilegeEscalation.yaml`
- `AWS_CreatedSSMPolicytoPrivilegeEscalation.yaml`

#### Data Protection & Encryption
- `AWS_CreationofEncryptKeysWithoutMFA.yaml` - KMS key creation without MFA
- `AWS_OverlyPermessiveKMS.yaml` - Overly permissive KMS policies

#### Network Security
- `AWS_ChangeToVPC.yaml` - VPC configuration changes
- `AWS_IngressEgressSecurityGroupChange.yaml` - Security group modifications
- `AWS_LoadBalancerSecGroupChange.yaml` - Load balancer security changes
- `AWS_NetworkACLOpenToAllPorts.yaml` - Network ACL misconfigurations

#### Logging & Monitoring
- `AWS_ClearStopChangeTrailLogs.yaml` - CloudTrail tampering detection
- `AWS_LogTampering.yaml` - General log tampering
- `AWS_GuardDutyDisabled.yaml` - GuardDuty service disabled

#### Database Security
- `AWS_ChangeToRDSDatabase.yaml` - RDS configuration changes
- `AWS_RDSInstancePubliclyExposed.yaml` - Public RDS instances

#### Container Security
- `AWS_ECRContainerHigh.yaml` - ECR container vulnerabilities
- `AWS_ECRImageScanningDisabled.yaml` - ECR scanning disabled

#### Threat Intelligence
- `AWS_APIfromTor.yaml` - API calls from Tor exit nodes
- `AWS_S3BruteForce.yaml` - S3 bucket brute force attempts

#### Command Execution
- `AWS_SuspiciousCommandEC2.yaml` - Suspicious EC2 commands

### Creating Custom Analytics Rules

To create custom analytics rules:

1. **Create YAML file** in `packages/<your-package>/` directory:

```yaml
id: <unique-guid>
name: Your Rule Name
description: |
  'Detailed description of what this rule detects'
severity: Medium  # Low, Medium, High, Informational
status: Available
requiredDataConnectors:
  - connectorId: AzureActiveDirectory
    dataTypes:
      - SigninLogs
queryFrequency: 1h  # How often to run
queryPeriod: 1h     # Time window to query
triggerOperator: gt # gt, lt, eq, ne
triggerThreshold: 0
tactics:
  - InitialAccess
relevantTechniques:
  - T1078
query: |
  SigninLogs
  | where ResultType != 0
  | where UserPrincipalName contains "admin"
  | project TimeGenerated, UserPrincipalName, IPAddress, ResultType
entityMappings:
  - entityType: Account
    fieldMappings:
      - identifier: FullName
        columnName: UserPrincipalName
  - entityType: IP
    fieldMappings:
      - identifier: Address
        columnName: IPAddress
version: 1.0.0
```

2. **Add to environment configuration:**

Update `environments/nonprod.json`:

```json
{
  "packages": [{
    "customerSolutions": [
      "keyvault",
      "your-new-package"  // Add here
    ]
  }]
}
```

3. **Commit and push:**

```bash
git add packages/your-new-package/
git add environments/nonprod.json
git commit -m "Add custom analytics rules"
git push origin main
```

The workflow will automatically:
- Validate KQL syntax
- Check for deprecated functions
- Convert YAML to ARM
- Deploy to Sentinel

### Rule Severity Guidelines

| Severity | Use Case |
|----------|----------|
| **Informational** | FYI alerts, no immediate action needed |
| **Low** | Minor policy violations, informational threats |
| **Medium** | Suspicious activity requiring investigation |
| **High** | Confirmed threats or critical policy violations |

### MITRE ATT&CK Mapping

Common tactics and techniques:

| Tactic | Example Techniques |
|--------|-------------------|
| Initial Access | T1078 - Valid Accounts |
| Execution | T1204 - User Execution |
| Persistence | T1098 - Account Manipulation |
| Privilege Escalation | T1068 - Exploitation for Privilege Escalation |
| Defense Evasion | T1562 - Impair Defenses |
| Credential Access | T1110 - Brute Force |
| Discovery | T1087 - Account Discovery |
| Lateral Movement | T1021 - Remote Services |
| Collection | T1530 - Data from Cloud Storage Object |
| Exfiltration | T1567 - Exfiltration Over Web Service |
| Impact | T1485 - Data Destruction |

---

## 🐛 Troubleshooting

### Common Issues and Solutions

#### Issue 1: Authentication Failed

**Error Message:**
```
Error: Login failed with Error: Please verify AZURE_CREDENTIALS
```

**Solutions:**

1. **Verify secret format:**
   ```bash
   # Recreate service principal with correct format
   az ad sp create-for-rbac \
     --name "sentinel-deploy-sp" \
     --role contributor \
     --scopes /subscriptions/{subscription-id} \
     --sdk-auth
   ```

2. **Check secret configuration:**
   - Go to Settings → Secrets → Actions
   - Verify `AZURE_CREDENTIALS` exists
   - Verify JSON is properly formatted (no extra spaces)

3. **Verify service principal hasn't expired:**
   ```bash
   az ad sp show --id <client-id>
   ```

#### Issue 2: Resource Group Deployment Failed

**Error Message:**
```
Deployment failed. ResourceGroupNotFound
```

**Solutions:**

1. **Verify subscription scope deployment:**
   ```yaml
   # In deploy-sentinel.yml, ensure:
   scope: 'subscription'  # Not 'resourceGroup'
   ```

2. **Check subscription permissions:**
   ```bash
   # Verify service principal has Contributor at subscription level
   az role assignment list \
     --assignee <client-id> \
     --scope /subscriptions/{subscription-id}
   ```

3. **Verify subscription ID:**
   - Check `AZURE_SUBSCRIPTION` secret matches your subscription

#### Issue 3: Workspace Deployment Failed

**Error Message:**
```
InvalidWorkspaceName or LocationNotAvailable
```

**Solutions:**

1. **Workspace naming rules:**
   - 4-63 characters
   - Alphanumeric and hyphens only
   - Must be unique within resource group

2. **Check region availability:**
   ```bash
   # List available regions for Log Analytics
   az provider show \
     --namespace Microsoft.OperationalInsights \
     --query "resourceTypes[?resourceType=='workspaces'].locations" \
     -o table
   ```

3. **Verify location matches resource group:**
   - Workspace location should match resource group location

#### Issue 4: Analytics Deployment Failed

**Error Message:**
```
YAMLToARM conversion failed
```

**Solutions:**

1. **Validate YAML syntax:**
   ```bash
   # Use yamllint or online YAML validator
   yamllint packages/your-package/*.yaml
   ```

2. **Check required fields:**
   ```yaml
   # Minimum required fields:
   id: <guid>
   name: <string>
   severity: <High|Medium|Low|Informational>
   query: |
     <KQL query>
   ```

3. **Validate KQL query:**
   - Test query in Log Analytics workspace
   - Check for syntax errors
   - Verify table names exist

#### Issue 5: KQL Validation Failed

**Error Message:**
```
Deprecated KQL function detected
```

**Solutions:**

1. **Update deprecated functions:**
   ```kql
   # Old → New
   todynamic() → parse_json()
   extractjson() → parse_json()
   ```

2. **Check validation logs:**
   - Go to Actions → Failed workflow
   - Review "Validate Deprecated KQL values" step
   - Update identified functions

#### Issue 6: Matrix Deployment Partially Failed

**Error Message:**
```
Some deployments in matrix failed
```

**Solutions:**

1. **Check individual package logs:**
   - Each matrix job runs independently
   - Review logs for failed package

2. **Verify package structure:**
   ```
   packages/
   └── your-package/
       ├── rule1.yaml
       ├── rule2.yaml
       └── (deployment.json created automatically)
   ```

3. **Re-run failed deployments:**
   - Workflow uses `continue-on-error: true`
   - Fix issues and re-run workflow

### Debugging Tips

#### Enable Debug Logging

Add to workflow file:

```yaml
env:
  ACTIONS_RUNNER_DEBUG: true
  ACTIONS_STEP_DEBUG: true
```

#### Test Locally

```bash
# Test Bicep compilation
az bicep build --file resources/workspace.bicep

# Test deployment in what-if mode
az deployment group what-if \
  --resource-group rdk-dev-rg \
  --template-file resources/workspace.bicep \
  --parameters workspaceName=test-workspace

# Validate JSON configuration
cat environments/nonprod.json | jq .
```

#### Check Azure Activity Log

```bash
# View recent deployments
az monitor activity-log list \
  --resource-group rdk-dev-rg \
  --start-time 2024-10-23T00:00:00Z \
  --query "[].{Time:eventTimestamp, Operation:operationName.value, Status:status.value}" \
  -o table
```

#### Review Sentinel Logs

```kql
// In Log Analytics workspace
LAQueryLogs
| where TimeGenerated > ago(1d)
| where QueryText contains "error" or QueryText contains "fail"
| project TimeGenerated, QueryText, ResponseCode
```

### Getting Help

1. **Check existing issues:**
   [View Issues](../../issues)

2. **Create new issue:**
   - [Bug Report](../../issues/new?template=bug_report.md)
   - [Feature Request](../../issues/new?template=feauture_request.md)

3. **Review workflow logs:**
   - Actions tab → Select workflow run
   - Download logs for detailed analysis

4. **SecureHats Community:**
   - Twitter: [@dijkmanrogier](https://twitter.com/dijkmanrogier)
   - GitHub: [SecureHats](https://github.com/securehats)

---

## ✨ Best Practices

### 1. Version Control

✅ **DO:**
- Commit all configuration changes
- Use descriptive commit messages
- Create feature branches for major changes
- Use pull requests for code review

❌ **DON'T:**
- Commit secrets or credentials
- Push directly to main without testing
- Skip code review for critical changes

### 2. Environment Management

✅ **DO:**
- Maintain separate configurations per environment
- Use consistent naming conventions
- Document environment-specific settings
- Test in non-production first

```
environments/
├── dev.json       # Development
├── nonprod.json   # Non-production/Test
└── prod.json      # Production
```

❌ **DON'T:**
- Use production credentials in dev/test
- Share resources between environments
- Deploy untested changes to production

### 3. Security

✅ **DO:**
- Rotate service principal credentials regularly
- Use least-privilege access principles
- Enable Azure AD Conditional Access
- Monitor service principal usage
- Scan for secrets in code

```bash
# Rotate service principal secret
az ad sp credential reset \
  --id <client-id> \
  --append  # Keeps old credential valid during rotation
```

❌ **DON'T:**
- Store credentials in code or configs
- Grant excessive permissions
- Share service principal credentials
- Disable security features

### 4. Analytics Rules

✅ **DO:**
- Test queries in workspace before deploying
- Use MITRE ATT&CK framework for tactics
- Include entity mappings for investigations
- Set appropriate severity levels
- Document expected false positives

```kql
// Test query performance
SigninLogs
| where TimeGenerated > ago(1d)
| summarize count() by bin(TimeGenerated, 1h)
// Should complete in < 30 seconds
```

❌ **DON'T:**
- Deploy untested queries
- Use overly broad queries (performance impact)
- Ignore false positives
- Set incorrect severity levels

### 5. Naming Conventions

✅ **DO:**
Follow consistent naming:

```
Resource Type       | Pattern                    | Example
--------------------|----------------------------|------------------
Resource Group      | <purpose>-<env>-rg        | sentinel-prod-rg
Workspace           | <purpose>-<env>-workspace | sentinel-prod-workspace
Analytics Rule      | <source>_<description>    | AWS_ConsoleLogonWithoutMFA
Package             | <lowercase-hyphenated>    | azure-firewall
```

### 6. Cost Management

✅ **DO:**
- Monitor Log Analytics ingestion
- Set appropriate retention periods
- Use commitment tiers for predictable workloads
- Review unused analytics rules

```bash
# Check workspace ingestion
az monitor log-analytics workspace show \
  --resource-group rdk-dev-rg \
  --workspace-name rdk-tst-workspace \
  --query "{GB_ingested: '[check in portal]', retention: retentionInDays}"
```

**Cost Optimization:**
- Non-prod: 30-90 day retention
- Production: 90-365 day retention
- Use commitment tiers if ingesting 100GB+/day

❌ **DON'T:**
- Set unnecessary long retention
- Enable all solutions without need
- Ignore cost alerts

### 7. Monitoring & Maintenance

✅ **DO:**
- Monitor workflow execution
- Set up GitHub Action notifications
- Review failed deployments
- Update analytics rules regularly
- Keep Bicep templates updated

```yaml
# Enable workflow notifications
# Settings → Notifications → Actions
- Workflow run failures
- Deployment failures
```

❌ **DON'T:**
- Ignore failed workflows
- Let deprecated rules accumulate
- Skip security updates

### 8. Documentation

✅ **DO:**
- Document custom analytics rules
- Maintain deployment runbooks
- Keep README updated
- Document known issues

❌ **DON'T:**
- Assume self-documenting code
- Skip deployment notes
- Leave outdated documentation

### 9. Testing Strategy

✅ **DO:**
- Validate Bicep templates before deploy
- Test KQL queries in workspace
- Use what-if deployments
- Test in isolated environment

```bash
# What-if deployment
az deployment group what-if \
  --resource-group test-rg \
  --template-file resources/workspace.bicep \
  --parameters @environments/nonprod.json
```

❌ **DON'T:**
- Skip validation steps
- Test in production
- Deploy without review

### 10. Backup & Disaster Recovery

✅ **DO:**
- Export analytics rules periodically
- Document restoration procedures
- Maintain infrastructure as code
- Version control everything

```bash
# Export analytics rules
az sentinel alert-rule list \
  --resource-group rdk-dev-rg \
  --workspace-name rdk-tst-workspace \
  -o json > backup-rules.json
```

❌ **DON'T:**
- Rely solely on Azure portal configurations
- Skip backup procedures
- Forget to test restoration

---

## 📚 Additional Resources

### Microsoft Documentation

- [Microsoft Sentinel Documentation](https://learn.microsoft.com/azure/sentinel/)
- [Log Analytics Workspace](https://learn.microsoft.com/azure/azure-monitor/logs/log-analytics-workspace-overview)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [KQL Query Language](https://learn.microsoft.com/azure/data-explorer/kusto/query/)
- [MITRE ATT&CK Framework](https://attack.mitre.org/)

### SecureHats Resources

- [SecureHats GitHub](https://github.com/securehats)
- [SecureHats Actions Marketplace](https://github.com/marketplace?query=securehats)
- [Twitter: @dijkmanrogier](https://twitter.com/dijkmanrogier)

### GitHub Actions

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Azure Login Action](https://github.com/marketplace/actions/azure-login)
- [ARM Deploy Action](https://github.com/marketplace/actions/deploy-azure-resource-manager-arm-template)

### Community

- [Microsoft Sentinel Community](https://github.com/Azure/Azure-Sentinel)
- [Sentinel GitHub Discussions](https://github.com/Azure/Azure-Sentinel/discussions)
- [Tech Community Blog](https://techcommunity.microsoft.com/t5/microsoft-sentinel-blog/bg-p/MicrosoftSentinelBlog)

---

## 🤝 Contributing

Contributions are welcome! Please see the main [README.md](README.md) for contribution guidelines.

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
[![Good First Issues](https://img.shields.io/github/issues/azurekid/sentinel-deploy/good%20first%20issue?color=important&label=good%20first%20issue&style=flat)](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)

---

## 📄 License

This project is maintained by SecureHats.

For issues or questions, please [create an issue](../../issues/new/choose).

---

**Last Updated:** October 23, 2025  
**Version:** 1.0.0  
**Maintained by:** [SecureHats](https://github.com/securehats)
