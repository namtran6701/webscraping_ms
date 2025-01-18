param sourceNetworkName string
param destinationNetworkName string
param destinationNetworkSubscriptionId string
param destinationNetworkResourceGroupName string

resource sourceNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: sourceNetworkName  
}

resource sourceToDestinationPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: '${sourceNetworkName}-to-${destinationNetworkName}'
  parent: sourceNetwork
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: resourceId(destinationNetworkSubscriptionId, destinationNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', destinationNetworkName)
    }
  }
}
