param location string = resourceGroup().location

param keyVaultName string

param enabledForTemplateDeployment bool

param enabledForDiskEncryption bool

param enabledForDeployment bool

param softDeleteRetentionInDays int

param enableDiagnostics bool

param DeployLogAnalytics string
param logAnalyticsSubscriptionId string
param logAnalyticsRG string
param logAnalyticsName string

param DeployPurgeProtection string = 'False'

@allowed([
  'premium'
  'standard'
])
param sku string = 'standard'

param enablePurgeProtection bool = (DeployPurgeProtection == 'True')?true:false

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string = 'False'

//ip firewall rules
param AllowAccessToIpRange string  = 'False'
param IpRangeCidr string = ''
var ipRangeFilter = (DeployWithCustomNetworking == 'True' && AllowAccessToIpRange == 'True')?true:false

var publicNetworkAccess = (DeployResourcesWithPublicAccess == 'True' || ipRangeFilter)?'Enabled':'Disabled'
var defaultAction = (DeployResourcesWithPublicAccess == 'True' && ipRangeFilter == false)?'Allow':'Deny'

//for private link setup
param DeployWithCustomNetworking string = 'True'
param CreatePrivateEndpoints string = 'True'
param CreatePrivateEndpointsInSameRgAsResource string = 'False'
param UseManualPrivateLinkServiceConnections string = 'False'
param rgname string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string
param PrivateEndpointId string


var vnetIntegration = (DeployWithCustomNetworking == 'True' && CreatePrivateEndpoints == 'True')?true:false
var privateEndpointRg = (CreatePrivateEndpointsInSameRgAsResource == 'True')?resourceGroup().name:rgname

//dns zone
@secure()
param SUBSCRIPTION_ID string
var privateDnsZoneName = 'privatelink.vaultcore.azure.net'

resource r_keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    createMode: 'default'
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enablePurgeProtection: (enablePurgeProtection)?true:null
    enableRbacAuthorization: true
    enableSoftDelete: true
    networkAcls: {
      defaultAction: defaultAction
      ipRules: (ipRangeFilter==false)?null:[
        {
          value: IpRangeCidr
        }
      ]
    }
    publicNetworkAccess: publicNetworkAccess
    sku: {
      family: 'A'
      name: sku
    }
    softDeleteRetentionInDays: softDeleteRetentionInDays
    tenantId: tenant().tenantId
  }
}

resource r_loganalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (DeployLogAnalytics == 'True') {
  scope: resourceGroup(logAnalyticsSubscriptionId, logAnalyticsRG)
  name: logAnalyticsName
}

resource r_diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && DeployLogAnalytics == 'True') {
  scope: r_keyvault
  name: 'kv-diagnostic-loganalytics'
  properties: {
    workspaceId: r_loganalytics.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
  }
}

module m_keyvault_private_endpoint '../private_endpoint/deploy.bicep' = if (vnetIntegration) {
  name: 'keyvault_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    rgname: rgname
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    SUBSCRIPTION_ID: SUBSCRIPTION_ID
    rgname: rgname
    privateDnsZoneName:privateDnsZoneName
    privateDnsZoneConfigsName:replace(privateDnsZoneName,'.','-')
    resourceName: keyVaultName
    resourceID: r_keyvault.id
    privateEndpointgroupIds: [
      'vault'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}
