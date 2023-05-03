@description('Location for all resources.')
param location string = resourceGroup().location
param logAnalyticsName string

@description('Specifies the service tier of the workspace: CapacityReservation, Standalone, PerNode, Free, Pay-as-you-go.')
@allowed([
  'CapacityReservation'
  'PerGB2018'
  'Free'
  'Standalone'
  'Standard'
  'Premium'
  'PerNode'
  'LACluster'
])
param pricingTierLogAnalytics string = 'PerGB2018'

@description('Enable custom pricing tier for Sentinel, default false.')
param pricingTierSentinel bool = false

@description('Capacity reservation level which is used together with pricingTier capacityreservation for Log Analytics.')
@allowed([
  100
  200
  300
  400
  500
  1000
  2000
  5000
])
param capacityReservationLevelLogAnalytics int = 100

@description('Capacity reservation level which is used together with pricingTier capacityreservation for Sentinel.')
@allowed([
  100
  200
  300
  400
  500
  1000
  2000
  5000
])
param capacityReservationLevelSentinel int = 100

@description('How many days data should be retained')
param retentionInDays int = 90

@description('Option to enable the Microsoft Behavior Analytics Insights Solution.')
param enableBehaviorAnalyticsInsights bool = false

@description('Option to enable the Logic Apps Management Insights Solution')
param enableLogicAppsManagementInsights bool = false

@description('Option to enable the Microsoft DNS Analytics Solution.')
param enableDnsAnalytics bool = false

@description('Option to enable the Microsoft Container Insights Solution.')
param enableContainerInsights bool = false

@description('Option to enable the Microsoft VM Insights Solution.')
param enableVMInsights bool = false

@description('Option to enable the Microsoft Windows Firewall Solution.')
param enableWindowsFirewall bool = false

var azureSentinelSolutionName = 'SecurityInsights(${logAnalyticsName})'
var skuLevel = ((toLower(pricingTierLogAnalytics) == 'capacityreservation') ? json('{"name":"${pricingTierLogAnalytics}","capacityReservationLevel":${capacityReservationLevelLogAnalytics}}') : json('{"name":"${pricingTierLogAnalytics}"}'))
var sentinelSku = (pricingTierSentinel ? json('{"name":"CapacityReservation","capacityReservationLevel":${capacityReservationLevelSentinel}}') : json('{"name":"PerGB"}'))
var dnsAnalyticsSolutionName = 'DnsAnalytics(${logAnalyticsName})'
var containerInsightsSolutionName = 'ContainerInsights(${logAnalyticsName})'
var behaviorAnalyticsInsightsSolutionName = 'BehaviorAnalyticsInsights(${logAnalyticsName})'
var vmInsightsSolutionName = 'VMInsights(${logAnalyticsName})'
var windowsFirewallSolutionName = 'WindowsFirewall(${logAnalyticsName})'
var logicAppsManagementInsightsSolutionName = 'LogicAppsManagement(${logAnalyticsName})'

resource logAnalytics 'microsoft.operationalinsights/workspaces@2021-06-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: skuLevel
    retentionInDays: retentionInDays
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource azureSentinelSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: azureSentinelSolutionName
  location: location
  plan: {
    name: azureSentinelSolutionName
    promotionCode: ''
    product: 'OMSGallery/SecurityInsights'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: logAnalytics.id
  }
}

resource behaviorAnalyticsInsightsSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enableBehaviorAnalyticsInsights) {
  name: behaviorAnalyticsInsightsSolutionName
  location: location
  plan: {
    name: behaviorAnalyticsInsightsSolutionName
    promotionCode: ''
    product: 'OMSGallery/BehaviorAnalyticsInsights'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: logAnalytics.id
  }
}

resource logicAppsManagementInsightsSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enableLogicAppsManagementInsights) {
  name: logicAppsManagementInsightsSolutionName
  location: location
  plan: {
    name: logicAppsManagementInsightsSolutionName
    promotionCode: ''
    product: 'OMSGallery/LogicAppsManagement'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: logAnalytics.id
  }
}

resource dnsAnalyticsSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enableDnsAnalytics) {
  name: dnsAnalyticsSolutionName
  location: location
  plan: {
    name: dnsAnalyticsSolutionName
    promotionCode: ''
    product: 'OMSGallery/DnsAnalytics'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: logAnalytics.id
  }
}

resource containerInsightsSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enableContainerInsights) {
  name: containerInsightsSolutionName
  location: location
  plan: {
    name: containerInsightsSolutionName
    promotionCode: ''
    product: 'OMSGallery/ContainerInsights'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: logAnalytics.id
  }
}

resource vmInsightsSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enableVMInsights) {
  name: vmInsightsSolutionName
  location: location
  plan: {
    name: vmInsightsSolutionName
    promotionCode: ''
    product: 'OMSGallery/VMInsights'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: logAnalytics.id
  }
}

resource windowsFirewallSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enableWindowsFirewall) {
  name: windowsFirewallSolutionName
  location: location
  plan: {
    name: windowsFirewallSolutionName
    promotionCode: ''
    product: 'OMSGallery/WindowsFirewall'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: logAnalytics.id
  }
}

output resourceId string = logAnalytics.id
output workspaceId string = logAnalytics.properties.customerId
