@description('name of the log analytics workspace')
param workspaceName string

@description('log retention in days')
param retentionInDays int = 30

param resourceGroupLocation string = resourceGroup().location

resource workspace 'microsoft.operationalinsights/workspaces@2021-06-01' = {
  name: workspaceName
  location: resourceGroupLocation
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource azureSentinelSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SecurityInsights(${workspaceName})'
  plan: {
    name: workspaceName
    promotionCode: ''
    product: 'OMSGallery/SecurityInsights'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: workspace.id
  }
}