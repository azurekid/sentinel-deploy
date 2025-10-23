# Bicep Templates Reference

## Overview

This repository uses Azure Bicep templates for Infrastructure as Code (IaC) deployment. Bicep provides a declarative syntax for deploying Azure resources.

## Templates

### 1. Resource Group (`resources/resourcegroup.bicep`)

**Purpose:** Creates an Azure Resource Group at subscription scope

**Scope:** `subscription`

**File:** `resources/resourcegroup.bicep`

#### Template Content

```bicep
param resourceGroupName string
param location string

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}
```

#### Parameters

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `resourceGroupName` | string | ✅ Yes | Name of the resource group | `rdk-dev-rg` |
| `location` | string | ✅ Yes | Azure region | `westeurope` |

#### Deployment

**Azure CLI:**
```bash
az deployment sub create \
  --name rg-deployment \
  --location westeurope \
  --template-file resources/resourcegroup.bicep \
  --parameters \
    resourceGroupName=rdk-dev-rg \
    location=westeurope
```

**PowerShell:**
```powershell
New-AzSubscriptionDeployment `
  -Name rg-deployment `
  -Location westeurope `
  -TemplateFile resources/resourcegroup.bicep `
  -resourceGroupName rdk-dev-rg `
  -location westeurope
```

#### Resources Created

- 1 Resource Group

#### Naming Conventions

**Resource Group Names:**
- Pattern: `<purpose>-<environment>-rg`
- Examples:
  - `sentinel-dev-rg`
  - `sentinel-prod-rg`
  - `siem-nonprod-rg`

**Supported Locations:**
Common Azure regions:
- `eastus`, `eastus2`
- `westus`, `westus2`, `westus3`
- `centralus`
- `northeurope`, `westeurope`
- `uksouth`, `ukwest`
- `australiaeast`, `australiasoutheast`
- `southeastasia`, `eastasia`

---

### 2. Log Analytics Workspace (`resources/workspace.bicep`)

**Purpose:** Deploys Log Analytics Workspace with Microsoft Sentinel and optional solutions

**Scope:** `resourceGroup`

**File:** `resources/workspace.bicep`

#### Template Content Summary

```bicep
// Parameters
@description('name of the log analytics workspace')
param workspaceName string

@description('log retention in days')
param retentionInDays int = 30

@description('Azure region')
param location string = resourceGroup().location

@description('Feature flags for solutions')
param enableBehaviorAnalyticsInsights bool = false
param enableLogicAppsManagementInsights bool = false
param enableDnsAnalytics bool = false
param enableContainerInsights bool = false
param enableVMInsights bool = false
param enableWindowsFirewall bool = false

// Main workspace
resource workspace 'microsoft.operationalinsights/workspaces@2021-06-01' = { ... }

// Sentinel solution
resource azureSentinelSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = { ... }

// Optional solutions (conditional deployment)
resource behaviorAnalyticsInsightsSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enableBehaviorAnalyticsInsights) { ... }
// ... more solutions

// Sample incident (for testing)
resource sampleIncident 'Microsoft.SecurityInsights/incidents@2022-12-01-preview' = { ... }
```

#### Parameters

| Parameter | Type | Default | Required | Description |
|-----------|------|---------|----------|-------------|
| `workspaceName` | string | - | ✅ Yes | Workspace name (4-63 chars) |
| `retentionInDays` | int | `30` | No | Log retention (30-730 days) |
| `location` | string | Resource group location | No | Azure region |
| `enableBehaviorAnalyticsInsights` | bool | `false` | No | Enable UEBA solution |
| `enableLogicAppsManagementInsights` | bool | `false` | No | Enable Logic Apps monitoring |
| `enableDnsAnalytics` | bool | `false` | No | Enable DNS analytics |
| `enableContainerInsights` | bool | `false` | No | Enable container monitoring |
| `enableVMInsights` | bool | `false` | No | Enable VM monitoring |
| `enableWindowsFirewall` | bool | `false` | No | Enable Windows Firewall logs |

#### Resources Created

**Always Created:**
1. **Log Analytics Workspace**
   - API Version: `2021-06-01`
   - SKU: `PerGB2018` (Pay-as-you-go)
   - Public access: Enabled for ingestion and query

2. **Microsoft Sentinel Solution**
   - API Version: `2015-11-01-preview`
   - Product: `OMSGallery/SecurityInsights`
   - Automatically enables Sentinel on workspace

3. **Sample Incident**
   - API Version: `2022-12-01-preview`
   - Title: "Azure AD is compromised"
   - Severity: High
   - Status: New
   - Purpose: Testing and demonstration

**Conditionally Created:**

4. **Behavior Analytics Insights** (if `enableBehaviorAnalyticsInsights = true`)
   - Product: `OMSGallery/BehaviorAnalyticsInsights`
   - Enables UEBA (User and Entity Behavior Analytics)

5. **Logic Apps Management** (if `enableLogicAppsManagementInsights = true`)
   - Product: `OMSGallery/LogicAppsManagement`
   - Monitors Logic Apps used in Sentinel playbooks

6. **DNS Analytics** (if `enableDnsAnalytics = true`)
   - Product: `OMSGallery/DnsAnalytics`
   - Analyzes DNS query logs

7. **Container Insights** (if `enableContainerInsights = true`)
   - Product: `OMSGallery/ContainerInsights`
   - Monitors Kubernetes/container workloads

8. **VM Insights** (if `enableVMInsights = true`)
   - Product: `OMSGallery/VMInsights`
   - Monitors virtual machine performance

9. **Windows Firewall** (if `enableWindowsFirewall = true`)
   - Product: `OMSGallery/WindowsFirewall`
   - Collects Windows Firewall logs

#### Deployment

**Azure CLI:**
```bash
az deployment group create \
  --resource-group rdk-dev-rg \
  --template-file resources/workspace.bicep \
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

**PowerShell:**
```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName rdk-dev-rg `
  -TemplateFile resources/workspace.bicep `
  -workspaceName rdk-tst-workspace `
  -location westeurope `
  -retentionInDays 90 `
  -enableBehaviorAnalyticsInsights $true `
  -enableVMInsights $true
```

**With Parameter File:**

Create `workspace.parameters.json`:
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "workspaceName": {
      "value": "rdk-tst-workspace"
    },
    "retentionInDays": {
      "value": 90
    },
    "location": {
      "value": "westeurope"
    },
    "enableBehaviorAnalyticsInsights": {
      "value": true
    }
  }
}
```

Deploy:
```bash
az deployment group create \
  --resource-group rdk-dev-rg \
  --template-file resources/workspace.bicep \
  --parameters @workspace.parameters.json
```

#### Workspace Configuration

**Pricing Tiers:**

| Tier | Description | Minimum | Best For |
|------|-------------|---------|----------|
| `PerGB2018` | Pay-as-you-go | No minimum | Variable workloads, testing |
| `CapacityReservation` | Commitment tier | 100GB/day | Predictable workloads, cost savings |

**Retention Periods:**

| Retention | Use Case | Cost Impact |
|-----------|----------|-------------|
| 30 days | Minimum, compliance | Low |
| 90 days | Standard security monitoring | Medium |
| 180 days | Extended analysis | High |
| 365 days | Long-term compliance | Very High |
| 730 days | Maximum, regulatory | Maximum |

**Public Access Settings:**

```bicep
properties: {
  publicNetworkAccessForIngestion: 'Enabled'  // Allow log ingestion
  publicNetworkAccessForQuery: 'Enabled'      // Allow queries
}
```

Change to `'Disabled'` for private endpoint-only access.

#### Sample Incident Details

The template creates a test incident:

```bicep
resource sampleIncident 'Microsoft.SecurityInsights/incidents@2022-12-01-preview' = {
  name: 'sampleIncident(${workspaceName})'
  scope: workspace
  properties: {
    severity: 'High'
    status: 'New'
    title: 'Azure AD is compromised'
  }
}
```

**Purpose:**
- Demonstrates incident structure
- Tests Sentinel functionality
- Can be deleted after validation

**Delete Sample Incident:**
```bash
# List incidents
az sentinel incident list \
  --resource-group rdk-dev-rg \
  --workspace-name rdk-tst-workspace

# Delete specific incident
az sentinel incident delete \
  --resource-group rdk-dev-rg \
  --workspace-name rdk-tst-workspace \
  --incident-id <incident-id>
```

---

### 3. Solutions (`resources/solutions.bicep`)

**Purpose:** Deploy additional Azure Monitor solutions to existing workspace

**Scope:** `resourceGroup`

**File:** `resources/solutions.bicep`

**Note:** Currently commented out in the workflow. Uncomment to enable.

#### Template Content Summary

```bicep
// Parameters
@description('name of the log analytics workspace')
param workspaceName string

@description('Feature flags')
param enableBehaviorAnalyticsInsights bool = false
param enableLogicAppsManagementInsights bool = false
param enableDnsAnalytics bool = false
param enableContainerInsights bool = false
param enableVMInsights bool = false
param enableWindowsFirewall bool = false

param location string = resourceGroup().location

// Reference existing workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2015-11-01-preview' existing = {
  name: workspaceName
}

// Deploy solutions (same as workspace.bicep but references existing workspace)
resource behaviorAnalyticsInsightsSolution '...' = if (enableBehaviorAnalyticsInsights) { ... }
// ... more solutions

// Outputs
output resourceId string = workspace.id
output workspaceId string = workspace.properties.customerId
```

#### Key Differences from workspace.bicep

| Feature | workspace.bicep | solutions.bicep |
|---------|----------------|-----------------|
| Workspace | Creates new | References existing |
| Sentinel | Deploys | Assumes deployed |
| Sample Incident | Creates | Creates |
| Solutions | Optional | Optional |
| Use Case | Initial deployment | Add solutions later |

#### When to Use

✅ **Use solutions.bicep when:**
- Workspace already exists
- Adding solutions after initial deployment
- Separating workspace and solutions deployment
- Testing solutions without recreating workspace

❌ **Don't use when:**
- First-time deployment (use workspace.bicep)
- Workspace doesn't exist yet

#### Deployment

**Azure CLI:**
```bash
az deployment group create \
  --resource-group rdk-dev-rg \
  --template-file resources/solutions.bicep \
  --parameters \
    workspaceName=rdk-tst-workspace \
    enableVMInsights=true \
    enableContainerInsights=true
```

#### Outputs

| Output | Type | Description | Use Case |
|--------|------|-------------|----------|
| `resourceId` | string | Workspace resource ID | Reference in other templates |
| `workspaceId` | string | Workspace ID (GUID) | Configure data connectors |

**Using Outputs:**
```bash
# Capture outputs
outputs=$(az deployment group show \
  --resource-group rdk-dev-rg \
  --name solutions-deployment \
  --query properties.outputs \
  -o json)

# Extract workspace ID
workspaceId=$(echo $outputs | jq -r '.workspaceId.value')
echo "Workspace ID: $workspaceId"
```

---

## Solution Details

### Behavior Analytics Insights (UEBA)

**What it does:**
- User and Entity Behavior Analytics
- Anomaly detection
- Risk scoring for users and entities
- ML-based threat detection

**Data Requirements:**
- Azure AD sign-in logs
- Azure activity logs
- Optional: On-premises AD logs

**Configuration:**
```bicep
param enableBehaviorAnalyticsInsights bool = true
```

**Cost Impact:** Medium (processes large volumes of data)

### Logic Apps Management

**What it does:**
- Monitor Sentinel playbooks
- Track Logic Apps execution
- Performance metrics
- Failure analysis

**Data Requirements:**
- Logic Apps diagnostic logs enabled

**Configuration:**
```bicep
param enableLogicAppsManagementInsights bool = true
```

**Cost Impact:** Low

### DNS Analytics

**What it does:**
- DNS query analysis
- Malicious domain detection
- DNS tunneling detection
- Query performance analysis

**Data Requirements:**
- DNS server logs
- Windows DNS server diagnostic logs

**Configuration:**
```bicep
param enableDnsAnalytics bool = true
```

**Cost Impact:** Medium (depends on DNS query volume)

### Container Insights

**What it does:**
- Kubernetes cluster monitoring
- Container performance metrics
- Node and pod health
- Log collection from containers

**Data Requirements:**
- Azure Kubernetes Service (AKS)
- Container Insights agent installed

**Configuration:**
```bicep
param enableContainerInsights bool = true
```

**Cost Impact:** High (metrics and logs from all containers)

### VM Insights

**What it does:**
- Virtual machine performance monitoring
- Process dependency mapping
- Health monitoring
- Performance metrics

**Data Requirements:**
- VMs with Dependency agent installed
- Log Analytics agent installed

**Configuration:**
```bicep
param enableVMInsights bool = true
```

**Cost Impact:** Medium-High (per VM)

### Windows Firewall

**What it does:**
- Collect Windows Firewall logs
- Analyze blocked connections
- Security policy compliance
- Network threat detection

**Data Requirements:**
- Windows servers
- Firewall logging enabled
- Log Analytics agent installed

**Configuration:**
```bicep
param enableWindowsFirewall bool = true
```

**Cost Impact:** Low-Medium

---

## Validation and Testing

### Validate Bicep Templates

**Check Syntax:**
```bash
# Validate all templates
az bicep build --file resources/resourcegroup.bicep
az bicep build --file resources/workspace.bicep
az bicep build --file resources/solutions.bicep
```

**What-If Deployment:**
```bash
# Resource Group
az deployment sub what-if \
  --location westeurope \
  --template-file resources/resourcegroup.bicep \
  --parameters resourceGroupName=test-rg location=westeurope

# Workspace
az deployment group what-if \
  --resource-group rdk-dev-rg \
  --template-file resources/workspace.bicep \
  --parameters workspaceName=test-workspace
```

**Output shows:**
- Resources to be created (green +)
- Resources to be modified (yellow ~)
- Resources to be deleted (red -)
- No changes (white =)

### Test Deployment

**Create Test Resource Group:**
```bash
az group create --name bicep-test-rg --location westeurope
```

**Deploy Templates:**
```bash
# Deploy workspace
az deployment group create \
  --resource-group bicep-test-rg \
  --template-file resources/workspace.bicep \
  --parameters \
    workspaceName=test-workspace \
    retentionInDays=30 \
    enableBehaviorAnalyticsInsights=false
```

**Verify Deployment:**
```bash
# Check workspace
az monitor log-analytics workspace show \
  --resource-group bicep-test-rg \
  --workspace-name test-workspace

# List solutions
az resource list \
  --resource-group bicep-test-rg \
  --resource-type Microsoft.OperationsManagement/solutions \
  --query "[].{Name:name, Type:type}" \
  -o table
```

**Cleanup:**
```bash
az group delete --name bicep-test-rg --yes --no-wait
```

---

## Customization Examples

### Example 1: Add Custom Tags

Modify templates to include tags:

```bicep
resource workspace 'microsoft.operationalinsights/workspaces@2021-06-01' = {
  name: workspaceName
  location: location
  tags: {
    Environment: 'Production'
    CostCenter: 'IT-Security'
    Owner: 'SOC Team'
    ManagedBy: 'Terraform'
  }
  properties: {
    // ... existing properties
  }
}
```

### Example 2: Change Pricing Tier

Add parameter for pricing tier:

```bicep
@description('Pricing tier for Log Analytics')
@allowed([
  'PerGB2018'
  'CapacityReservation'
])
param pricingTier string = 'PerGB2018'

@description('Capacity reservation level (100-5000 GB/day)')
@minValue(100)
@maxValue(5000)
param capacityReservationLevel int = 100

resource workspace 'microsoft.operationalinsights/workspaces@2021-06-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: pricingTier
      capacityReservationLevel: pricingTier == 'CapacityReservation' ? capacityReservationLevel : null
    }
    // ... other properties
  }
}
```

### Example 3: Private Endpoint Support

Add private endpoint configuration:

```bicep
@description('Enable private endpoint')
param enablePrivateEndpoint bool = false

resource workspace 'microsoft.operationalinsights/workspaces@2021-06-01' = {
  name: workspaceName
  location: location
  properties: {
    // ... other properties
    publicNetworkAccessForIngestion: enablePrivateEndpoint ? 'Disabled' : 'Enabled'
    publicNetworkAccessForQuery: enablePrivateEndpoint ? 'Disabled' : 'Enabled'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = if (enablePrivateEndpoint) {
  name: '${workspaceName}-pe'
  location: location
  properties: {
    subnet: {
      id: subnetId  // Add parameter for subnet ID
    }
    privateLinkServiceConnections: [
      {
        name: '${workspaceName}-plsc'
        properties: {
          privateLinkServiceId: workspace.id
          groupIds: [
            'azuremonitor'
          ]
        }
      }
    ]
  }
}
```

### Example 4: Data Export Rules

Add data export to storage account:

```bicep
@description('Storage account resource ID for export')
param storageAccountId string = ''

resource dataExport 'Microsoft.OperationalInsights/workspaces/dataExports@2020-08-01' = if (!empty(storageAccountId)) {
  parent: workspace
  name: 'export-to-storage'
  properties: {
    destination: {
      resourceId: storageAccountId
    }
    tableNames: [
      'SecurityEvent'
      'Syslog'
      'SigninLogs'
    ]
    enable: true
  }
}
```

---

## Best Practices

### 1. Parameter Validation

Use decorators for validation:

```bicep
@description('Workspace name')
@minLength(4)
@maxLength(63)
param workspaceName string

@description('Retention in days')
@minValue(30)
@maxValue(730)
param retentionInDays int = 90

@description('Azure region')
@allowed([
  'eastus'
  'westeurope'
  'westus2'
])
param location string
```

### 2. Output Important Values

```bicep
output workspaceName string = workspace.name
output workspaceId string = workspace.properties.customerId
output resourceId string = workspace.id
output location string = workspace.location
```

### 3. Use Resource References

```bicep
// Reference existing resources
resource existingRg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

// Use in other resources
resource workspace '...' = {
  location: existingRg.location
}
```

### 4. Conditional Deployment

```bicep
// Only deploy if condition is met
resource vmInsights '...' = if (enableVMInsights && !empty(workspaceName)) {
  // ... resource definition
}
```

### 5. Naming Conventions

```bicep
var workspaceFullName = '${prefix}-${environment}-workspace'
var rgName = '${prefix}-${environment}-rg'

resource workspace '...' = {
  name: workspaceFullName
}
```

---

## Troubleshooting

### Common Errors

#### Error: InvalidWorkspaceName

```
Code: InvalidWorkspaceName
Message: Workspace name must be 4-63 characters
```

**Solution:**
- Check workspace name length
- Use only alphanumeric and hyphens
- No special characters

#### Error: SubscriptionNotRegistered

```
Code: SubscriptionNotRegistered
Message: Microsoft.OperationalInsights not registered
```

**Solution:**
```bash
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace Microsoft.OperationsManagement
az provider register --namespace Microsoft.SecurityInsights
```

#### Error: LocationNotAvailable

```
Code: LocationNotAvailable
Message: Location not available for resource type
```

**Solution:**
```bash
# Check available regions
az provider show \
  --namespace Microsoft.OperationalInsights \
  --query "resourceTypes[?resourceType=='workspaces'].locations"
```

#### Error: RetentionInDaysInvalid

```
Code: RetentionInDaysInvalid
Message: Retention must be between 30 and 730 days
```

**Solution:**
- Update `retentionInDays` parameter
- Minimum: 30 days
- Maximum: 730 days (2 years)

---

## Additional Resources

- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Log Analytics REST API](https://learn.microsoft.com/rest/api/loganalytics/)
- [Sentinel ARM Template Reference](https://learn.microsoft.com/azure/templates/microsoft.securityinsights/allversions)
- [Azure Resource Manager Templates](https://learn.microsoft.com/azure/azure-resource-manager/templates/)

---

**Last Updated:** October 23, 2025  
**Version:** 1.0.0
