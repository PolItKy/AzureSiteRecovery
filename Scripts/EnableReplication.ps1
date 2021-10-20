param (
        [Parameter(Mandatory=$true)]
        [string]
        $vmCsvPath,
        [Parameter(Mandatory=$true)]
        [string]
        $envtlabel,
        [Parameter(Mandatory=$true)]
        [string]
        $sublabel
)

#Setting Subscription Label
if ($sublabel -eq "StandardSecurity")
{
  $sublabel = "sts"
}

#Setting Envt Label
if ($envtLabel -eq "Test")
{
  $envtLabel = "tst"
}
elseif ($envtLabel -eq "NonProd") {
  $envtLabel = "npe"
}
elseif ($envtLabel -eq "Prod") {
   $envtLabel = "prd"
}

#Default Variables
$primaryRegion = "australiaeast"
$primaryASRStorageAccount = "pptstaaue"+$envtLabel+$subLabel+"0102"
$recoveryASRStorageAccount = "pptstaaus"+$envtLabel+$subLabel+"0102"
$asrResourceGroup = "ppt-rg-aus-"+$envtLabel+$subLabel+"01-01-asr"
$rsvVault = "ppt-rsv-aus-"+$envtLabel+$subLabel+"01-01"
$targetVirtualNetwork = "ppt-vnt-aus-"+$envtLabel+$subLabel+"01-01"
$primaryASRStorageAccountId = (Get-AzResource -Name $primaryASRStorageAccount).ResourceId
$recoveryASRStorageAccountId = (Get-AzResource -Name $recoveryASRStorageAccount).ResourceId
function Enable-Replication([string] $vmName, [string] $replicationPolicy,  [string] $sourceRg,  [string] $targetRg, [string] $rsvVault)
{
  Write-output ("Enabling Replication for VM: "+$vmName)
  $Vault = Get-AzRecoveryServicesVault -Name $rsvVault
  
  $targetResourceGroupId = (Get-AzResourceGroup -Name $targetRg).ResourceId
  
  $primaryContinerName = "australiaeast-container"
  
  $targetVirtualNetworkId = (Get-AzResource -Name $targetVirtualNetwork).ResourceId
  
  $context = Set-AzRecoveryServicesAsrVaultContext -vault $Vault
  
  $primaryFabric = get-asrfabric | Where-object {$_.FabricSpecificDetails.Location -like $primaryRegion} 
  
  $primaryContainer = Get-ASRProtectionContainer -Name $PrimaryContinerName -Fabric $primaryFabric
  
  ############
    
  $cnMapping = "australiaeast-australiasoutheast"
  
  $primaryContainerMapping = $cnMapping + "-$replicationPolicy"
  
  $primaryProtectionContainerMapping = Get-ASRProtectionContainerMapping -Name $primaryContainerMapping -ProtectionContainer $primaryContainer
  
  write-output "Populated Fabric and Container details for Replication"
  try {

  $vmDetails = Get-AzVM -ResourceGroupName $sourceResourceGroup -Name $vmName 
  
  $nicid = $vmDetails.NetworkProfile.NetworkInterfaces
  
  $nicName=($nicid.id  -split '/' )[-1]
  
  $nicDetails = Get-AzNetworkInterface -Name $nicName
  
  $subnetDetails = $nicdetails.IpConfigurations.Subnet
  
  $sourceSubnetName =($subnetDetails.id  -split '/' )[-1]
  
  $targetSubnetName = $sourceSubnetName + "ASR"
  
  $diskList =  New-Object System.Collections.ArrayList
  
  write-output "Adding OS disks for Replication"

  $osDisk = New-AzRecoveryServicesAsrAzureToAzureDiskReplicationConfig -DiskId $vmDetails.StorageProfile.OsDisk.ManagedDisk.Id `
		    -LogStorageAccountId $primaryASRStorageAccountId -ManagedDisk  -RecoveryReplicaDiskAccountType $vmDetails.StorageProfile.OsDisk.ManagedDisk.StorageAccountType `
		    -RecoveryResourceGroupId  $targetResourceGroupId -RecoveryTargetDiskAccountType $vmDetails.StorageProfile.OsDisk.ManagedDisk.StorageAccountType         
  
  $rc = $diskList.Add($osDisk)
  
  foreach($dataDisk in $vmDetails.StorageProfile.DataDisks)
  { 
    write-output "Adding Data disks for Replication"
    $disk = New-AzRecoveryServicesAsrAzureToAzureDiskReplicationConfig -DiskId $dataDisk.ManagedDisk.Id `
			        -LogStorageAccountId $primaryASRStorageAccountId -ManagedDisk  -RecoveryReplicaDiskAccountType $dataDisk.ManagedDisk.StorageAccountType `
			        -RecoveryResourceGroupId  $targetResourceGroupId -RecoveryTargetDiskAccountType $dataDisk.ManagedDisk.StorageAccountType
    $rc = $diskList.Add($disk)
  }
  
  Write-output ("Triggering Site Recovery job for VM: "+$vmName)
  $job = New-AzRecoveryServicesAsrReplicationProtectedItem -AzureToAzure -Name $vmName -RecoveryVmName $vmName -ProtectionContainerMapping $primaryProtectionContainerMapping `
		       -AzureVmId $vmDetails.ID -AzureToAzureDiskReplicationConfiguration $diskList -RecoveryResourceGroupId $TargetResourceGroupId `
		       -RecoveryAzureSubnetName $targetSubnetName -RecoveryAzureNetworkId $targetVirtualNetworkId #-RecoveryAzureStorageAccountId $recoveryASRStorageAccountId #-LogStorageAccountId $primaryASRStorageAccountId

  $rc =$enableReplicationJobs.Add($job)

  #return $job
  }
  catch
  {
    write-output ("Encountered error processing VM: $vmName " + $_)
  }
    
}

#from CSV file

#import CSV from vmCsvPath
$vmCsv = import-csv $vmCsvPath
$enableReplicationJobs = New-Object System.Collections.ArrayList

#Enable Replication for Each VM
foreach ($vm in $vmCsv)
{ 
  #if ($vm.vmName -eq "azpocw013")
  #{
  Write-output ("Processing VM: "+$vm.vmName)
  $vmName = $vm.vmName
  $sourceResourceGroup = $vm.resourceGroup
  $replicationPolicy = $vm.replicationPolicy

  Enable-Replication -vmName $vmName -replicationPolicy $replicationPolicy -sourceRg $sourceResourceGroup  -targetRg $asrResourceGroup -rsvVault $rsvVault
  #}
}

#Monitor Protection and Replication jobs for completion
foreach ($jb in $enableReplicationJobs) {
  if ($jb -ne $null)
  {
  Write-output ("Monitoring Site Recovery job for VM: " + $jb.TargetObjectName)
	do {
		Start-Sleep -Seconds 10
		$job = Get-AsrJob -Job $jb
		Write-Output $job.State
	} while ($job.State -ne 'Succeeded' -and $job.State -ne 'Failed' -and $job.State -ne 'CompletedWithInformation')

	if ($job.State -ne 'Succeeded') {
      Write-Output ('Job ' + $job.DisplayName + ' ' + $job.State + ' for ' + $job.TargetObjectName )
       foreach ($er in $job.Errors) {
        foreach ($pe in $er.ProviderErrorDetails) {
            $pe
        }
        foreach ($se in $er.ServiceErrorDetails) {
            $se
        }
       }
    }
  else {
    Write-Output ('Enable Replication completed for '+ $job.TargetObjectName + '. Initial Synchronization running in background')
  }
  }
}
