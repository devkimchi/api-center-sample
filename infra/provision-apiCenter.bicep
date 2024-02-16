param name string
param location string = resourceGroup().location

param tags object = {}

module apic './apiCenter.bicep' = {
  name: 'APICenter_APICenter'
  params: {
    name: name
    location: location
    tags: tags
  }
}

output id string = apic.outputs.id
output name string = apic.outputs.name
output workspace string = apic.outputs.workspace
