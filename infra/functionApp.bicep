param name string
param suffix string = 'linter'
param location string = resourceGroup().location

param tags object = {}

resource appins 'Microsoft.Insights/components@2020-02-02' existing = {
  name: 'appins-${name}${suffix == null || suffix == '' ? '' : '-'}${suffix}'
}

resource st 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: 'st${name}${suffix}'
}

resource csplan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: 'csplan-${name}${suffix == null || suffix == '' ? '' : '-'}${suffix}'
}

var functionApp = {
  name: 'fncapp-${name}${suffix == null || suffix == '' ? '' : '-'}${suffix}'
  location: location
  tags: tags
}

var commonSettings = [
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appins.properties.InstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appins.properties.ConnectionString
  }
  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${st.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${st.listKeys().keys[0].value}'
  }
  {
    name: 'FUNCTION_APP_EDIT_MODE'
    value: 'readonly'
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: 'node'
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: 'DefaultEndpointsProtocol=https;AccountName=${st.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${st.listKeys().keys[0].value}'
  }
  {
    name: 'WEBSITE_CONTENTSHARE'
    value: functionApp.name
  }
]

var appSettings = concat(commonSettings)

resource fncapp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionApp.name
  location: functionApp.location
  dependsOn: [
    appins
    st
  ]
  kind: 'functionapp,linux'
  tags: functionApp.tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: csplan.id
    httpsOnly: true
    reserved: true
    siteConfig: {
      appSettings: appSettings
      linuxFxVersion: 'Node|20'
    }
  }
}

var policies = [
  {
    name: 'scm'
    allow: false
  }
  {
    name: 'ftp'
    allow: false
  }
]

resource fncappPolicies 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = [for policy in policies: {
  name: policy.name
  parent: fncapp
  properties: {
    allow: policy.allow
  }
}]

output id string = fncapp.id
output name string = fncapp.name
