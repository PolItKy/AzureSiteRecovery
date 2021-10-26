param vnetName string
param vnetAddressPrefix string
param subnetArray array

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [for (subnet,index) in subnetArray: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        serviceEndpoints: []
      }
    }]
  }
}

output subnets array = virtualNetwork.properties.subnets
output vnetid string = virtualNetwork.id
output vnetName string = virtualNetwork.name

