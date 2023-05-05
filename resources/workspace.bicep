@description('name of the log analytics workspace')
param workspaceName string

@description('log retention in days')
param retentionInDays int = 30

@description('sku of the log analytics workspace')
param skuLevel string = 'PerGB2018'

param resourceGroupLocation string = resourceGroup().location

resource workspace 'microsoft.operationalinsights/workspaces@2021-06-01' = {
  name: workspaceName
  location: resourceGroupLocation
  properties: {
    sku: skuLevel
    retentionInDays: retentionInDays
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}