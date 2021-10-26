param vnetName string
param vnetAddressPrefix string
param subnetArray array
param nsgIdArray array
param routeTableArray array

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
        networkSecurityGroup: {
          id: nsgIdArray[index].resourceId
        }
        routeTable: {
          id: routeTableArray[index].resourceId 
        }
      }
    }]
  }
}

output subnets array = virtualNetwork.properties.subnets
output vnetid string = virtualNetwork.id
output vnetName string = virtualNetwork.name

