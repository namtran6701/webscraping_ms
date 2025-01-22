param privateDnsZoneName string

resource r_PrivateZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  tags: {
  }
  properties: {
  }
}
