# Quick Start Guide - Microsoft Sentinel Deployment

## 🚀 5-Minute Setup

### 1. Create Service Principal

```bash
az ad sp create-for-rbac \
  --name "sentinel-deploy-sp" \
  --role contributor \
  --scopes /subscriptions/{your-subscription-id} \
  --sdk-auth
```

Copy the entire JSON output.

### 2. Configure GitHub Secrets

Go to **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Create two secrets:

| Secret Name | Value |
|-------------|-------|
| `AZURE_CREDENTIALS` | Paste the entire JSON from step 1 |
| `AZURE_SUBSCRIPTION` | Your subscription ID |

### 3. Update Environment Configuration

Edit `environments/nonprod.json`:

```json
{
  "LogAnalytics": [
    {
      "sentinelResourceGroup": "your-rg-name",
      "workspaceName": "your-workspace-name",
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
    "enableWindowsFirewall": false
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

### 4. Commit and Push

```bash
git add environments/nonprod.json
git commit -m "Configure environment"
git push origin main
```

### 5. Trigger Deployment

Go to **Actions** → **Build and Publish Sentinel Solutions** → **Run workflow**

## ✅ Verify Deployment

```bash
# Login
az login

# Check resource group
az group show --name your-rg-name

# Check workspace
az monitor log-analytics workspace show \
  --resource-group your-rg-name \
  --workspace-name your-workspace-name
```

Or visit Azure Portal → Microsoft Sentinel → your workspace

## 📋 What Gets Deployed

- ✅ Resource Group
- ✅ Log Analytics Workspace
- ✅ Microsoft Sentinel
- ✅ Optional Solutions (based on config)
- ✅ Analytics Rules (from packages)

## 🆘 Need Help?

- Full guide: [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)
- Issues: [Create Issue](../../issues/new/choose)
- Community: [@dijkmanrogier](https://twitter.com/dijkmanrogier)

## 📊 Architecture Overview

```
GitHub Push → GitHub Actions → Azure Deployment
                    ↓
            ┌───────────────┐
            │ Set Variables │ (Load config from JSON)
            └───────┬───────┘
                    ↓
            ┌───────────────┐
            │ Deploy Infra  │ (Resource Group → Workspace → Sentinel)
            └───────┬───────┘
                    ↓
            ┌───────────────┐
            │ Deploy Rules  │ (Validate → Convert → Deploy)
            └───────────────┘
```

## 🔧 Common Customizations

### Change Azure Region

Update `location` in `environments/nonprod.json`:

```json
"location": "eastus"  // or westeurope, westus2, etc.
```

### Add Custom Analytics Rules

1. Create package directory: `mkdir -p packages/my-package`
2. Add YAML rules to `packages/my-package/*.yaml`
3. Update config:

```json
"customerSolutions": [
  "my-package"  // Add your package name
]
```

### Adjust Log Retention

Update `retentionInDays` (minimum 30, maximum 730):

```json
"retentionInDays": 180  // 6 months
```

## 📖 Next Steps

1. **Review Deployment:** Check Azure Portal
2. **Configure Data Connectors:** Enable data sources in Sentinel
3. **Review Analytics Rules:** Customize detection logic
4. **Set Up Automation:** Configure playbooks and incident response
5. **Monitor Costs:** Review Log Analytics ingestion

---

**Full Documentation:** [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)
