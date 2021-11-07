param rsvName string
param primaryLocation string
param secondaryLocation string

param srcVnet string
param tgtVnet string
param srcVnetRg string
param tgtVnetRg string
param replicationPolicyArray array

var srcRegion = 'australiaeast'
var tgtRegion = 'southeastasia'
var sourceFabricName ='${srcRegion}-fabric'
var targetFabricName ='${tgtRegion}-fabric'
var sourceContainer = '${srcRegion}-container'
var targetContainer = '${tgtRegion}-container'



resource rsv 'Microsoft.RecoveryServices/vaults@2021-06-01' = {
  name: rsvName
  location: resourceGroup().location
  sku:  {
     name: 'RS0'
     tier: 'Standard'
  }
  properties: {
  }
}

resource srcFab 'Microsoft.RecoveryServices/vaults/replicationFabrics@2021-06-01' = {
  name: '${rsvName}/${sourceFabricName}'
  properties: {
      customDetails: {
        instanceType: 'Azure'
        location: primaryLocation
      }
  }
  dependsOn: [
    rsv
  ]
}

resource tgtFab 'Microsoft.RecoveryServices/vaults/replicationFabrics@2021-06-01' = {
  name: '${rsvName}/${targetFabricName}'
  properties: {
      customDetails: {
        instanceType: 'Azure'
        location: secondaryLocation
      }
  }
  dependsOn: [
    rsv
  ]
}

resource srcCtr 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers@2021-06-01' = {
  name: '${rsvName}/${sourceFabricName}/${sourceContainer}'
  properties: {
     providerSpecificInput: [
        {
          instanceType: 'A2A'
        }
     ]
  }
  dependsOn: [
    srcFab
  ]
}

resource tgtCtr 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers@2021-06-01' = {
  name: '${rsvName}/${targetFabricName}/${targetContainer}'
  properties: {
     providerSpecificInput: [
        {
          instanceType: 'A2A'
        }
     ]
  }
  dependsOn: [
     tgtFab
  ]
}

resource replPolicy 'Microsoft.RecoveryServices/vaults/replicationPolicies@2021-06-01' = [for policy in replicationPolicyArray: {
  name: '${rsvName}/${policy.name}'
  properties: {
     providerSpecificInput: {
       multiVmSyncStatus: 'Enable'
       instanceType: 'A2A'
       appConsistentFrequencyInMinutes: policy.appConsistentFrequencyInMinutes
       crashConsistentFrequencyInMinutes: policy.crashConsistentFrequencyInMinutes
       recoveryPointHistory: policy.recoveryPointHistory
     }
  }
  dependsOn: [
    rsv
  ]
}]

resource srcCntMapping 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectionContainerMappings@2021-06-01' = [for policy in replicationPolicyArray: {
  name: '${rsvName}/${sourceFabricName}/${sourceContainer}/${srcRegion}-${tgtRegion}-${policy.name}'
  properties: {
     policyId: resourceId('Microsoft.RecoveryServices/vaults/replicationPolicies', rsvName, policy.name)
     providerSpecificInput: {
       instanceType: 'A2A'
     }
     targetProtectionContainerId: tgtCtr.id
  }
  dependsOn: [
    replPolicy
    srcFab
    tgtFab
    srcCtr
    tgtCtr
  ]
}]

resource tgtCntMapping 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectionContainerMappings@2021-06-01' = [for policy in replicationPolicyArray: {
  name: '${rsvName}/${targetFabricName}/${targetContainer}/${tgtRegion}-${srcRegion}-${policy.name}'
  properties: {
     policyId: resourceId('Microsoft.RecoveryServices/vaults/replicationPolicies', rsvName, policy.name)
     providerSpecificInput: {
       instanceType: 'A2A'
     }
     targetProtectionContainerId: srcCtr.id
  }
  dependsOn: [
    replPolicy
    srcFab
    tgtFab
    srcCtr
    tgtCtr
  ]
}]

resource srcNwMapping 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationNetworks/replicationNetworkMappings@2021-06-01' = {
  name: '${rsvName}/${sourceFabricName}/azurenetworks/${srcRegion}-${tgtRegion}-${srcVnet}'
  properties: {
    recoveryNetworkId: resourceId(tgtVnetRg, 'Microsoft.Network/virtualNetworks', tgtVnet)
    recoveryFabricName: targetFabricName
    fabricSpecificDetails: {
      primaryNetworkId: resourceId(srcVnetRg, 'Microsoft.Network/virtualNetworks' , srcVnet)
      instanceType: 'AzureToAzure'
    }
  }
  dependsOn: [
    rsv
    srcFab
    tgtFab
  ]
}

resource tgtNwMapping 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationNetworks/replicationNetworkMappings@2021-06-01' = {
  name: '${rsvName}/${targetFabricName}/azurenetworks/${tgtRegion}-${srcRegion}-${tgtVnet}'
  properties: {
    recoveryNetworkId: resourceId(srcVnetRg, 'Microsoft.Network/virtualNetworks', srcVnet)
    recoveryFabricName: sourceFabricName
    fabricSpecificDetails: {
      primaryNetworkId: resourceId(tgtVnetRg, 'Microsoft.Network/virtualNetworks', tgtVnet)
      instanceType: 'AzureToAzure'
    }
  }
  dependsOn: [
    rsv
    srcFab
    tgtFab
  ]
}
