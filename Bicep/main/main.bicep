targetScope = 'subscription'
param rgname string = 'Techconnect'
//param location string = resourceGroup().location
param location string = 'canadacentral'
param tags object = {
  Environment: 'dev'
  Department: 'techcon'
}
param aisearchname string = 'gtptchconaisearch'
param aisearchlocation string = 'canadacentral'
param sku_name string = 'standard'
param disableLocalAuth bool = true
param partitionCount int = 1
param replicaCount int = 1
param hostingMode string = 'default'
param semanticSearch string = 'standard'
param aiservicename string = 'gtpgenaitchcon'
param deployments array = []
param appInsightsName string = 'gtpgenaidevgrpain'

//param deployblobPE bool = true
//param deploydfsPE bool = false
//param deployfilePE bool = true
//param deployqueuePE bool = true
//param deploytablePE bool = true


param SUBSCRIPTION_ID string
param vnetName string = 'Techconnectvnet'
param PrivateEndpointSubnetName string = 'Devsubnet'
param PrivateEndpointId string = 'Devsubnet'
param DeployResourcesWithPublicAccess string = 'True'
//param AllowAccessToIpRange string = 'False'
param DeployWithCustomNetworking string = 'True'
param CreatePrivateEndpoints string = 'True'
param CreatePrivateEndpointsInSameRgAsResource string = 'False'
param UseManualPrivateLinkServiceConnections string = 'False'
//param privateDnsZoneName string
//param privateEndpointgroupIds array
//param apimSubnetServiceEndpoints array

param appServicePlanName string = 'gtpgenaidevdefnp'
param appserviceplan_sku string = 'ElasticPremium'
param appserviceplan_skuCode string = 'EP1'
param reserved bool = true
param maximumElasticWorkerCount int = 1
param functionWorkerRuntime string = 'node'
param functionAppName string = 'gtpgenaitcdefnans'
param hostingPlanName string = 'gtpgenaidevdefnp'
param storageAccountName string = 'gtpgenaitchconstor'
param functionApplinuxFxVersion string = 'DOCKER|mcr.microsoft.com/appsvc/staticsite:latest'
param dockerRegistryUrl string = 'gtpgenaicontainer.azurecr.io'
param dockerRegistryUsername string = 'gtpgenaidevdecon'

param vnetAddressSpace string = '10.240.4.0/23'
//param vnet_id string
param FunctionAppSubnetName string = 'FunctionAppSubnet'
param apiManagementSubnetName string = 'ApiManagementSubnet'
param azurePAASResourcesSubnetAddressSpace string = '10.240.4.240/28'
param logicAppSubnetAddressSpace string = '10.240.4.192/28'
param functionAppSubnetAddressSpace string = '10.240.4.176/28'
param apiManagementSubnetAddressSpace string = '10.240.4.144/28'
//param firewallIPAddress string = '10.240.4.64/26'

param DeployDataLake string = 'True'
param DeployLandingStorage string = 'True'
param DeployKeyVault string = 'True'
//param DeploySynapse string = 'False'
//param DeployPurview string = 'False'
param DeployMLWorkspace string = 'True'
param DeployCognitiveService string = 'True'
//param DeployEventHubNamespace string = 'False'
//param DeploySynapseWebPrivateEndpoint string = 'False'
//param DeployPurviewPrivateEndpoints string = 'False'
//param DeployDatabricks string = 'False'
param DeployAzureSearch string = 'True'
param DeployAPIManagement string = 'True'
param DeployAzureOpenAI string = 'True'
param sku string = 'standard'

param keyVaultName string = 'gtpgenaitchckvns'
param enabledForTemplateDeployment bool = true
param enabledForDiskEncryption bool = true
param enabledForDeployment bool = true
param softDeleteRetentionInDays int = 90
param DeployPurgeProtection string = 'False'
param enablePurgeProtection bool = (DeployPurgeProtection == 'True') ? true : false

param DeployLogAnalytics string = 'True'
param logAnalyticsName string = 'gtpgenailogtechcon'
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
param log_sku_name string = 'PerGB2018'
param retentionInDays int = 90
param dailyQuotaGb int = -1
param enableDataExport bool = true
//param enableLogAccessUsingOnlyResourcePermissions bool = false
//param immediatePurgeDataOn30Days bool = false

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_ZRS'
@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'
param containerName string = 'gtpgenaistortechcont'
//param isHnsEnabled bool = false
param requireInfrastructureEncryption bool = true
param softDeleteEnabled bool = false
param enableDiagnostics bool = true


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
  dependsOn:[rg]
}


module subnetModule '../subnet/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'subnetDeployment'
    params: {
    location: location
    vnetName: vnetName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
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
    //enableLogAccessUsingOnlyResourcePermissions: enableLogAccessUsingOnlyResourcePermissions
    //immediatePurgeDataOn30Days: immediatePurgeDataOn30Days
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
    logAnalyticsSubscriptionId: SUBSCRIPTION_ID
    logAnalyticsRG: rgname
    logAnalyticsName: logAnalyticsName
    DeployPurgeProtection: DeployPurgeProtection
    sku: sku
    enablePurgeProtection: enablePurgeProtection
    DeployResourcesWithPublicAccess: DeployResourcesWithPublicAccess
    //AllowAccessToIpRange: AllowAccessToIpRange
    DeployWithCustomNetworking: DeployWithCustomNetworking
    CreatePrivateEndpoints: CreatePrivateEndpoints
    CreatePrivateEndpointsInSameRgAsResource: CreatePrivateEndpointsInSameRgAsResource
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    rgname: rgname
    vnetName: vnetName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    PrivateEndpointId: PrivateEndpointId
    SUBSCRIPTION_ID: SUBSCRIPTION_ID
  }
  dependsOn:[dnsModule]
}

module dnsZones '../private_dns_zone_create/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'dnsZonesModule'
  params: {
    SUBSCRIPTION_ID: SUBSCRIPTION_ID
    rgname: rgname
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
    //DeploySynapse: DeploySynapse
    //DeployPurview: DeployPurview
    DeployMLWorkspace: DeployMLWorkspace
    DeployCognitiveService: DeployCognitiveService
    //DeployEventHubNamespace: DeployEventHubNamespace
    //DeploySynapseWebPrivateEndpoint: DeploySynapseWebPrivateEndpoint
    //DeployPurviewPrivateEndpoints: DeployPurviewPrivateEndpoints
    //DeployDatabricks: DeployDatabricks
    DeployAzureSearch: DeployAzureSearch
    DeployAPIManagement: DeployAPIManagement
    DeployAzureOpenAI: DeployAzureOpenAI
    vnetName: vnetName
    SUBSCRIPTION_ID: SUBSCRIPTION_ID
    rgname: rgname
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
    //isHnsEnabled: isHnsEnabled
    requireInfrastructureEncryption: requireInfrastructureEncryption
    softDeleteEnabled: softDeleteEnabled
    enableDiagnostics: enableDiagnostics
    DeployWithCustomNetworking: DeployWithCustomNetworking
    vnetName: vnetName
    allowBlobPublicAccess: true
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    SUBSCRIPTION_ID: SUBSCRIPTION_ID
    rgname: rgname
    //deployblobPE: deployblobPE
    //deploydfsPE: deploydfsPE
    //deployfilePE: deployfilePE
    //deployqueuePE: deployqueuePE
    //deploytablePE: deploytablePE
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
    publicAccess: 'Container'
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
    SUBSCRIPTION_ID: SUBSCRIPTION_ID
    rgname: rgname
    vnetName: vnetName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    PrivateEndpointId: PrivateEndpointId
    DeployResourcesWithPublicAccess: DeployResourcesWithPublicAccess
    //AllowAccessToIpRange: AllowAccessToIpRange
    DeployWithCustomNetworking: DeployWithCustomNetworking
    CreatePrivateEndpoints: CreatePrivateEndpoints
    CreatePrivateEndpointsInSameRgAsResource: CreatePrivateEndpointsInSameRgAsResource
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
  }
  dependsOn:[storageContainerModule]
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
  dependsOn:[storageContainerModule]
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
    VnetForResourcesRgName: rgname
    FunctionAppSubnetName: FunctionAppSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    rgname: rgname
    vnetName: vnetName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    PrivateEndpointId: PrivateEndpointId
    SUBSCRIPTION_ID: SUBSCRIPTION_ID
    dockerRegistryUrl: dockerRegistryUrl
    dockerRegistryUsername: dockerRegistryUsername
  }
  dependsOn:[storageContainerModule,m_appServicePlan]

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
    vnetName: vnetName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    PrivateEndpointId: PrivateEndpointId
    SUBSCRIPTION_ID: SUBSCRIPTION_ID
    rgname: rgname
    deployments: deployments
  }
  dependsOn:[ storageContainerModule,m_ai_search]
}

module appInsightsModule '../appinsights/deploy.bicep' = {
  scope: resourceGroup(rgname)
  name: 'deployAppInsights'
  params: {
    location: location
    appInsightsName: appInsightsName
    DeployLogAnalytics: DeployLogAnalytics
    logAnalyticsSubscriptionId: SUBSCRIPTION_ID
    logAnalyticsName: logAnalyticsName
    logAnalyticsRG: rgname
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    RetentionInDays: retentionInDays
    DeployResourcesWithPublicAccess: DeployResourcesWithPublicAccess
  }
  dependsOn:[vnetModule,subnetModule]
}
