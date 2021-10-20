param rsvName string
param primaryLocation string
param secondaryLocation string
param sourceFabricName string
param targetFabricName string
param sourceContainer string
param targetContainer string
param srcVnet string
param tgtVnet string
var srcRegion = 'australiaeast'
var tgtRegion = 'australiasoutheast'



resource rsv 'Microsoft.RecoveryServices/vaults@2021-06-01' = {
  name: rsvName
  location: secondaryLocation
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

resource srcNwMapping 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationNetworks/replicationNetworkMappings@2021-06-01' = {
  name: '${rsvName}/${sourceFabricName}/azurenetworks/${srcRegion}-${tgtRegion}-${srcVnet}'
  properties: {
    recoveryNetworkId: resourceId('Microsoft.Network/virtualNetworks', tgtVnet)
    recoveryFabricName: targetFabricName
    fabricSpecificDetails: {
      primaryNetworkId: resourceId('Microsoft.Network/virtualNetworks', srcVnet)
      instanceType: 'AzureToAzure'
    }
  }
}

resource tgtNwMapping 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationNetworks/replicationNetworkMappings@2021-06-01' = {
  name: '${rsvName}/${sourceFabricName}/azurenetworks/${tgtRegion}-${srcRegion}-${tgtVnet}'
  properties: {
    recoveryNetworkId: resourceId('Microsoft.Network/virtualNetworks', srcVnet)
    recoveryFabricName: sourceFabricName
    fabricSpecificDetails: {
      primaryNetworkId: resourceId('Microsoft.Network/virtualNetworks', tgtVnet)
      instanceType: 'AzureToAzure'
    }
  }
}
