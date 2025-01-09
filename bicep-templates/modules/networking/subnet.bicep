resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'mySubnet'
  parent: vnet
  properties: {
    addressPrefix: '10.0.1.0/24'
  }
}