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
    replicationPolicyArray: rsVault.replicationPolicies
  }
}
