targetScope = 'subscription'    // Resource group must be deployed under 'subscription' scope

param resourceGroupName string

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
}