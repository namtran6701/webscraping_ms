param location string = resourceGroup().location

param vnetName string

param DeployMLWorkspace string = 'True'

param DeployApiManagement string = 'False'


//subnet names
param PrivateEndpointSubnetName string
param LogicAppSubnetName string = 'LogicAppSubnet'
param FunctionAppSubnetName string = 'FunctionAppSubnet'
param ApiManagementSubnetName string = 'ApiManagementSubnet'

param azurePAASResourcesSubnetAddressSpace string
param logicAppSubnetAddressSpace string = ''
param functionAppSubnetAddressSpace string = ''
param apiManagementSubnetAddressSpace string = ''

var DeployLogicApp = empty(logicAppSubnetAddressSpace)?'False':'True'

var DeployFunctionApp = empty(functionAppSubnetAddressSpace)?'False':'True'

@description('Service endpoints enabled on the API Management subnet')
param apimSubnetServiceEndpoints array = [
  {
    service: 'Microsoft.Storage'
  }
  {
    service: 'Microsoft.Sql'
  }
  {
    service: 'Microsoft.EventHub'
  }
  {
    service: 'Microsoft.KeyVault'
  }
]

var DefaultNsgRules = [
  //{
  //  name: 'AllowVirtualNetworkOutbound'
  //  properties: {
  //    protocol: '*'
  //    sourcePortRange: '*'
  //    destinationPortRange: '*'
  //    sourceAddressPrefix: 'VirtualNetwork'
  //    destinationAddressPrefix: 'VirtualNetwork'
  //    access: 'Allow'
  //    priority: 4095
  //    direction: 'Outbound'
  //  }
  //}
  //{
  //  name: 'DenyAllOutbound'
  //  properties: {
  //    protocol: '*'
  //    sourcePortRange: '*'
  //    destinationPortRange: '*'
  //    sourceAddressPrefix: '*'
  //    destinationAddressPrefix: '*'
  //    access: 'Deny'
  //    priority: 4096
  //    direction: 'Outbound'
  //  }
  //}
]

var nsgMLStudioSubnetNsgRules = [
  {
    name: 'AllowInbound_BatchNodeManagement_29877'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '29877'
      sourceAddressPrefix: 'BatchNodeManagement'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 201
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowInbound_BatchNodeManagement_29876'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '29876'
      sourceAddressPrefix: 'BatchNodeManagement'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 210
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowInbound_AzureMachineLearning_44224'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '44224'
      sourceAddressPrefix: 'AzureMachineLearning'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 220
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowOutbound_AzureActiveDirectory'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRanges: [
        '80'
        '443'
      ] 
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureActiveDirectory'
      access: 'Allow'
      priority: 140
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureMachineLearning'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRanges: [
        '443'
        '8787'
        '18881'
      ] 
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureMachineLearning'
      access: 'Allow'
      priority: 150
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureMachineLearning_Udp'
    properties: {
      protocol: 'UDP'
      sourcePortRange: '*'
      destinationPortRanges: [
        '5831'
      ] 
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureMachineLearning'
      access: 'Allow'
      priority: 151
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_BatchNodeManagement'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRanges: [
        '443'
      ] 
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'BatchNodeManagement'
      access: 'Allow'
      priority: 152
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureResourceManager'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureResourceManager'
      access: 'Allow'
      priority: 160
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_Storage'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRanges: [
        '443'
        '445'
      ] 
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'Storage'
      access: 'Allow'
      priority: 170
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureFrontDoor_FrontEnd'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureFrontDoor.Frontend'
      access: 'Allow'
      priority: 180
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_MicrosoftContainerRegistry'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'MicrosoftContainerRegistry'
      access: 'Allow'
      priority: 190
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureMonitor'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureMonitor'
      access: 'Allow'
      priority: 200
      direction: 'Outbound'
    }
  }     
]

var PaasResourcesNsgRuleswithSynapse = [
  {
    name: 'AllowOutbound_AzureActiveDirectory'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRanges: [
        '80'
        '443'
      ] 
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureActiveDirectory'
      access: 'Allow'
      priority: 140
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureResourceManager'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureResourceManager'
      access: 'Allow'
      priority: 160
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureFrontDoor_FrontEnd'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureFrontDoor.Frontend'
      access: 'Allow'
      priority: 180
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureMonitor'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureMonitor'
      access: 'Allow'
      priority: 200
      direction: 'Outbound'
    }
  }
]

resource r_nsgLogicAppsSubnet 'Microsoft.Network/networkSecurityGroups@2022-01-01' = if (DeployLogicApp == 'True') {
  name: '${vnetName}-${LogicAppSubnetName}-NSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Dependency_on_Azure_Storage'
        properties: {
          description: 'Dependency on Azure blob storage'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 1000
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_on_Azure_Storage_SMB'
        properties: {
          description: 'Dependency on Azure blob storage SMB'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '445'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 1001
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_on_Azure_LogicApps'
        properties: {
          description: 'Dependency on Azure Logic Apps'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'LogicApps'
          access: 'Allow'
          priority: 1002
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_on_Azure_Connectors'
        properties: {
          description: 'Dependency on Azure Connectors'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureConnectors'
          access: 'Allow'
          priority: 1003
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource r_nsgFunctionAppsSubnet 'Microsoft.Network/networkSecurityGroups@2022-01-01' = if (DeployFunctionApp == 'True') {
  name: '${vnetName}-${FunctionAppSubnetName}-NSG'
  location: location
  properties: {
    securityRules: []
  }
}

resource r_nsgazurePAASResourcesSubnet 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: '${vnetName}-${PrivateEndpointSubnetName}-NSG'
  location: location
  properties: {
    securityRules: (DeployMLWorkspace == 'True')?concat(DefaultNsgRules, nsgMLStudioSubnetNsgRules):concat(DefaultNsgRules, PaasResourcesNsgRuleswithSynapse)
  }
}

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}


resource r_AzurePaasResourcesSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: r_vnet
  name: PrivateEndpointSubnetName
  properties: {
    addressPrefix: azurePAASResourcesSubnetAddressSpace
    networkSecurityGroup: {
      id: r_nsgazurePAASResourcesSubnet.id
    }
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
  dependsOn: [    
  ]
}

resource r_logicAppSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = if (DeployLogicApp == 'True') {
  parent: r_vnet
  name: LogicAppSubnetName
  properties: {
    addressPrefix: logicAppSubnetAddressSpace
    networkSecurityGroup: {
      id: r_nsgLogicAppsSubnet.id
    }
    delegations: [
      {
        name: 'delegation'
        id: '${r_vnet.id}/subnets/${LogicAppSubnetName}/delegations/delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverfarms'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
      }
    ]
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
  dependsOn: [
    r_AzurePaasResourcesSubnet
  ]
}

resource r_FunctionAppSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = if (DeployFunctionApp == 'True') {
  parent: r_vnet
  name: FunctionAppSubnetName
  properties: {
    addressPrefix: functionAppSubnetAddressSpace
    networkSecurityGroup: {
      id: r_nsgFunctionAppsSubnet.id
    }
    delegations: [
      {
        name: 'delegation'
        id: '${r_vnet.id}/subnets/${FunctionAppSubnetName}/delegations/delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverfarms'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
      }
    ]
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
  dependsOn: [
    r_logicAppSubnet
  ]
}

resource r_nsgApiManagementSubnet 'Microsoft.Network/networkSecurityGroups@2022-07-01' = if (DeployApiManagement == 'True') {
  name: '${vnetName}-${ApiManagementSubnetName}-NSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Management_endpoint_for_Azure_portal_and_Powershell'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3443'
          sourceAddressPrefix: 'ApiManagement'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'Dependency_on_Redis_Cache'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '6381-6383'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'Dependency_to_sync_Rate_Limit_Inbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '4290'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 135
          direction: 'Inbound'
        }
      }
      {
        name: 'Dependency_on_Azure_SQL'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Sql'
          access: 'Allow'
          priority: 140
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_for_Log_to_event_Hub_policy'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '5671'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'EventHub'
          access: 'Allow'
          priority: 150
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_on_Redis_Cache_outbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '6381-6383'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 160
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_To_sync_RateLimit_Outbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '4290'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 165
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_on_Azure_File_Share_for_GIT'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '445'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 170
          direction: 'Outbound'
        }
      }
      {
        name: 'Azure_Infrastructure_Load_Balancer'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '6390'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 180
          direction: 'Inbound'
        }
      }
      {
        name: 'Publish_DiagnosticLogs_And_Metrics'
        properties: {
          description: 'API Management logs and metrics for consumption by admins and your IT team are all part of the management plane'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureMonitor'
          access: 'Allow'
          priority: 185
          direction: 'Outbound'
          destinationPortRanges: [
            '443'
            '12000'
            '1886'
          ]
        }
      }
      {
        name: 'Connect_To_SMTP_Relay_For_SendingEmails'
        properties: {
          description: 'APIM features the ability to generate email traffic as part of the data plane and the management plane'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 190
          direction: 'Outbound'
          destinationPortRanges: [
            '25'
            '587'
            '25028'
          ]
        }
      }
      {
        name: 'Authenticate_To_Azure_Active_Directory'
        properties: {
          description: 'Connect to Azure Active Directory for developer portal authentication or for OAuth 2 flow during any proxy authentication'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureActiveDirectory'
          access: 'Allow'
          priority: 200
          direction: 'Outbound'
          destinationPortRanges: [
            '80'
            '443'
          ]
        }
      }
      {
        name: 'Dependency_on_Azure_Storage'
        properties: {
          description: 'APIM service dependency on Azure blob and Azure table storage'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'Publish_Monitoring_Logs'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 300
          direction: 'Outbound'
        }
      }
      {
        name: 'Access_KeyVault'
        properties: {
          description: 'Allow API Management service control plane access to Azure Key Vault to refresh secrets'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureKeyVault'
          access: 'Allow'
          priority: 350
          direction: 'Outbound'
          destinationPortRanges: [
            '443'
          ]
        }
      }
      {
        name: 'Deny_All_Internet_Outbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Deny'
          priority: 999
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource r_ApimSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = if (DeployApiManagement == 'True') {
  parent: r_vnet
  name: ApiManagementSubnetName
  properties: {
    addressPrefix: apiManagementSubnetAddressSpace
    networkSecurityGroup: {
      id: r_nsgApiManagementSubnet.id
    }
    serviceEndpoints: apimSubnetServiceEndpoints    
  }
  dependsOn: [
    r_FunctionAppSubnet
  ]
}
