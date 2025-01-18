targetScope = 'subscription'
param rgname string
//param location string = resourceGroup().location
param location string = 'EASTUS'
param tags object
param aisearchname string
param aisearchlocation string
param sku_name string
param disableLocalAuth bool = true
param partitionCount int
param replicaCount int
param hostingMode string
param semanticSearch string = 'standard'
param aiservicename string = 'gtpgenaitchcon'
param deployments array = []
param appInsightsName string

param deployblobPE bool
param deploydfsPE bool
param deployfilePE bool
param deployqueuePE bool
param deploytablePE bool


param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string
param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string
param PrivateEndpointId string
param DeployResourcesWithPublicAccess string = 'False'
param AllowAccessToIpRange string = 'False'
param IpRangeCidr string = ''
param DeployWithCustomNetworking string = 'True'
param CreatePrivateEndpoints string = 'True'
param CreatePrivateEndpointsInSameRgAsResource string = 'False'
param UseManualPrivateLinkServiceConnections string = 'False'
//param privateDnsZoneName string
//param privateEndpointgroupIds array
//param apimSubnetServiceEndpoints array

param appServicePlanName string
param appserviceplan_sku string
param appserviceplan_skuCode string
param reserved bool
param maximumElasticWorkerCount int
param functionWorkerRuntime string = 'node'
param functionAppName string = 'gtpgenaitcdefna'
param hostingPlanName string = 'gtpgenaidevdefnp'
param storageAccountName string
param functionApplinuxFxVersion string = 'DOCKER|mcr.microsoft.com/appsvc/staticsite:latest'
param dockerRegistryUrl string
param dockerRegistryUsername string

param vnetName string
param vnetAddressSpace string
//param vnet_id string
param VnetForResourcesRgName string
param VnetForResourcesName string 
param FunctionAppSubnetName string = 'FunctionAppSubnet'
param logicAppSubnetName string = 'LogicAppSubnet'
param apiManagementSubnetName string = 'ApiManagementSubnet'
param azurePAASResourcesSubnetAddressSpace string
param logicAppSubnetAddressSpace string = '10.240.4.192/28'
param functionAppSubnetAddressSpace string = '10.240.4.176/28'
param apiManagementSubnetAddressSpace string = '10.240.4.144/28'
//param firewallIPAddress string = '10.240.4.64/26'

param DeployDataLake string = 'True'
param DeployLandingStorage string = 'True'
param DeployKeyVault string = 'True'
param DeployAzureSQL string = 'True'
param DeployADF string = 'True'
param DeploySynapse string = 'False'
param DeployPurview string = 'False'
param DeployLogicApp string = 'True'
param DeployFunctionApp string = 'True'
param DeployMLWorkspace string = 'True'
param DeployCognitiveService string = 'True'
param DeployEventHubNamespace string = 'False'
param DeployADFPortalPrivateEndpoint string = 'True'
param DeploySynapseWebPrivateEndpoint string = 'False'
param DeployPurviewPrivateEndpoints string = 'False'
param DeployDatabricks string = 'False'
param DeployAzureSearch string = 'True'
param DeployAPIManagement string = 'True'
param DeployAzureOpenAI string = 'True'
param sku string

param keyVaultName string
param secrets array
param enabledForTemplateDeployment bool
param enabledForDiskEncryption bool
param enabledForDeployment bool
param softDeleteRetentionInDays int
param DeployPurgeProtection string = 'False'
param enablePurgeProtection bool = (DeployPurgeProtection == 'True') ? true : false

param DeployLogAnalytics string = 'True'
param logAnalyticsSubscriptionId string
param logAnalyticsRG string
param logAnalyticsName string
@description('Public Network Access for Ingestion')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'
@description('Public Network Access for Query')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccessForQuery string = 'Enabled'
param log_sku_name string
param retentionInDays int = 90
param dailyQuotaGb int = -1
param enableDataExport bool = true
param enableLogAccessUsingOnlyResourcePermissions bool = false
param immediatePurgeDataOn30Days bool = false

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountType string
@allowed([
  'Hot'
  'Cool'
])
param accessTier string
param containerName string
param isHnsEnabled bool
param requireInfrastructureEncryption bool
param softDeleteEnabled bool
param enableDiagnostics bool

//param vnet_id string



module rg '../resource-group/deploy.bicep' = {
  name: 'rg-deployment'
  params: {
    name: rgname
    tags: tags
  }
}

module vnetModule '../vnet/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'vnetDeployment'
  params: {
    location: location
    vnetName: vnetName
    vnetAddressSpace: vnetAddressSpace
  }
}


module subnetModule '../subnet/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'subnetDeployment'
  params: {
    location: location
    vnetName: vnetName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    LogicAppSubnetName: logicAppSubnetName
    FunctionAppSubnetName: FunctionAppSubnetName
    ApiManagementSubnetName: apiManagementSubnetName
    azurePAASResourcesSubnetAddressSpace: azurePAASResourcesSubnetAddressSpace
    logicAppSubnetAddressSpace: logicAppSubnetAddressSpace
    functionAppSubnetAddressSpace: functionAppSubnetAddressSpace
    apiManagementSubnetAddressSpace: apiManagementSubnetAddressSpace
    //apimSubnetServiceEndpoints: apimSubnetServiceEndpoints
    DeployMLWorkspace: DeployMLWorkspace
    //DeployApiManagement: DeployApiManagement
  }
  dependsOn:[vnetModule]
}


module logAnalyticsModule '../loganalytics/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'logAnalyticsDeployment'
  params: {
    location: location
    logAnalyticsName: logAnalyticsName
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    sku_name: log_sku_name
    disableLocalAuth: disableLocalAuth
    enableDataExport: enableDataExport
    enableLogAccessUsingOnlyResourcePermissions: enableLogAccessUsingOnlyResourcePermissions
    immediatePurgeDataOn30Days: immediatePurgeDataOn30Days
    retentionInDays: retentionInDays
    dailyQuotaGb: dailyQuotaGb
    DeployResourcesWithPublicAccess: DeployResourcesWithPublicAccess
  }
  dependsOn:[vnetModule,subnetModule]
}


module keyVaultModule '../keyvault/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'keyVaultModule'
  params: {
    location: location
    keyVaultName: keyVaultName
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForDeployment: enabledForDeployment
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableDiagnostics: enableDiagnostics
    DeployLogAnalytics: DeployLogAnalytics
    logAnalyticsSubscriptionId: logAnalyticsSubscriptionId
    logAnalyticsRG: logAnalyticsRG
    logAnalyticsName: logAnalyticsName
    DeployPurgeProtection: DeployPurgeProtection
    sku: sku
    enablePurgeProtection: enablePurgeProtection
    DeployResourcesWithPublicAccess: DeployResourcesWithPublicAccess
    AllowAccessToIpRange: AllowAccessToIpRange
    IpRangeCidr: IpRangeCidr
    DeployWithCustomNetworking: DeployWithCustomNetworking
    CreatePrivateEndpoints: CreatePrivateEndpoints
    CreatePrivateEndpointsInSameRgAsResource: CreatePrivateEndpointsInSameRgAsResource
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    PrivateEndpointId: PrivateEndpointId
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
  }
  dependsOn:[dnsModule]
}

module m_keyvualt_add_secret '../keyvault/keyvaultsecret.bicep' = [
  for secret in secrets: {
    scope: resourceGroup(rgname)
    name: '${keyVaultName}_${secret.name}'
    params: {
      keyVaultName: keyVaultName
      secretName: secret.name
      secretValue: secret.value
    }
    dependsOn:[keyVaultModule]   
  }
]

module dnsZones '../private_dns_zone_create/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'dnsZonesModule'
  params: {
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
  }
  dependsOn:[vnetModule,subnetModule]
}


module dnsModule '../private-dns-zone-orchestrator/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'dns-deployment'
  params: {
    DeployDataLake: DeployDataLake
    DeployLandingStorage: DeployLandingStorage
    DeployKeyVault: DeployKeyVault
    DeployAzureSQL: DeployAzureSQL
    DeployADF: DeployADF
    DeploySynapse: DeploySynapse
    DeployPurview: DeployPurview
    DeployLogicApp: DeployLogicApp
    DeployFunctionApp: DeployFunctionApp
    DeployMLWorkspace: DeployMLWorkspace
    DeployCognitiveService: DeployCognitiveService
    DeployEventHubNamespace: DeployEventHubNamespace
    DeployADFPortalPrivateEndpoint: DeployADFPortalPrivateEndpoint
    DeploySynapseWebPrivateEndpoint: DeploySynapseWebPrivateEndpoint
    DeployPurviewPrivateEndpoints: DeployPurviewPrivateEndpoints
    DeployDatabricks: DeployDatabricks
    DeployAzureSearch: DeployAzureSearch
    DeployAPIManagement: DeployAPIManagement
    DeployAzureOpenAI: DeployAzureOpenAI
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    //vnet_id: vnet_id
  }
  dependsOn:[dnsZones]

}


module storageAccount '../storageaccount/deploy.bicep' = {
  scope: resourceGroup(rgname)

  name: 'storageAccountModule'
  params: {
    location: location
    storageAccountName: storageAccountName
    storageAccountType: storageAccountType
    accessTier: accessTier
    isHnsEnabled: isHnsEnabled
    requireInfrastructureEncryption: requireInfrastructureEncryption
    softDeleteEnabled: softDeleteEnabled
    enableDiagnostics: enableDiagnostics
    DeployWithCustomNetworking: DeployWithCustomNetworking
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    deployblobPE: deployblobPE
    deploydfsPE: deploydfsPE
    deployfilePE: deployfilePE
    deployqueuePE: deployqueuePE
    deploytablePE: deploytablePE
    PrivateEndpointId: PrivateEndpointId
  }
  dependsOn:[dnsModule]
}

module storageContainerModule '../storage_account_container/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'storageContainerDeployment'
  params: {
    storageAccountName: storageAccountName
    containerName: containerName
  }
  dependsOn:[storageAccount]
}


module m_ai_search '../ai search/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'ai_search_deployment'
  params: {
    location: location
    aisearchname: aisearchname
    aisearchlocation: aisearchlocation
    sku_name: sku_name
    disableLocalAuth: disableLocalAuth
    partitionCount: partitionCount
    replicaCount: replicaCount
    hostingMode: hostingMode
    semanticSearch: semanticSearch
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    PrivateEndpointId: PrivateEndpointId
    DeployResourcesWithPublicAccess: DeployResourcesWithPublicAccess
    AllowAccessToIpRange: AllowAccessToIpRange
    IpRangeCidr: IpRangeCidr
    DeployWithCustomNetworking: DeployWithCustomNetworking
    CreatePrivateEndpoints: CreatePrivateEndpoints
    CreatePrivateEndpointsInSameRgAsResource: CreatePrivateEndpointsInSameRgAsResource
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
  }
  dependsOn:[m_keyvualt_add_secret,storageContainerModule]
}

module m_appServicePlan '../appserviceplan/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'appServicePlanDeployment'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    appserviceplan_sku: appserviceplan_sku
    appserviceplan_skuCode: appserviceplan_skuCode
    reserved: reserved
    maximumElasticWorkerCount: maximumElasticWorkerCount
  }
  dependsOn:[m_keyvualt_add_secret,storageContainerModule]
}

module functionAppModule '../functionapp/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'deployFunctionApp'
  params: {
    location: location
    functionWorkerRuntime: functionWorkerRuntime
    functionAppName: functionAppName
    hostingPlanName: hostingPlanName
    storageAccountName: storageAccountName
    functionApplinuxFxVersion: functionApplinuxFxVersion
    VnetForResourcesRgName: VnetForResourcesRgName
    VnetForResourcesName: VnetForResourcesName
    FunctionAppSubnetName: FunctionAppSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    PrivateEndpointId: PrivateEndpointId
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    dockerRegistryUrl: dockerRegistryUrl
    dockerRegistryUsername: dockerRegistryUsername
  }
  dependsOn:[m_keyvualt_add_secret,storageContainerModule,m_appServicePlan]

}

module cognitiveServiceModule '../openai_service/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'cognitiveServiceDeployment'
  params: {
    cognitiveServiceName: aiservicename
    location: location
    openAILocation: location
    disableLocalAuth: disableLocalAuth
    DeployResourcesWithPublicAccess: DeployResourcesWithPublicAccess
    DeployWithCustomNetworking: DeployWithCustomNetworking
    CreatePrivateEndpoints: CreatePrivateEndpoints
    CreatePrivateEndpointsInSameRgAsResource: CreatePrivateEndpointsInSameRgAsResource
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    PrivateEndpointId: PrivateEndpointId
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    deployments: deployments
  }
  dependsOn:[m_keyvualt_add_secret, storageContainerModule,m_ai_search]
}

module appInsightsModule '../appinsights/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'deployAppInsights'
  params: {
    location: location
    appInsightsName: appInsightsName
    DeployLogAnalytics: DeployLogAnalytics
    logAnalyticsSubscriptionId: logAnalyticsSubscriptionId
    logAnalyticsName: logAnalyticsName
    logAnalyticsRG: logAnalyticsRG
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    RetentionInDays: retentionInDays
    DeployResourcesWithPublicAccess: DeployResourcesWithPublicAccess
  }
  dependsOn:[vnetModule,subnetModule]
}
