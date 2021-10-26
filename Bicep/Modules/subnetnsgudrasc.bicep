param vnetName string
param nsgIdArray array
param routeTableArray array
param subnetArray array

resource nsgudrassociate 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = [for (subnet,index) in subnetArray : {
  name: '${vnetName}/${subnet.name}'
  properties: {
    addressPrefix: subnet.properties.addressPrefix
    networkSecurityGroup: {
      id: nsgIdArray[index].resourceId
    }
    routeTable: {
      id: routeTableArray[index].resourceId 
    }
    }
}]

