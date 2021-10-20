param (
        [Parameter(Mandatory=$true)]
        [string]
        $RPName,
        [Parameter(Mandatory=$true)]
        [string]
        $envtlabel,
        [Parameter(Mandatory=$true)]
        [string]
        $sublabel,
        [Parameter(Mandatory=$true)]
        [string]
        $direction,
        [Parameter(Mandatory=$true)]
        [string]
        $mode
)
function JobChecker ([object] $jb)
{
   do {
		Start-Sleep -Seconds 30
		$job = Get-AsrJob -Job $jb
	} while ($job.State -ne 'Succeeded' -and $job.State -ne 'Failed' -and $job.State -ne 'CompletedWithInformation')

   return $job.state
}

#Setting Subscription Label
if ($sublabel -like "*StandardSecurity*")
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
$rsvVault = "ppt-rsv-aus-"+$envtLabel+$subLabel+"01-01"

if ($direction -eq "PrimaryToRecovery")
{
   $testVnet = "ppt-vnt-aus-"+$envtLabel+$subLabel+"01-02"
}
elseif ($direction -eq "RecoveryToPrimary") {
   $testVnet = "ppt-vnt-aue-"+$envtLabel+$subLabel+"01-02"
}

$testVnetId = (Get-AzResource -Name $testVnet).ResourceId
$Vault = Get-AzRecoveryServicesVault -Name $rsvVault
$context = Set-AzRecoveryServicesAsrVaultContext -vault $Vault

$recoveryPlan = Get-AzRecoveryServicesAsrRecoveryPlan -Name $RPName

if ($mode -eq "TestFailover")
{
   $testFailoverJob = Start-AzRecoveryServicesAsrTestFailoverJob -RecoveryPlan $recoveryPlan -Direction $direction -AzureVMNetworkId $testVnetId
   $jobState = JobChecker -jb $testFailoverJob
   Write-Output ("Test Failover $jobState for recovery plan $RPName")
}


#Execute Test Failover Cleanup once Test Failover is completed
if ($mode -eq "Cleanup")
{
   $testFailoverCleanupJob = Start-AzRecoveryServicesAsrTestFailoverCleanupJob -RecoveryPlan $recoveryPlan
   $jobState = JobChecker -jb $testFailoverCleanupJob
   Write-Output ("Test Failover Cleanup $jobState for recovery plan $RPName")
}
