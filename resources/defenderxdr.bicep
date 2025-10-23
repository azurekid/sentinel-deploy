@description('Name of the Log Analytics workspace for Defender XDR integration')
param workspaceName string

@description('Enable Microsoft Defender for Endpoint integration')
param enableMDE bool = true

@description('Enable Microsoft Defender for Office 365 integration')
param enableMDO bool = true

@description('Enable Microsoft Defender for Identity integration')
param enableMDI bool = true

@description('Enable Microsoft Defender for Cloud Apps integration')
param enableMDCA bool = true

// Reference existing Log Analytics workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: workspaceName
}

// Microsoft Defender for Endpoint Data Connector
resource mdeConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = if (enableMDE) {
  scope: workspace
  name: 'MicrosoftDefenderForEndpoint-DataConnector'
  kind: 'MicrosoftDefenderAdvancedThreatProtection'
  properties: {
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
    tenantId: subscription().tenantId
  }
}

// Microsoft Defender for Office 365 Data Connector
resource mdoConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = if (enableMDO) {
  scope: workspace
  name: 'MicrosoftDefenderForOffice365-DataConnector'
  kind: 'Office365'
  properties: {
    dataTypes: {
      exchange: {
        state: 'Enabled'
      }
      sharePoint: {
        state: 'Enabled'
      }
      teams: {
        state: 'Enabled'
      }
    }
    tenantId: subscription().tenantId
  }
}

// Microsoft Defender for Identity Data Connector
resource mdiConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = if (enableMDI) {
  scope: workspace
  name: 'MicrosoftDefenderForIdentity-DataConnector'
  kind: 'AzureAdvancedThreatProtection'
  properties: {
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
    tenantId: subscription().tenantId
  }
}

// Microsoft Defender for Cloud Apps Data Connector
resource mdcaConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = if (enableMDCA) {
  scope: workspace
  name: 'MicrosoftDefenderForCloudApps-DataConnector'
  kind: 'MicrosoftCloudAppSecurity'
  properties: {
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
      discoveryLogs: {
        state: 'Enabled'
      }
    }
    tenantId: subscription().tenantId
  }
}

// Outputs
output workspaceId string = workspace.id
output mdeConnectorId string = enableMDE ? mdeConnector.id : ''
output mdoConnectorId string = enableMDO ? mdoConnector.id : ''
output mdiConnectorId string = enableMDI ? mdiConnector.id : ''
output mdcaConnectorId string = enableMDCA ? mdcaConnector.id : ''
