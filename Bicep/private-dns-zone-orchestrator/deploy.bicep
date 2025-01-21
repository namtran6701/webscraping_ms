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

param rgname string
param vnetName string
param SUBSCRIPTION_ID string

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  scope: resourceGroup(rgname)
  name: vnetName
}

//storage - blob
var blobprivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
module m_blob_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployDataLake == 'True' ||  DeployLandingStorage == 'True' || DeployPurview == 'True') {
  name: 'blob_private_endpoint'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: blobprivateDnsZoneName
    vnetName: vnetName
    ////vnet_id: r_vnet.id
  }
}

//storage - dfs
var dfsprivateDnsZoneName = 'privatelink.dfs.${environment().suffixes.storage}'
module m_df_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployDataLake == 'True' ||  DeployLandingStorage == 'True') {
  name: 'dfs_private_endpoint'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: dfsprivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//storage - file
var fileprivateDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
module m_file_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployMLWorkspace == 'True' || DeployLandingStorage == 'True' || DeployLogicApp == 'True') {
  name: 'file_private_endpoint'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: fileprivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//storage - queue
var queueprivateDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'
module m_queue_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployMLWorkspace == 'True' || DeployLandingStorage == 'True' || DeployLogicApp == 'True' || DeployPurview == 'True') {
  name: 'queue_private_endpoint'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: queueprivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//storage - table
var tableprivateDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'
module m_table_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployDataLake == 'True' || DeployLandingStorage == 'True' || DeployLogicApp == 'True') {
  name: 'table_private_endpoint'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: tableprivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//azure sql
var sqlPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
module m_sql_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployAzureSQL == 'True') {
  name: 'sql_private_endpoint'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: sqlPrivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//cognitive service
var cognitiveServicePrivateDnsZoneName = 'privatelink.cognitiveservices.azure.com'
module m_cognitive_service_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployCognitiveService == 'True') {
  name: 'cognitive_service_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: cognitiveServicePrivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//openai service
var openAIPrivateDnsZoneName = 'privatelink.openai.azure.com'
module m_openai_service_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployAzureOpenAI == 'True') {
  name: 'openai_service_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: openAIPrivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//data factory portal
var adfPortalPrivateDnsZoneName = 'privatelink.adf.azure.com'
module m_data_factory_portal_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployADF == 'True' && DeployADFPortalPrivateEndpoint == 'True') {
  name: 'data_factory_portal_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: adfPortalPrivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//data factory integration runtime
var adfPrivateDnsZoneName = 'privatelink.datafactory.azure.net'
module m_data_factory_dataFactory_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployADF == 'True') {
  name: 'data_factory_dataFactory_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: adfPrivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//event hub namespace for purview and/or event hub namespace for streaming pattern
var eventhubPrivateDnsZone='privatelink.servicebus.windows.net'
module m_event_hub_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployEventHubNamespace == 'True' || DeployPurview == 'True') {
  name: 'event_hub_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: eventhubPrivateDnsZone
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//key vault
var keyVaultPrivateDnsZoneName = 'privatelink.vaultcore.azure.net'
module m_key_vault_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployKeyVault == 'True') {
  name: 'key_vault_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: keyVaultPrivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//logic app
var WebsitesPrivateDnsZoneName = 'privatelink.azurewebsites.net'
module m_websites_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployLogicApp == 'True' || DeployFunctionApp == 'True') {
  name: 'websites_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: WebsitesPrivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//purview - portal
var purviewPortalprivateDnsZoneName = 'privatelink.purviewstudio.azure.com'
module m_purview_portal_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployPurview == 'True' && DeployPurviewPrivateEndpoints == 'True') {
  name: 'purview_portal_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: purviewPortalprivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//purview - account
var purviewAccountprivateDnsZoneName = 'privatelink.purview.azure.com'
module m_purview_account_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployPurview == 'True' && DeployPurviewPrivateEndpoints == 'True') {
  name: 'purview_account_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: purviewAccountprivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//synapse - dev
var synapseDevprivateDnsZoneName = 'privatelink.dev.azuresynapse.net'
module m_synapse_dev_dns_zone '../private-dns-zone/deploy.bicep' = if (DeploySynapse == 'True') {
  name: 'synapse_dev_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: synapseDevprivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//synapse - sql
var synapseSqlprivateDnsZoneName = 'privatelink.sql.azuresynapse.net'
module m_synapse_sql_dns_zone '../private-dns-zone/deploy.bicep' = if (DeploySynapse == 'True') {
  name: 'synapse_sql_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: synapseSqlprivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//synapse - web
var synapsePrivatelinkhubprivateDnsZoneName = 'privatelink.azuresynapse.net'
module m_synapse_web_dns_zone '../private-dns-zone/deploy.bicep' = if (DeploySynapse == 'True' && DeploySynapseWebPrivateEndpoint == 'True') {
  name: 'synapse_web_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: synapsePrivatelinkhubprivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//machine leaning workspace container registry
var containerRegistryPrivateDnsZoneName = 'privatelink${environment().suffixes.acrLoginServer}'
module m_container_registry_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployMLWorkspace == 'True') {
  name: 'container_registry_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: containerRegistryPrivateDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//machine leaning workspace api
var mlWorkspaceprivateDnsZoneName1 = 'privatelink.api.azureml.ms'
module m_ml_workspace_api_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployMLWorkspace == 'True') {
  name: 'ml_workspace_api_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: mlWorkspaceprivateDnsZoneName1
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//machine leaning workspace notebook
var mlWorkspaceprivateDnsZoneName2 = 'privatelink.notebooks.azure.net'
module m_ml_workspace_notebook_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployMLWorkspace == 'True') {
  name: 'ml_workspace_notebook_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: mlWorkspaceprivateDnsZoneName2
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

//databricks workspace
var databricksWorkspaceDnsZoneName = 'privatelink.azuredatabricks.net'
module m_databricksWorkspace_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployDatabricks == 'True') {
  name: 'databricksWorkspace_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: databricksWorkspaceDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

var searchDnsZoneName = 'privatelink.search.windows.net'
module m_search_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployAzureSearch == 'True') {
  name: 'search_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: searchDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

var apiManagementDnsZoneName = 'privatelink.azure-api.net'
module m_api_management_dns_zone '../private-dns-zone/deploy.bicep' = if (DeployAPIManagement == 'True') {
  name: 'api_management_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: apiManagementDnsZoneName
    vnetName: vnetName
    //vnet_id: r_vnet.id
  }
}

