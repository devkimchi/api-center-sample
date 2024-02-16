targetScope = 'subscription'

param name string

// The location where the resources should be deployed.
@allowed([
  'australiaeast'
  'centralindia'
  'eastus'
  'uksouth'
  'westeurope'
])
param location string

param apiManagementPublisherName string = 'Dev Kimchi'
param apiManagementPublisherEmail string = 'apim@devkimchi.com'

// tags that should be applied to all resources.
var tags = {
  // Tag all resources with the environment name.
  'azd-env-name': name
}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${name}'
  location: location
  tags: tags
}

module apic './provision-apiCenter.bicep' = {
  name: 'APICenter'
  scope: rg
  params: {
    name: name
    location: location
    tags: tags
  }
}

module apim './provision-ApiManagement.bicep' = {
  name: 'ApiManagement'
  scope: rg
  params: {
    name: name
    location: location
    tags: tags
    apiManagementPublisherName: apiManagementPublisherName
    apiManagementPublisherEmail: apiManagementPublisherEmail
  }
}

output apicId string = apic.outputs.id
output apicName string = apic.outputs.name
output apicWorkspace string = apic.outputs.workspace
output apimId string = apim.outputs.id
output apimName string = apim.outputs.name
output apimSubscriptionKey string = apim.outputs.subscriptionKey
