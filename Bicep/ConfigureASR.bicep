targetScope = 'subscription'

param rsVault object
param rgName string

module rsv 'Modules/RecoveryServicesVault.bicep' = {
  scope: resourceGroup(rgName)
  name: 'rsv-${rgName}'
  params: {
    primaryLocation: rsVault.primaryLocation
    rsvName: rsVault.rsvName
    secondaryLocation: rsVault.secondaryLocation
    srcVnet: rsVault.srcVnet
    tgtVnet: rsVault.tgtVnet
    srcVnetRg: rsVault.srcVnetRg
    tgtVnetRg: rsVault.tgtVnetRg
    replicationPolicyArray: rsVault.replicationPolicies
  }
}
