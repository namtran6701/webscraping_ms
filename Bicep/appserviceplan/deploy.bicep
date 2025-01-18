param location string = resourceGroup().location

param appServicePlanName string

param appserviceplan_sku string

param appserviceplan_skuCode string

param reserved bool

param maximumElasticWorkerCount int

resource r_AppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  kind: 'elastic'
  sku: {
    tier: appserviceplan_sku
    name: appserviceplan_skuCode
  }
  properties: {
    reserved: reserved
    maximumElasticWorkerCount: maximumElasticWorkerCount
  }
  dependsOn: []
}
