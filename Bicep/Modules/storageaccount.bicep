param stgAccName string

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: stgAccName
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
}

output stgId string = storageaccount.id
