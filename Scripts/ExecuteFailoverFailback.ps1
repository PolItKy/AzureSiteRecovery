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
        $mode,
        [Parameter(Mandatory=$true)]
        [string]
        $direction
)

function JobChecker ([object] $jb)
{
   do {
		Start-Sleep -Seconds 10
		$job = Get-AsrJob -Job $jb
		Write-Output $job.State
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

#Setting Inverse direction for reprotection based on Direction 
if ($direction -eq "PrimaryToRecovery")
{
   $inverseDirection = "RecoveryToPrimary"
}
elseif ($direction -eq "RecoveryToPrimary") {
   $inverseDirection = "PrimaryToRecovery"   
}

#Default variables
$rsvVault = "ppt-rsv-aus-"+$envtLabel+$subLabel+"01-01"

#Setting Recovery Services Vault Context
$Vault = Get-AzRecoveryServicesVault -Name $rsvVault
$context = Set-AzRecoveryServicesAsrVaultContext -vault $Vault

$recoveryPlan = Get-AzRecoveryServicesAsrRecoveryPlan -Name $RPName

#Execute Failover/Failback based on direction
if ($mode -eq "DR")
{
   Write-Output ("Starting Unplanned Failover for recovery plan $RPName")
   $failoverJob = Start-AzRecoveryServicesAsrUnplannedFailoverJob -RecoveryPlan $recoveryPlan -Direction $direction
   $jobState = JobChecker -jb $failoverJob
   Write-Output ("Unplanned Failover $jobState for recovery plan $RPName for direction $direction")
}

#Execute Commit once failover/failback
if ($mode -eq "Commit")
{
   $commitJob = Start-AzRecoveryServicesAsrCommitFailoverJob -RecoveryPlan $recoveryPlan
   $jobState = JobChecker -jb $commitJob
   Write-Output ("Commit $jobState for recovery plan $RPName post recovery $direction")
}

#Execute ReProtect once Commit
#Not working due to https://github.com/Azure/azure-powershell/issues/15712
if ($mode -eq "Reprotect")
{
   $reprotectJob = Update-AzRecoveryServicesAsrProtectionDirection -RecoveryPlan $recoveryPlan -Direction $inverseDirection
   $jobState = JobChecker -jb $reprotectJob
   Write-Output ("ReProtect $jobState for recovery plan $RPName for direction $inverseDirection")
}

