param (
        [Parameter(Mandatory=$true)]
        [string]
        $vmCsvPath,
        [Parameter(Mandatory=$true)]
        [string]
        $groupActionCsvPath,
        [Parameter(Mandatory=$true)]
        [string]
        $baseTemplatePath,
        [Parameter(Mandatory=$true)]
        [string]
        $envtlabel,
        [Parameter(Mandatory=$true)]
        [string]
        $sublabel,
        [Parameter(Mandatory=$true)]
        [string]
        $armTemplateFile,
        [Parameter(Mandatory=$true)]
        [string]
        $recoveryPlan
)

function Split-StringObject ([object] $stringObject) {
    if ($stringObject -is [string] -and -not [string]::IsNullOrEmpty($stringObject)) {
        $outputArrayValue = $stringObject.Split($arrayDelimiter)
        return [array] $outputArrayValue
    }
    else {
        return @()
    }
}

#Default Variables
$primaryRegion = "australiaeast"
$primaryContinerName = "australiaeast-container"
$templateName = "recoveryPlan.parameters.json"
$arrayDelimiter = ","

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

#Setting Automation AccountID for Runbook based tasks in Recovery Plan
if ($envtLabel -eq "tst")
{
    $automationAccountId = "/subscriptions/d08e79e9-05b2-48f6-a05f-55935de93086/resourceGroups/ppt-rg-aue-tstmgt01-01-mon/providers/Microsoft.Automation/automationAccounts/ppt-aa-aue-tstmgt01-01"
}
else
{
    $automationAccountId = "/subscriptions/3a3260d4-ea73-4ac3-94f4-0a4985479b10/resourceGroups/ppt-rg-aue-pltmgt01-01-mon/providers/Microsoft.Automation/automationAccounts/ppt-aa-aue-pltmgt01-01"
}

$rsvVault = "ppt-rsv-aus-"+$envtLabel+$subLabel+"01-01"
$rsvRg = "ppt-rg-aus-"+$envtLabel+$subLabel+"01-01-net"
$Vault = Get-AzRecoveryServicesVault -Name $rsvVault
$context = Set-AzRecoveryServicesAsrVaultContext -vault $Vault
$baseTemplate = "$baseTemplatePath\$templateName"

#Import Base Param file
$recoveryPlanfile = ConvertFrom-Json -inputobject ( Get-Content -Raw -Path $baseTemplate )

#Import VMs for DR 
$vmCsv = import-csv $vmCsvPath 
#Import Group Actions for RecoveryPlan Group Actions
$groupActions = import-csv $groupActionCsvPath -Delimiter "|"

    $maxline = $vmCsv | Where-object { $_.recoveryPlan -eq $recoveryPlan} | Sort-object group | Select-object -Last 1
    [int] $groupCount= [int] $maxline.group
    [int] $i = 1
    write-output $groupCount
    if ( $groupCount -ge 1)
    {
    $recoveryGroupsArray = New-Object System.Collections.ArrayList
    for([int] $i=1; $i -le $groupCount ; $i++ )
    {
        $finalStartAction = @()
        $finalEndAction = @()
        #Select VMs as per group
        $vmSubset = $vmCsv | Where-object { ($_.recoveryPlan -eq $recoveryPlan) -and ($_.group -eq $i) }
        Write-output ("Processing Replication group " + $i + " for recovery plan " + $recoveryPlan)
        #Create Recovery Protected Items Array
        $replicationProtArray = $vmSubset | ForEach-Object {
            $primaryFabric = get-asrfabric | Where-object {$_.FabricSpecificDetails.Location -like $primaryRegion} 
            $primaryContainer = Get-ASRProtectionContainer -Name $PrimaryContinerName -Fabric $primaryFabric
            $protDetails = Get-AzRecoveryServicesAsrReplicationProtectedItem -Name $_.vmName -ProtectionContainer $primaryContainer
            $protId = $protDetails.Id
            $vmDetails = Get-AzVM -ResourceGroupName $_.resourceGroup -Name $_.vmName 
            $vmId = $vmDetails.Id 
            [PSCustomObject]@{
                id = $protId
                virtualMachineId = $vmId 
            }

        }
        #Fetch Group Actions from ASRGroupActions object
        $action = $groupActions | Where-object { ($_.recoveryPlan -eq $recoveryPlan) -and ($_.group -eq $i )} 

        ###Start Group Action
        
        #Logic to transform to Manual action
        if ($action.startAction -eq 'Manual')
        {
            $startCustomDetails=  [PSCustomObject]@{
                instanceType = 'ManualActionDetails'
                description = $action.startActionDescription
            }
            $finalStartAction = [PSCustomObject]@{
                actionName = $action.startActionName
                failoverTypes = [string[]] (Split-StringObject $action.failoverType)  
                failoverDirections =  [string[]] (Split-StringObject $action.failoverDirections)
                customDetails = $startCustomDetails 
            }         
            
        }
        #Logic to transform to Runbook action 
        elseif( $action.startAction -eq 'Runbook') {
            $runbookName = $action.startActionName
            $runbookId = ($automationAccountId+"/runbooks/"+$runbookName)
            $startCustomDetails =  [PSCustomObject]@{
                instanceType = 'AutomationRunbookActionDetails'
                runbookId = $runbookId
                description = $action.startActionDescription
                fabricLocation = 'Primary'
            }
            $finalStartAction = [PSCustomObject]@{
                actionName = $action.startActionName
                failoverTypes = [string[]] (Split-StringObject $action.failoverType)  
                failoverDirections =  [string[]] (Split-StringObject $action.failoverDirections)
                customDetails = $startCustomDetails 
            }    
        }
        elseif( !$action ) {
            $finalStartAction = @()            
        }

        ###End Group Action

        #Logic to transform to Manual action
        if ($action.endAction -eq 'Manual')
        {
            $endCustomDetails =  [PSCustomObject]@{
                instanceType = 'ManualActionDetails'
                description = $action.endActionDescription
            }
            $finalEndAction = [PSCustomObject]@{
                actionName = $action.endActionName
                failoverTypes = [string[]] (Split-StringObject $action.failoverType)  
                failoverDirections =  [string[]] (Split-StringObject $action.failoverDirections)
                customDetails = $endCustomDetails 
            }    

        }
        #Logic to transform to Runbook action 
        elseif( $action.endAction -eq 'Runbook') {
            $runbookName = $action.endActionName
            $runbookId = ($automationAccountId+"/runbooks/"+$runbookName)
            $endCustomDetails =  [PSCustomObject]@{
                instanceType = 'AutomationRunbookActionDetails'
                runbookId = $runbookId
                description = $action.endActionDescription
                fabricLocation = 'Primary'
            }
            $finalEndAction = [PSCustomObject]@{
                actionName = $action.endActionName
                failoverTypes = [string[]] (Split-StringObject $action.failoverType)  
                failoverDirections =  [string[]] (Split-StringObject $action.failoverDirections)
                customDetails = $endCustomDetails 
            }           
        }
        elseif( !$action) {
            $finalEndAction = @()            
        }
        
        #Create Recovery Group Array
        $recoveryGroups = [PSCustomObject]@{
                groupType = "Boot"
                replicationProtectedItems = [array] $replicationProtArray
                startGroupActions =  [array] $finalStartAction
                endGroupActions =  [array] $finalEndAction
        }

        $recoveryGroupsArray.Add($recoveryGroups)
    }
    
    #create Recovery Plan Finalized Param file with Array
    $recoveryPlanfile.parameters.recoveryVaultName.value = $rsvVault

    $recoveryPlanfile.parameters.recoveryPlanName.value = "RecoveryPlan-$recoveryPlan"

    $recoveryPlanfile.parameters.recoveryGroups.value = [array] $recoveryGroupsArray

    #Convert to Json Parameters
    $recoveryPlanJson = ConvertTo-Json -InputObject $recoveryPlanfile -Depth 10
    
    write-output "Finalizing Parameters file for Recovery Plan for $recoveryPlan"
    
    #Populate final Parameters json file for ARM template deployment
    $recoveryPlanJson | Set-Content $baseTemplatePath\"RecoveryPlan-$recoveryPlan.parameters.json"

    Write-output $recoveryPlanJson

    Write-output ("Parameter file is $baseTemplatePath\RecoveryPlan-$recoveryPlan.parameters.json")

    $plns = Get-AzRecoveryServicesAsrRecoveryPlan

    #Verify and Delete the Recovery Plan before creating or changing
    foreach($pln in $plns)
    {
        if ($pln.Name -eq "RecoveryPlan-$recoveryPlan")
        {
            Remove-AzRecoveryServicesAsrRecoveryPlan -Name "RecoveryPlan-$recoveryPlan"
            Write-Output ("Recovery Plan already exists. Deleted to allow new changes")
        }
    }

    $DeploymentInputs = @{
                     Name                  = "RecoveryPlan-$recoveryPlan-$(-join (Get-Date -Format yyyyMMddTHHMMssffffZ)[0..63])"
                     TemplateFile          = $armTemplateFile
                     TemplateParameterFile = "$baseTemplatePath\RecoveryPlan-$recoveryPlan.parameters.json"
                     Verbose               = $true
                     ErrorAction           = "Stop"
                   }
    try
    {
        Write-output ("Performing ARM template deployment for RecoveryPlan-$recoveryPlan")
        New-AzResourceGroupDeployment @DeploymentInputs -ResourceGroupName $rsvRg
    }
    catch
    {
        Write-Error $_ 
    }

    }
    else
    {
        Write-output ("No Groups found. Skipping recovery plan $recoveryPlan")
    }
