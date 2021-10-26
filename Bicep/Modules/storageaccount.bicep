param stgAccName string
param vnetId string

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: stgAccName
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
  properties: {
     allowBlobPublicAccess: false
     networkAcls: {
       defaultAction: 'Allow'
       virtualNetworkRules: [
          {
            id: vnetId
            action: 'Allow'
          }
       ]
     }
  }
}

output stgId string = storageaccount.id
