param name string
param location string = resourceGroup().location

param tags object = {}

@allowed([
  'web'
  'api'
])
param appType string = 'web'
@allowed([
  'windows'
  'linux'
])
param appKind string = 'linux'

var appInsights = {
  name: 'appins-${name}-${appType}'
}

resource appins 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsights.name
}

var appServicePlan = {
  name: 'asplan-${name}-${appType}'
}

resource asplan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: appServicePlan.name
}

var appService = {
  name: 'appsvc-${name}-${appType}'
  location: location
  kind: '${appType == 'web' ? 'app' : 'api'}${appKind == 'linux' ? ',linux' : ''}'
  tags: tags
}

resource appsvc 'Microsoft.Web/sites@2023-01-01' = {
  name: appService.name
  location: appService.location
  kind: appService.kind
  tags: appService.tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: asplan.id
    reserved: appKind == 'linux' ? true : false
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
    }
    httpsOnly: true
  }
}

resource appsettings 'Microsoft.Web/sites/config@2023-01-01' = {
  name: 'appsettings'
  parent: appsvc
  properties: {
    APPLICATIONINSIGHTS_CONNECTION_STRING: appins.properties.ConnectionString
    ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
    XDT_MicrosoftApplicationInsights_Mode: 'Recommended'
  }
}

output id string = appsvc.id
output name string = appsvc.name
