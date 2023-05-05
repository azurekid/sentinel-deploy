@description('name of the log analytics workspace')
param workspaceName string

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

resource workspace 'Microsoft.OperationalInsights/workspaces@2015-11-01-preview' = {
  name: workspaceName
}

resource azureSentinelSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: workspaceName
  location: location
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
    workspaceResourceId: workspace.id
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
    workspaceResourceId: workspace.id
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
    workspaceResourceId: workspace.id
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
    workspaceResourceId: workspace.id
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
    workspaceResourceId: workspace.id
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
    workspaceResourceId: workspace.id
  }
}

output resourceId string = workspace.id
output workspaceId string = workspace.properties.customerId
