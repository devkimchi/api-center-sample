param name string
param suffix string = 'linter'
param location string = resourceGroup().location

param tags object = {}

var storage = {
  name: 'st${name}${suffix}'
  location: location
  tags: tags
}

resource st 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storage.name
  location: storage.location
  kind: 'StorageV2'
  tags: storage.tags
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
  }
}
