param SUBSCRIPTION_ID string
param rgname string

//storage - blob
var blobprivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
module m_blob_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'blob_private_endpoint'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: blobprivateDnsZoneName
  }
}

//storage - dfs
var dfsprivateDnsZoneName = 'privatelink.dfs.${environment().suffixes.storage}'
module m_df_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'dfs_private_endpoint'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: dfsprivateDnsZoneName
  }
}

//storage - file
var fileprivateDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
module m_file_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'file_private_endpoint'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: fileprivateDnsZoneName    
  }
}

//storage - queue
var queueprivateDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'
module m_queue_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'queue_private_endpoint'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: queueprivateDnsZoneName
  }
}

//storage - table
var tableprivateDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'
module m_table_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'table_private_endpoint'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: tableprivateDnsZoneName
  }
}

//azure sql
var sqlPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
module m_sql_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'sql_private_endpoint'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: sqlPrivateDnsZoneName
  }
}

//cognitive service
var cognitiveServicePrivateDnsZoneName = 'privatelink.cognitiveservices.azure.com'
module m_cognitive_service_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'cognitive_service_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: cognitiveServicePrivateDnsZoneName
  }
}

var openAIPrivateDnsZoneName = 'privatelink.openai.azure.com'
module m_openai_service_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'openai_service_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: openAIPrivateDnsZoneName
  }
}

//data factory portal
var adfPortalPrivateDnsZoneName = 'privatelink.adf.azure.com'
module m_data_factory_portal_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'data_factory_portal_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: adfPortalPrivateDnsZoneName
  }
}

//data factory integration runtime
var adfPrivateDnsZoneName = 'privatelink.datafactory.azure.net'
module m_data_factory_dataFactory_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'data_factory_dataFactory_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: adfPrivateDnsZoneName
  }
}

//event hub namespace for purview and/or event hub namespace for streaming pattern
// var eventhubPrivateDnsZone='privatelink.servicebus.windows.net'
// module m_event_hub_dns_zone 'private_endpoint_dns_zone_base.bicep' = {
//   name: 'event_hub_dns_zone'
//   scope: resourceGroup(SUBSCRIPTION_ID, rgname)
//   params: {
//     privateDnsZoneName: eventhubPrivateDnsZone
//   }
// }

//key vault
var keyVaultPrivateDnsZoneName = 'privatelink.vaultcore.azure.net'
module m_key_vault_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'key_vault_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: keyVaultPrivateDnsZoneName
  }
}

//logic app
var azureWebsitesPrivateDnsZoneName = 'privatelink.azurewebsites.net'
module m_azurewebsites_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'logic_app_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: azureWebsitesPrivateDnsZoneName
  }
}

//purview - portal
// var purviewPortalprivateDnsZoneName = 'privatelink.purviewstudio.azure.com'
// module m_purview_portal_dns_zone 'private_endpoint_dns_zone_base.bicep' = {
//   name: 'purview_portal_dns_zone'
//   scope: resourceGroup(SUBSCRIPTION_ID, rgname)
//   params: {
//     privateDnsZoneName: purviewPortalprivateDnsZoneName
//   }
// }

//purview - account
// var purviewAccountprivateDnsZoneName = 'privatelink.purview.azure.com'
// module m_purview_account_dns_zone 'private_endpoint_dns_zone_base.bicep' = {
//   name: 'purview_account_dns_zone'
//   scope: resourceGroup(SUBSCRIPTION_ID, rgname)
//   params: {
//     privateDnsZoneName: purviewAccountprivateDnsZoneName
//   }
// }

//synapse - dev
// var synapseDevprivateDnsZoneName = 'privatelink.dev.azuresynapse.net'
// module m_synapse_dev_dns_zone 'private_endpoint_dns_zone_base.bicep' = {
//   name: 'synapse_dev_dns_zone'
//   scope: resourceGroup(SUBSCRIPTION_ID, rgname)
//   params: {
//     privateDnsZoneName: synapseDevprivateDnsZoneName
//   }
// }

//synapse - sql
// var synapseSqlprivateDnsZoneName = 'privatelink.sql.azuresynapse.net'
// module m_synapse_sql_dns_zone 'private_endpoint_dns_zone_base.bicep' = {
//   name: 'synapse_sql_dns_zone'
//   scope: resourceGroup(SUBSCRIPTION_ID, rgname)
//   params: {
//     privateDnsZoneName: synapseSqlprivateDnsZoneName
//   }
// }

//synapse - web
// var synapsePrivatelinkhubprivateDnsZoneName = 'privatelink.azuresynapse.net'
// module m_synapse_web_dns_zone 'private_endpoint_dns_zone_base.bicep' = {
//   name: 'synapse_web_dns_zone'
//   scope: resourceGroup(SUBSCRIPTION_ID, rgname)
//   params: {
//     privateDnsZoneName: synapsePrivatelinkhubprivateDnsZoneName
//   }
// }

//container registry
var containerRegistryPrivateDnsZoneName = 'privatelink${environment().suffixes.acrLoginServer}'
module m_container_registry_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'container_registry_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: containerRegistryPrivateDnsZoneName
  }
}

//machine leaning workspace api
var mlWorkspaceprivateDnsZoneName1 = 'privatelink.api.azureml.ms'
module m_ml_workspace_api_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'ml_workspace_api_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: mlWorkspaceprivateDnsZoneName1
  }
}

//machine leaning workspace notebook
var mlWorkspaceprivateDnsZoneName2 = 'privatelink.notebooks.azure.net'
module m_ml_workspace_notebook_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'ml_workspace_notebook_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: mlWorkspaceprivateDnsZoneName2
  }
}

//databricks workspace
// var databricksWorkspaceDnsZoneName = 'privatelink.azuredatabricks.net'
// module m_databricksWorkspace_dns_zone 'private_endpoint_dns_zone_base.bicep' = {
//   name: 'databricksWorkspace_dns_zone'
//   scope: resourceGroup(SUBSCRIPTION_ID, rgname)
//   params: {
//     privateDnsZoneName: databricksWorkspaceDnsZoneName
//   }
// }

var searchDnsZoneName = 'privatelink.search.windows.net'
module m_search_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'search_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: searchDnsZoneName
  }
}

var apiManagementDnsZoneName = 'privatelink.azure-api.net'
module m_api_management_dns_zone '../private_dns_zone_base/deploy.bicep' = {
  name: 'api_management_dns_zone'
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  params: {
    privateDnsZoneName: apiManagementDnsZoneName
  }
}
