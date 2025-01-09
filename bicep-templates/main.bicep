// Import networking modules
module vnet 'modules/networking/vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    vnetName: 'myVnet'
    addressSpace: '10.0.0.0/16'
  }
}

module subnet 'modules/networking/subnet.bicep' = {
  name: 'subnetDeployment'
  params: {
    vnetName: vnet.outputs.vnetName
    subnetName: 'mySubnet'
    addressPrefix: '10.0.1.0/24'
  }
}

// Import compute modules
module vm 'modules/compute/vm.bicep' = {
  name: 'vmDeployment'
  params: {
    vmName: 'myVM'
    adminUsername: 'adminUser'
    adminPassword: 'P@ssword123'
    subnetId: subnet.outputs.subnetId
  }
}