![logo](./media/sh-banner.png)

# Microsoft Sentinel Deployment Automation

[![SecureHats](https://img.shields.io/badge/SecureHats-community-green.svg)](https://twitter.com/dijkmanrogier)
[![Maintenance](https://img.shields.io/maintenance/yes/2025.svg?style=flat-square)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
[![Good First Issues](https://img.shields.io/github/issues/securehats/toolbox/good%20first%20issue?color=important&label=good%20first%20issue&style=flat)](https://github.com/securehats/toolbox/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
[![Needs Feedback](https://img.shields.io/github/issues/securehats/toolbox/needs%20feedback?color=blue&label=needs%20feedback%20&style=flat)](https://github.com/securehats/toolbox/issues?q=is%3Aopen+is%3Aissue+label%3A%22needs+feedback%22)

---

## 🎯 Overview

Automated deployment of **Microsoft Sentinel** and security content using **GitHub Actions** and **Azure Bicep** templates. This repository provides a complete Infrastructure as Code (IaC) solution for deploying and managing Sentinel workspaces with pre-built analytics rules.

### Key Features

✅ **Automated Infrastructure Deployment** - Resource Group, Log Analytics, Sentinel  
✅ **CI/CD with GitHub Actions** - Automated workflows for deployment and validation  
✅ **54 Pre-built Analytics Rules** - AWS security detection rules included  
✅ **Bicep Templates** - Modern IaC for Azure resources  
✅ **Validation Pipeline** - KQL syntax and rule structure validation  
✅ **Multi-Environment Support** - Separate configs for dev/prod  
✅ **SecureHats Actions** - Purpose-built deployment tools  

---

## 🚀 Quick Start

Get up and running in 5 minutes:

1. **Create Service Principal:**
   ```bash
   az ad sp create-for-rbac --name "sentinel-deploy-sp" \
     --role contributor \
     --scopes /subscriptions/{subscription-id} \
     --sdk-auth
   ```

2. **Configure GitHub Secrets:**
   - `AZURE_CREDENTIALS` - Output from step 1
   - `AZURE_SUBSCRIPTION` - Your subscription ID

3. **Update Configuration:**
   Edit `environments/nonprod.json` with your values

4. **Deploy:**
   Push to GitHub or manually trigger workflow

👉 **Full guide:** [QUICK-START.md](./QUICK-START.md)

---

## 📚 Documentation

| Document | Description | Best For |
|----------|-------------|----------|
| **[📋 Documentation Index](./DOCUMENTATION-INDEX.md)** | Navigation guide to all docs | Finding what you need |
| **[⚡ Quick Start Guide](./QUICK-START.md)** | 5-minute setup | Getting started fast |
| **[📘 Deployment Guide](./DEPLOYMENT-GUIDE.md)** | Complete documentation | Understanding everything |
| **[⚙️ Workflows Reference](./WORKFLOWS-REFERENCE.md)** | GitHub Actions deep-dive | Customizing workflows |
| **[🔷 Bicep Reference](./BICEP-REFERENCE.md)** | Infrastructure templates | Customizing Azure resources |

### Quick Links

- **New to this repo?** → Start with [QUICK-START.md](./QUICK-START.md)
- **Want full details?** → Read [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)
- **Need to troubleshoot?** → Check [DEPLOYMENT-GUIDE.md#troubleshooting](./DEPLOYMENT-GUIDE.md#troubleshooting)
- **Customizing workflows?** → See [WORKFLOWS-REFERENCE.md](./WORKFLOWS-REFERENCE.md)
- **Modifying infrastructure?** → See [BICEP-REFERENCE.md](./BICEP-REFERENCE.md)

---

## 🏗️ Architecture

```
┌─────────────────────┐
│   GitHub Push       │
│   (Trigger)         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  GitHub Actions     │
│  - Load Config      │
│  - Deploy Infra     │
│  - Deploy Rules     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Azure Resources   │
│  - Resource Group   │
│  - Log Analytics    │
│  - Sentinel         │
│  - Analytics Rules  │
└─────────────────────┘
```

---

## 📂 Repository Structure

```
sentinel-deploy/
├── .github/workflows/          # GitHub Actions workflows
│   ├── deploy-sentinel.yml    # Infrastructure & content deployment
│   └── analytics.yaml          # Analytics rule validation
├── environments/               # Environment configurations
│   └── nonprod.json           # Non-production config
├── resources/                  # Bicep templates
│   ├── resourcegroup.bicep    # Resource group deployment
│   ├── workspace.bicep        # Log Analytics + Sentinel
│   └── solutions.bicep        # Optional Azure solutions
├── packages/                   # Custom solution packages
│   └── README.md
├── samples/                    # 54 pre-built analytics rules
│   └── AWS_*.yaml             # AWS security detections
└── Documentation files
    ├── QUICK-START.md
    ├── DEPLOYMENT-GUIDE.md
    ├── WORKFLOWS-REFERENCE.md
    ├── BICEP-REFERENCE.md
    └── DOCUMENTATION-INDEX.md
```

---

## ⚙️ What Gets Deployed

### Infrastructure (via Bicep)

1. **Azure Resource Group**
2. **Log Analytics Workspace**
   - Pricing: PerGB2018 (configurable)
   - Retention: 90 days (configurable: 30-730)
3. **Microsoft Sentinel**
4. **Optional Solutions** (configurable):
   - Behavior Analytics Insights (UEBA)
   - Logic Apps Management
   - DNS Analytics
   - Container Insights
   - VM Insights
   - Windows Firewall

### Content (via GitHub Actions)

- **54 AWS Security Detection Rules**
  - Identity & Access Management
  - Privilege Escalation
  - Data Protection
  - Network Security
  - Logging & Monitoring
  - Database Security
  - Container Security
  - Threat Intelligence

---

## 🔧 Configuration

Environment configuration is managed in `environments/nonprod.json`:

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

**Configuration Guide:** [DEPLOYMENT-GUIDE.md#configuration](./DEPLOYMENT-GUIDE.md#configuration)

---

## 🔄 GitHub Actions Workflows

### 1. Deploy Sentinel (`deploy-sentinel.yml`)

**Triggers:** Changes to `.github/**`

**Jobs:**
1. **set-variables** - Load configuration from JSON
2. **deploy-resources** - Deploy Azure infrastructure
3. **deploy_analytics** - Deploy analytics rules (matrix strategy)

**Details:** [WORKFLOWS-REFERENCE.md](./WORKFLOWS-REFERENCE.md)

### 2. Analytics Validation (`analytics.yaml`)

**Triggers:** Changes to `packages/**`

**Validation:**
- Deprecated KQL functions check
- YAML structure validation
- Required fields verification
- Syntax checking

**Details:** [WORKFLOWS-REFERENCE.md#analytics-validation](./WORKFLOWS-REFERENCE.md)

---

## 🛠️ Usage Examples

### Deploy to Azure

```bash
# Update configuration
vim environments/nonprod.json

# Commit and push (triggers workflow)
git add environments/nonprod.json
git commit -m "Configure environment"
git push origin main

# Or trigger manually via GitHub UI
# Actions → Deploy Sentinel → Run workflow
```

### Add Custom Analytics Rule

```bash
# Create package directory
mkdir -p packages/my-rules

# Create rule file
cat > packages/my-rules/my-rule.yaml << EOF
id: $(uuidgen)
name: My Custom Detection Rule
severity: Medium
status: Available
query: |
  SecurityEvent
  | where EventID == 4625
  | summarize count() by Account
EOF

# Update environment config
# Add "my-rules" to customerSolutions array

# Commit and deploy
git add packages/my-rules/
git commit -m "Add custom analytics rule"
git push origin main
```

### Manual Deployment (CLI)

```bash
# Login
az login

# Deploy resource group
az deployment sub create \
  --location westeurope \
  --template-file resources/resourcegroup.bicep \
  --parameters resourceGroupName=rdk-dev-rg location=westeurope

# Deploy workspace
az deployment group create \
  --resource-group rdk-dev-rg \
  --template-file resources/workspace.bicep \
  --parameters workspaceName=rdk-tst-workspace
```

---

## 🐛 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Authentication failed | Check `AZURE_CREDENTIALS` secret format |
| Workspace deployment failed | Verify workspace name (4-63 chars, alphanumeric) |
| Analytics deployment failed | Validate YAML syntax and KQL queries |
| Workflow not triggering | Check path filters in workflow file |

**Full troubleshooting guide:** [DEPLOYMENT-GUIDE.md#troubleshooting](./DEPLOYMENT-GUIDE.md#troubleshooting)

---

## 🔒 Security

- **Secrets Management:** Store credentials in GitHub Secrets
- **Least Privilege:** Service Principal with minimal required permissions
- **Code Review:** Use pull requests for changes
- **Validation:** Automated checks before deployment

**Security best practices:** [WORKFLOWS-REFERENCE.md#security-best-practices](./WORKFLOWS-REFERENCE.md#security-best-practices)

---

## 🤝 Contributing

Contributions welcome! Please follow these guidelines:

1. **Fork the repository**
2. **Create feature branch:** `git checkout -b feature/my-feature`
3. **Commit changes:** `git commit -m "Add my feature"`
4. **Push to branch:** `git push origin feature/my-feature`
5. **Open Pull Request**

### What to Contribute

- 🐛 Bug fixes
- 📝 Documentation improvements
- ✨ New analytics rules
- 🔧 Workflow enhancements
- 💡 Feature suggestions

---

## 📊 Project Status

- **Version:** 1.0.0
- **Last Updated:** October 23, 2025
- **Status:** ✅ Active Development
- **License:** MIT (see LICENSE file)

---

## 💬 Support

### Need Help?

1. **Check Documentation:** [DOCUMENTATION-INDEX.md](./DOCUMENTATION-INDEX.md)
2. **Search Issues:** [View Issues](../../issues)
3. **Ask Questions:** [Create Issue](../../issues/new/choose)
4. **Community:** [@dijkmanrogier](https://twitter.com/dijkmanrogier)

### Report Issues

- **Bug Report:** [Template](../../issues/new?template=bug_report.md)
- **Feature Request:** [Template](../../issues/new?template=feauture_request.md)

---

## 📖 Additional Resources

- [Microsoft Sentinel Documentation](https://learn.microsoft.com/azure/sentinel/)
- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [KQL Query Language](https://learn.microsoft.com/azure/data-explorer/kusto/query/)
- [SecureHats Community](https://github.com/securehats)

---

## 👏 Acknowledgments

- **SecureHats** - Community and tools
- **Microsoft Sentinel Team** - Product and documentation
- **Contributors** - Thank you for your contributions!

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ by [SecureHats](https://github.com/securehats)**

[![GitHub stars](https://img.shields.io/github/stars/azurekid/sentinel-deploy?style=social)](../../stargazers)
[![GitHub forks](https://img.shields.io/github/forks/azurekid/sentinel-deploy?style=social)](../../network/members)

</div>
