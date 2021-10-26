targetScope = 'subscription'

param rgName string
param rgLocation string
param subnetArray array
param vnetAddressPrefix string 
param vnetName string
param nsgName string
param udrName string
param rsVault object

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: rgLocation
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
  }
}

module rsv 'Modules/RecoveryServicesVault.bicep' = {
  scope: rg
  name: 'rsv-${rgName}'
  params: {
    primaryLocation: rsVault.primaryLocation
    rsvName: rsVault.rsvName
    secondaryLocation: rsVault.secondaryLocation
    srcVnet: rsVault.srcVnet
    tgtVnet: rsVault.tgtVnet
    replicationPolicyArray: rsVault.replicationPolicies
  }
  dependsOn: [
    vnet
  ]
}

module nsgudrasc 'Modules/subnetnsgudrasc.bicep' = {
  scope: rg
  name: 'nsdudrascmodule-${rgName}'
  dependsOn: [
    vnet
    routeTable
    nsg
  ]
  params: {
    nsgIdArray: nsg.outputs.nsgIds
    routeTableArray: routeTable.outputs.routeTables
    subnetArray: vnet.outputs.subnets
    vnetName: vnetName
  }
}
