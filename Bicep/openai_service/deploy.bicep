@description('That name is the name of our application.')
param cognitiveServiceName string

@description('Location for non Azure Open AI resources.')
param location string = resourceGroup().location

@description('Location for Azure Open AI.')
param openAILocation string

param kind string = 'OpenAI'

@allowed([
  'S0'
])
param sku string = 'S0'

@description('Disable use of API Keys and only allow AAD Auth')
param disableLocalAuth bool = true

param deployments array = []

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string = 'False'

//ip firewall rules
param AllowAccessToIpRange string = 'False'
param IpRangeCidr string = ''
var ipRangeFilter = (DeployWithCustomNetworking == 'True' && AllowAccessToIpRange == 'True')?true:false

var publicNetworkAccess = (DeployResourcesWithPublicAccess == 'True' || ipRangeFilter)?'Enabled':'Disabled'
var defaultAction = (DeployResourcesWithPublicAccess == 'True' && ipRangeFilter == false)?'Allow':'Deny'

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
var privateDnsZoneName = (kind == 'OpenAI')?'privatelink.openai.azure.com':'privatelink.cognitiveservices.azure.com'

resource r_cognitiveService 'Microsoft.CognitiveServices/accounts@2022-10-01' = {
  name: cognitiveServiceName
  location: openAILocation
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  kind: kind
  properties: {
    publicNetworkAccess: publicNetworkAccess
    disableLocalAuth: disableLocalAuth
    customSubDomainName: cognitiveServiceName
    apiProperties: {
      statisticsEnabled: false
    }
    networkAcls: {
      defaultAction: defaultAction
      ipRules: (ipRangeFilter==false)?null:[
        {
          value: IpRangeCidr
        }
      ]
    }
  }
}

@batchSize(1)
resource r_deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in deployments: {
  parent: r_cognitiveService
  name: deployment.name
  properties: {
    model: deployment.model
    raiPolicyName: contains(deployment, 'raiPolicyName') ? deployment.raiPolicyName : null
  }
  sku: contains(deployment, 'sku') ? deployment.sku : {
    name: 'Standard'
    capacity: 20
  }
}]

module m_cognitiveService_private_endpoint '../private_endpoint/deploy.bicep' = if (vnetIntegration) {
  name: 'cognitiveService_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    vnetName: vnetName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    SUBSCRIPTION_ID: SUBSCRIPTION_ID
    rgname: rgname
    privateDnsZoneName:privateDnsZoneName
    privateDnsZoneConfigsName:replace(privateDnsZoneName,'.','-')
    resourceName: cognitiveServiceName
    resourceID: r_cognitiveService.id
    privateEndpointgroupIds: [
      'account'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}


