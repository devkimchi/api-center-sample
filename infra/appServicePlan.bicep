param name string
param location string = resourceGroup().location

param tags object = {}

@allowed([
  'web'
  'api'
])
param appType string = 'web'
param appKind string
@allowed([
  'B1'
  'S1'
  'P1'
])
param skuName string = 'S1'

var appServicePlan = {
  name: 'asplan-${name}-${appType}'
  location: location
  tags: tags
  kind: appKind
  sku: {
    name: skuName
  }
}

resource asplan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlan.name
  location: appServicePlan.location
  tags: appServicePlan.tags
  kind: appServicePlan.kind
  sku: {
    name: appServicePlan.sku.name
  }
  properties: {
    reserved: appServicePlan.kind == 'linux' ? true : false
  }
}
