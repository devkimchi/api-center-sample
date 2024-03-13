param name string
param suffix string = 'linter'
param location string = resourceGroup().location

param tags object = {}

resource wrkspc 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: 'wrkspc-${name}${suffix == null || suffix == '' ? '' : '-'}${suffix}'
}

var appInsights = {
  name: 'appins-${name}${suffix == null || suffix == '' ? '' : '-'}${suffix}'
  location: location
  tags: tags
}

resource appins 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsights.name
  location: appInsights.location
  dependsOn: [
    wrkspc
  ]
  kind: 'web'
  tags: appInsights.tags
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    IngestionMode: 'LogAnalytics'
    Request_Source: 'rest'
    WorkspaceResourceId: wrkspc.id
  }
}

output id string = appins.id
output name string = appins.name
