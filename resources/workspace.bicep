@description('name of the log analytics workspace')
param workspaceName string

@description('log retention in days')
param retentionInDays int = 30

@description('sku of the log analytics workspace')
param sku string = 'PerGB2018'

param resourceGroupLocation string = resourceGroup().location

resource workspace 'Microsoft.OperationalInsights/workspaces@2015-11-01-preview' = {
  name: workspaceName
  location: resourceGroupLocation
  properties: {
    retentionInDays: retentionInDays
    sku: {
      name: sku
    }
  }
}

resource SecurityInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SecurityInsights(${workspaceName})'
  location: resourceGroupLocation
  plan: {
    name: 'SecurityInsights(${workspaceName})'
    product: 'OMSGallery/SecurityInsights'
    publisher: 'Microsoft'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: workspace.id
  }
}

resource workspaceName_SecurityInsightsSecurityEventCollectionConfiguration 'Microsoft.OperationalInsights/workspaces/dataSources@2020-03-01-preview' = {
  parent: workspace
  name: 'SecurityInsightsSecurityEventCollectionConfiguration'
  kind: 'SecurityInsightsSecurityEventCollectionConfiguration'
  properties: {
    tier: 'All'
    tierSetMethod: 'Custom'
  }
}