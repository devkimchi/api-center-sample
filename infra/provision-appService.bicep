param name string
param location string = resourceGroup().location

param tags object = {}

@allowed([
  'web'
  'api'
])
param appType string = 'web'

module wrkspc './logAnalyticsWorkspace.bicep' = {
  name: 'AppService_LogAnalyticsWorkspace-${appType}'
  params: {
    name: name
    suffix: appType
    location: location
    tags: tags
  }
}

module appins './applicationInsights.bicep' = {
  name: 'AppService_ApplicationInsights-${appType}'
  dependsOn: [
    wrkspc
  ]
  params: {
    name: name
    suffix: appType
    location: location
    tags: tags
  }
}

module asplan './appServicePlan.bicep' = {
  name: 'AppService_AppServicePlan-${appType}'
  dependsOn: [
    appins
  ]
  params: {
    name: name
    location: location
    tags: tags
    appType: appType
    appKind: 'linux'
  }
}

module appsvc './appService.bicep' = {
  name: 'AppService_AppService-${appType}'
  dependsOn: [
    asplan
  ]
  params: {
    name: name
    location: location
    tags: tags
    appType: appType
    appKind: 'linux'
  }
}

output id string = appsvc.outputs.id
output name string = appsvc.outputs.name
