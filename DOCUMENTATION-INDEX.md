# Documentation Index

## 📚 Complete Documentation Suite

This repository includes comprehensive documentation for deploying Microsoft Sentinel using GitHub Actions and Azure Bicep templates.

---

## 📖 Available Documentation

### 1. [QUICK-START.md](./QUICK-START.md) ⚡
**5-minute setup guide**

Perfect for: Getting started quickly

**Contents:**
- Service Principal setup
- GitHub Secrets configuration
- Environment configuration
- Quick deployment steps
- Verification commands

**Start here if:** You want to deploy immediately

---

### 2. [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md) 📘
**Comprehensive deployment documentation**

Perfect for: Understanding the complete system

**Contents:**
- Architecture overview
- Prerequisites and requirements
- Repository structure
- GitHub Actions workflows explained
- Configuration reference
- Deployment process (automated & manual)
- Analytics rules catalog (54 AWS rules)
- Troubleshooting guide
- Best practices
- Cost optimization

**Start here if:** You want complete understanding before deploying

---

### 3. [WORKFLOWS-REFERENCE.md](./WORKFLOWS-REFERENCE.md) ⚙️
**GitHub Actions technical reference**

Perfect for: Customizing workflows

**Contents:**
- Workflow trigger configurations
- Job-by-job breakdown
- SecureHats actions explained
- Matrix deployment strategy
- Secrets and permissions
- Execution flow diagrams
- Customization examples
- Performance optimization
- Security best practices

**Start here if:** You need to modify or troubleshoot workflows

---

### 4. [BICEP-REFERENCE.md](./BICEP-REFERENCE.md) 🔷
**Bicep templates technical reference**

Perfect for: Infrastructure customization

**Contents:**
- Template-by-template documentation
- Parameter reference
- Resource details
- Deployment commands (CLI & PowerShell)
- Solution descriptions and costs
- Validation and testing
- Customization examples
- Troubleshooting

**Start here if:** You need to customize Azure infrastructure

---

## 🎯 Quick Navigation by Task

### I want to...

#### Deploy Sentinel for the first time
1. Read: [QUICK-START.md](./QUICK-START.md) (5 min)
2. Follow: Steps 1-5
3. Verify: Azure Portal

#### Understand how everything works
1. Read: [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md) (30 min)
2. Review: Architecture section
3. Explore: Repository structure

#### Customize the workflows
1. Read: [WORKFLOWS-REFERENCE.md](./WORKFLOWS-REFERENCE.md)
2. Find: Job you want to modify
3. Apply: Customization examples

#### Change Azure infrastructure
1. Read: [BICEP-REFERENCE.md](./BICEP-REFERENCE.md)
2. Find: Template to modify
3. Test: What-if deployment
4. Apply: Changes

#### Add custom analytics rules
1. Read: [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md) → Analytics Rules
2. Create: YAML file in `packages/`
3. Update: Environment config
4. Deploy: Push to GitHub

#### Troubleshoot deployment issues
1. Read: [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md) → Troubleshooting
2. Check: Common issues
3. Review: Workflow logs
4. Apply: Solutions

#### Add a new environment (production)
1. Read: [WORKFLOWS-REFERENCE.md](./WORKFLOWS-REFERENCE.md) → Customization Examples
2. Create: `environments/prod.json`
3. Duplicate: Workflow for production
4. Configure: GitHub environment protection

#### Optimize costs
1. Read: [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md) → Best Practices
2. Review: Cost Management section
3. Adjust: Retention periods
4. Disable: Unused solutions

---

## 📊 Documentation Structure

```
Documentation Suite
│
├── QUICK-START.md (⚡ Fast track)
│   └── For: Immediate deployment
│
├── DEPLOYMENT-GUIDE.md (📘 Complete guide)
│   ├── Overview & Architecture
│   ├── Prerequisites
│   ├── Configuration
│   ├── Deployment Process
│   ├── Analytics Rules
│   ├── Troubleshooting
│   └── Best Practices
│
├── WORKFLOWS-REFERENCE.md (⚙️ Technical deep-dive)
│   ├── deploy-sentinel.yml breakdown
│   ├── analytics.yaml breakdown
│   ├── Job execution flow
│   ├── Customization examples
│   └── Security practices
│
└── BICEP-REFERENCE.md (🔷 Infrastructure guide)
    ├── resourcegroup.bicep
    ├── workspace.bicep
    ├── solutions.bicep
    ├── Parameter reference
    ├── Customization examples
    └── Troubleshooting
```

---

## 🔍 Finding Specific Information

### Configuration

| Topic | Document | Section |
|-------|----------|---------|
| Environment config (JSON) | DEPLOYMENT-GUIDE.md | Configuration |
| GitHub Secrets | QUICK-START.md | Step 2 |
| Workflow parameters | WORKFLOWS-REFERENCE.md | Job Details |
| Bicep parameters | BICEP-REFERENCE.md | Parameters |

### Deployment

| Topic | Document | Section |
|-------|----------|---------|
| Quick deployment | QUICK-START.md | Steps 1-5 |
| Automated deployment | DEPLOYMENT-GUIDE.md | Deployment Process → Automated |
| Manual deployment | DEPLOYMENT-GUIDE.md | Deployment Process → Manual |
| Validation | BICEP-REFERENCE.md | Validation and Testing |

### Customization

| Topic | Document | Section |
|-------|----------|---------|
| Add analytics rules | DEPLOYMENT-GUIDE.md | Analytics Rules → Creating Custom |
| Modify workflows | WORKFLOWS-REFERENCE.md | Customization Examples |
| Change infrastructure | BICEP-REFERENCE.md | Customization Examples |
| Add solutions | BICEP-REFERENCE.md | Solution Details |

### Troubleshooting

| Topic | Document | Section |
|-------|----------|---------|
| Deployment errors | DEPLOYMENT-GUIDE.md | Troubleshooting |
| Workflow failures | WORKFLOWS-REFERENCE.md | Troubleshooting Workflows |
| Bicep errors | BICEP-REFERENCE.md | Troubleshooting |
| Analytics validation | WORKFLOWS-REFERENCE.md | Analytics Validation |

---

## 💡 Tips for Using This Documentation

### For Beginners

1. **Start with QUICK-START.md**
   - Complete the 5-minute setup
   - Get a working deployment first

2. **Then read DEPLOYMENT-GUIDE.md**
   - Understand what you deployed
   - Learn best practices

3. **Explore other docs as needed**
   - When you need customization
   - When troubleshooting issues

### For Experienced Users

1. **Use as reference material**
   - Jump to specific sections
   - Find exact parameters needed

2. **Focus on customization sections**
   - Workflows for CI/CD changes
   - Bicep for infrastructure changes

3. **Leverage troubleshooting guides**
   - Quick problem resolution
   - Known issues and solutions

### For Team Collaboration

1. **Share QUICK-START.md** with new team members
2. **Reference DEPLOYMENT-GUIDE.md** for runbooks
3. **Use WORKFLOWS-REFERENCE.md** for change reviews
4. **Consult BICEP-REFERENCE.md** for infrastructure reviews

---

## 🔄 Document Versions

All documents are version controlled with the repository.

**Current Version:** 1.0.0  
**Last Updated:** October 23, 2025

To see document history:
```bash
git log --follow DEPLOYMENT-GUIDE.md
```

---

## 📝 Contributing to Documentation

Found an issue or want to improve the docs?

1. **For typos/errors:**
   - Create issue: [Bug Report](../../issues/new?template=bug_report.md)
   - Or submit PR with fix

2. **For improvements:**
   - Create issue: [Feature Request](../../issues/new?template=feauture_request.md)
   - Describe what's unclear or missing

3. **For new sections:**
   - Discuss in issue first
   - Submit PR with changes
   - Include examples and explanations

---

## 🆘 Still Need Help?

### Documentation doesn't answer your question?

1. **Check existing issues:**
   [View Issues](../../issues)

2. **Search discussions:**
   Look for similar questions

3. **Create new issue:**
   - [Bug Report](../../issues/new?template=bug_report.md) - For errors
   - [Feature Request](../../issues/new?template=feauture_request.md) - For improvements

4. **Community support:**
   - Twitter: [@dijkmanrogier](https://twitter.com/dijkmanrogier)
   - GitHub: [SecureHats](https://github.com/securehats)

---

## 📚 External Resources

### Microsoft Documentation

- [Microsoft Sentinel Docs](https://learn.microsoft.com/azure/sentinel/)
- [Log Analytics Docs](https://learn.microsoft.com/azure/azure-monitor/logs/)
- [Bicep Docs](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [KQL Reference](https://learn.microsoft.com/azure/data-explorer/kusto/query/)

### GitHub Documentation

- [GitHub Actions Docs](https://docs.github.com/actions)
- [GitHub Secrets](https://docs.github.com/actions/security-guides/encrypted-secrets)
- [Workflow Syntax](https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions)

### SecureHats

- [SecureHats GitHub](https://github.com/securehats)
- [SecureHats Actions](https://github.com/marketplace?query=securehats)
- [Community Resources](https://twitter.com/dijkmanrogier)

---

## ✅ Documentation Checklist

Before deploying, make sure you've:

- [ ] Read [QUICK-START.md](./QUICK-START.md)
- [ ] Created Service Principal
- [ ] Configured GitHub Secrets
- [ ] Updated environment configuration
- [ ] Understood the deployment process
- [ ] Reviewed [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md) troubleshooting
- [ ] Bookmarked relevant reference documents

---

**Happy Deploying! 🚀**

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
[![Documentation](https://img.shields.io/badge/docs-complete-success.svg)](./DEPLOYMENT-GUIDE.md)

---

*Maintained by [SecureHats](https://github.com/securehats)*  
*Last Updated: October 23, 2025*
