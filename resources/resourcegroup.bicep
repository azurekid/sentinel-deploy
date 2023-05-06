param resourceGroupName string
param location string

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' s= {
  name: resourceGroupName
  location: location
}