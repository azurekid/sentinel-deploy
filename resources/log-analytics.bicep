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