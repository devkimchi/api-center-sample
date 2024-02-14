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

module apic './apic.bicep' = {
  name: 'APICenter'
  scope: rg
  params: {
    name: name
    location: location
    tags: tags
  }
}

output id string = apic.outputs.id
output name string = apic.outputs.name
output workspace string = apic.outputs.workspace
