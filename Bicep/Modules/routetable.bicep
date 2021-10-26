param subnetArray array
param udrName string

resource routeTable 'Microsoft.Network/routeTables@2019-11-01' = [for subnetName in subnetArray: {
  name: '${udrName}-${subnetName.name}'
  location: resourceGroup().location
}]

output routeTables array = [for (subnetName, index) in subnetArray: {
  name: routeTable[index].name
  resourceId: routeTable[index].id
}]
