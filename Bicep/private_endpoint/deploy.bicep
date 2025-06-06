param location string
param VnetforPrivateEndpointsSubscriptionId string = subscription().subscriptionId
param vnetName string
param PrivateEndpointSubnetName string
param UseManualPrivateLinkServiceConnections string = 'False'
param SUBSCRIPTION_ID string
param rgname string
param privateDnsZoneName string
param privateDnsZoneConfigsName string
param resourceName string
param resourceID string
param privateEndpointgroupIds array
param PrivateEndpointId string

var peName = 'pep-${PrivateEndpointId}-${location}-${resourceName}-${first(privateEndpointgroupIds)}'

var privateLinkServiceConnections = [
  {
    name: peName
    properties: {
      privateLinkServiceId: resourceID
      groupIds: privateEndpointgroupIds
    }
  }
]

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  scope: resourceGroup(VnetforPrivateEndpointsSubscriptionId, rgname)
  name: vnetName
}

resource r_PrivateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(SUBSCRIPTION_ID, rgname)
  name: privateDnsZoneName
}

resource r_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: peName
  location: location
  properties: {
    subnet: {
      id: '${r_vnet.id}/subnets/${PrivateEndpointSubnetName}'
    }
    customNetworkInterfaceName: '${peName}-nic'
    privateLinkServiceConnections: (UseManualPrivateLinkServiceConnections == 'True')?null:privateLinkServiceConnections
    manualPrivateLinkServiceConnections: (UseManualPrivateLinkServiceConnections == 'False')?null:privateLinkServiceConnections
  }
  tags: {
  }
  dependsOn: [
  ]
}

resource r_PrivateEndpointZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: r_PrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneConfigsName
        properties: {
          privateDnsZoneId: r_PrivateDNSZone.id
        }
      }
    ]
  }
  dependsOn: [
  ]
}
