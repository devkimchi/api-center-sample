param name string
param location string = resourceGroup().location

param tags object = {
  'azd-env-name': name
}

var apiCenter = {
  name: 'apic-${name}'
  location: location
  tags: tags
  workspace: {
    title: 'Default workspace'
    description: 'Default workspace'
  }
}

resource apic 'Microsoft.ApiCenter/services@2024-03-01' = {
  name: apiCenter.name
  location: apiCenter.location
  tags: apiCenter.tags
  identity: {
    type: 'SystemAssigned'
  }
}

resource apicWorkspace 'Microsoft.ApiCenter/services/workspaces@2024-03-01' = {
  name: 'default'
  parent: apic
  properties: {
    title: apiCenter.workspace.title
    description: apiCenter.workspace.description
  }
}

output id string = apic.id
output name string = apic.name
output workspace string = apicWorkspace.name
