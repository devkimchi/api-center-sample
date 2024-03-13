param name string
param suffix string = 'linter'
param location string = resourceGroup().location

param tags object = {}

module st './storageAccount.bicep' = {
  name: 'FunctionApp${suffix == null || suffix == '' ? '' : '_'}${suffix}_StorageAccount'
  params: {
    name: name
    location: location
    tags: tags
  }
}

module wrkspc './logAnalyticsWorkspace.bicep' = {
  name: 'FunctionApp${suffix == null || suffix == '' ? '' : '_'}${suffix}_LogAnalyticsWorkspace'
  params: {
    name: name
    location: location
    tags: tags
  }
}

module appins './applicationInsights.bicep' = {
  name: 'FunctionApp${suffix == null || suffix == '' ? '' : '_'}${suffix}_ApplicationInsights'
  dependsOn: [
    wrkspc
  ]
  params: {
    name: name
    location: location
    tags: tags
  }
}

module csplan './consumptionPlan.bicep' = {
  name: 'FunctionApp${suffix == null || suffix == '' ? '' : '_'}${suffix}_ConsumptionPlan'
  params: {
    name: name
    location: location
    tags: tags
  }
}

module fncapp './functionApp.bicep' = {
  name: 'FunctionApp${suffix == null || suffix == '' ? '' : '_'}${suffix}_FunctionApp'
  dependsOn: [
    st
    appins
    csplan
  ]
  params: {
    name: name
    suffix: suffix
    location: location
    tags: tags
  }
}
