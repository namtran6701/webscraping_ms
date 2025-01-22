param privateDnsZoneName string
param vnetName string

var resourceName = '${privateDnsZoneName}-${vnetName}-link'
var trimmedName = length(resourceName) > 80 ? substring(resourceName, 0, 80) : resourceName

resource r_PrivateZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
}

resource sourceNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetName  
}

resource r_PrivateZoneVNETLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: r_PrivateZone
  name: trimmedName
  location: 'global'
  properties: {
    virtualNetwork: {
      id: sourceNetwork.id
    }
    registrationEnabled: false
  }
}
