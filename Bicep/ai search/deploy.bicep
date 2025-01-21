param location string = resourceGroup().location

param aisearchname string
param aisearchlocation string

@allowed([
  'basic'
  'free'
  'standard'
  'standard2'
  'standard3'
  'storage_optimized_l1'
  'storage_optimized_l2'
])
param sku_name string

param disableLocalAuth bool

param partitionCount int 

param replicaCount int 

param hostingMode string

@allowed([
  'disabled'
  'free'
  'standard'
])
param semanticSearch string = 'standard'


//for private link setup
param DeployWithCustomNetworking string = 'True'
param CreatePrivateEndpoints string = 'True'
param CreatePrivateEndpointsInSameRgAsResource string = 'False'
param UseManualPrivateLinkServiceConnections string = 'False'
param vnetName string
param PrivateEndpointSubnetName string
param PrivateEndpointId string

var vnetIntegration = (DeployWithCustomNetworking == 'True' && CreatePrivateEndpoints == 'True')?true:false
var privateEndpointRg = (CreatePrivateEndpointsInSameRgAsResource == 'True')?resourceGroup().name:rgname

//dns zone
@secure()
param SUBSCRIPTION_ID string
param rgname string
var privateDnsZoneName = 'privatelink.search.windows.net'

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string = 'False'

//ip firewall rules
param AllowAccessToIpRange string = 'False'
param IpRangeCidr string = ''
var ipRangeFilter = (DeployWithCustomNetworking == 'True' && AllowAccessToIpRange == 'True')?true:false

var publicNetworkAccess = (DeployResourcesWithPublicAccess == 'True' || ipRangeFilter)?'enabled':'disabled'
var defaultAction = (DeployResourcesWithPublicAccess == 'True' && ipRangeFilter == false)?'Allow':'Deny'

var networkRuleSet = {
  defaultAction: defaultAction
  ipRules: (ipRangeFilter==false)?null:[
    {
      action: 'Allow'
      value: IpRangeCidr
    }
  ]
}

resource r_aisearch 'Microsoft.Search/searchServices@2023-11-01' = {
  name: aisearchname
  location: aisearchlocation
  sku: {
    name: sku_name
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hostingMode: hostingMode
    semanticSearch: semanticSearch
    networkRuleSet: (sku_name=='basic')?null:networkRuleSet
    partitionCount: partitionCount
    replicaCount: replicaCount
    publicNetworkAccess: publicNetworkAccess
    disableLocalAuth: disableLocalAuth
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
  }
}


module m_ai_search_private_endpoint '../private_endpoint/deploy.bicep' = if (vnetIntegration) {
  name: 'ai_search_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    rgname: rgname
    vnetName: vnetName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    SUBSCRIPTION_ID: SUBSCRIPTION_ID
    rgname: rgname
    privateDnsZoneName:privateDnsZoneName
    privateDnsZoneConfigsName:replace(privateDnsZoneName,'.','-')
    resourceName: aisearchname
    resourceID: r_aisearch.id
    privateEndpointgroupIds: [
      'searchService'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}
