param name string
param suffix string = 'linter'
param location string = resourceGroup().location

param tags object = {}

var consumption = {
  name: 'csplan-${name}${suffix == null || suffix == '' ? '' : '-'}${suffix}'
  location: location
  tags: tags
}

resource csplan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: consumption.name
  location: consumption.location
  kind: 'functionApp'
  tags: consumption.tags
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

output id string = csplan.id
output name string = csplan.name
