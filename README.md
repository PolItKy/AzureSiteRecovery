# AzureSiteRecovery IaC practices

Among the many use cases for ASR, this repository deals with disaster recovery for Azure Virtual machines between regions in Azure. 

It elaborates some of the common painpoints in configuring and executing ASR from a Infrastructure as Code perspective. 

**Enabling ASR:** https://github.com/aravindsundaram/AzureSiteRecovery/blob/main/Links/ConfigureSiteRecoveryVault.md

**Enabling Replication:** https://github.com/aravindsundaram/AzureSiteRecovery/blob/main/Links/EnableReplication.md

**Building Recovery Plan:** https://github.com/aravindsundaram/AzureSiteRecovery/blob/main/Links/RecoveryPlan.md

**Execution of ASR:** https://github.com/aravindsundaram/AzureSiteRecovery/blob/main/Links/SiteRecoveryExecution.md

A brief about Folder heirarchy

| Folders | Description |
| --- | ----------- |
| .github/Workflows | Workflows to deploy Landing Zones, Configure ASRs, Enable Replication, Create Recovery Plans |
| ARM | ARM template to configure ASR in Recovery Services Vault  |
| Bicep | Bicep Modules and Code to configure ASR and deploy Landing Zones  |
| Links | Read Me links 
| Parameters | Parameters in format of CSV files for Enabling Replication and Creating Recovery Plans  |
| Scripts | Azure Powershell scripts which is used for Enabling replication, Creating Recovery Plans and to Execute ASR |
| Templates | Recovery plan base template which will be used to programatically build and Create recovery plan 

**Some of the references**
- https://docs.microsoft.com/en-us/azure/site-recovery/
- https://adamtheautomator.com/azure-disaster-recovery/
- https://github.com/Huachao/azure-content/blob/master/articles/site-recovery/site-recovery-deploy-with-powershell-resource-manager.md
- http://terenceluk.blogspot.com/2021/07/automating-azure-site-recovery-recovery.html
- https://docs.microsoft.com/en-us/azure/templates/microsoft.recoveryservices/vaults?tabs=bicep
