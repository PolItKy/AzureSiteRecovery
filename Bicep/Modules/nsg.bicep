param subnetArray array 
param nsgName string

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = [for subnetName in subnetArray: {
  name: '${nsgName}-${subnetName.name}'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'Allow_Storage_Aue'
        properties: {
            description: 'Allow_Storage_Aue'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'Storage.AustraliaEast'
            access: 'Allow'
            priority: 100
            direction: 'Outbound'
            sourcePortRanges: []
            destinationPortRanges: []
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []
        }
    }
    {
        name: 'Allow_Storage_Aus'
        properties: {
            description: 'Allow_Storage_Aus'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'Storage.AustraliaSoutheast'
            access: 'Allow'
            priority: 110
            direction: 'Outbound'
            sourcePortRanges: []
            destinationPortRanges: []
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []
        }
    }
    {
        name: 'Allow_Aad'
        properties: {
            description: 'Allow_Aad'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'AzureActiveDirectory'
            access: 'Allow'
            priority: 120
            direction: 'Outbound'
            sourcePortRanges: []
            destinationPortRanges: []
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []
        }
    }
    {
        name: 'Allow_Eventhub_Aue'
        properties: {
            description: 'Allow_Eventhub_Aue'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'EventHub.AustraliaEast'
            access: 'Allow'
            priority: 130
            direction: 'Outbound'
            sourcePortRanges: []
            destinationPortRanges: []
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []
        }
    }
    {
        name: 'Allow_Eventhub_Aus'
        properties: {
            description: 'Allow_Eventhub_Aus'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'EventHub.AustraliaSoutheast'
            access: 'Allow'
            priority: 140
            direction: 'Outbound'
            sourcePortRanges: []
            destinationPortRanges: []
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []
        }
    }
    {
        name: 'Allow_ASR'
        properties: {
            description: 'Allow_ASR'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'AzureSiteRecovery'
            access: 'Allow'
            priority: 150
            direction: 'Outbound'
            sourcePortRanges: []
            destinationPortRanges: []
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []
        }
    }
    {
        name: 'Allow_KV_Aue'
        properties: {
            description: 'Allow_KV_Aue'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'AzureKeyVault.AustraliaEast'
            access: 'Allow'
            priority: 160
            direction: 'Outbound'
            sourcePortRanges: []
            destinationPortRanges: []
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []
        }
    }
    {
        name: 'Allow_KV_Aus'
        properties: {
            description: 'Allow_KV_Aus'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'AzureKeyVault.AustraliaSoutheast'
            access: 'Allow'
            priority: 170
            direction: 'Outbound'
            sourcePortRanges: []
            destinationPortRanges: []
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []
        }
    }
    {
        name: 'Allow_GuestAndHybridManagement'
        properties: {
            description: 'Allow_GuestAndHybridManagement'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'GuestAndHybridManagement'
            access: 'Allow'
            priority: 180
            direction: 'Outbound'
            sourcePortRanges: []
            destinationPortRanges: []
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []
        }
    }
    ]
  }
}]

output nsgIds array = [for (subnetName, index) in subnetArray: {
  name: networkSecurityGroup[index].name
  resourceId: networkSecurityGroup[index].id
}]
