param subnetArray array 
param nsgName string

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = [for subnetName in subnetArray: {
  name: '${nsgName}-${subnetName.name}'
  location: resourceGroup().location
}]

output nsgIds array = [for (subnetName, index) in subnetArray: {
  name: networkSecurityGroup[index].name
  resourceId: networkSecurityGroup[index].id
}]
