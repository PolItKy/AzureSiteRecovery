targetScope = 'subscription'

param rgName string
param rgLocation string
param stgAccName string
param subnetArray array
param vnetAddressPrefix string 
param vnetName string
param nsgName string
param udrName string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: rgLocation
}

module stg 'Modules/storageaccount.bicep' = {
  scope: rg
  name: 'stgmodule-${rgName}'
  params: {
    stgAccName: stgAccName
    vnetId: vnet.outputs.vnetid
  }
}

module nsg 'Modules/nsg.bicep' = {
  name: 'nsgmodule-${rgName}'
  scope: rg
  params: {
    subnetArray: subnetArray
    nsgName: nsgName
  }
}

module routeTable 'Modules/routetable.bicep' = {
   name: 'routetablemodule-${rgName}'
   scope: rg
   params: {
     subnetArray: subnetArray
     udrName: udrName
   }
}

module vnet 'Modules/vnet.bicep' = {
  name: 'vnetmodule-${rgName}'
  scope: rg
  params: {
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    subnetArray: subnetArray
    nsgIdArray: nsg.outputs.nsgIds
    routeTableArray: routeTable.outputs.routeTables
  }
  dependsOn: [
    nsg
    routeTable
  ]
}
