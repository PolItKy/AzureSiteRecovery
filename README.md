# AzureSiteRecovery IaC practices

Among the many use cases for ASR, this repository deals with disaster recovery for Azure Virtual machines between regions in Azure. 

It elaborates some of the common painpoints in configuring and executing ASR from a Infrastructure as Code perspective. 

**Enabling ASR:** https://github.com/aravindsundaram/AzureSiteRecovery/blob/main/1ConfigureSiteRecoveryVault.md

**Enabling Replication:** https://github.com/aravindsundaram/AzureSiteRecovery/blob/main/2EnableReplication.md

**Building Recovery Plan:** https://github.com/aravindsundaram/AzureSiteRecovery/blob/main/3RecoveryPlan.md

**Execution of ASR:** https://github.com/aravindsundaram/AzureSiteRecovery/blob/main/4SiteRecoveryExecution.md

A brief about Folder heirarchy

| Folders | Description |
| --- | ----------- |
| .github/Workflows | Workflows to deploy Landing Zones, Configure ASRs, Enable Replication, Create Recovery Plans and Execute ASR |
| ADOPipelines | Azure Devops Pipelines to perform the tasks mentioned above.  |
| ARM | ARM template to configure ASR in Recovery Services Vault  |
| Bicep | Bicep Modules and Code to configure ASR and deploy Landing Zones  |
| Parameters | Parameters in format of CSV files for Enabling Replication and Creating Recovery Plans  |
| Scripts | Azure Powershell scripts which is used for Enabling replication, Creating Recovery Plans and to Execute ASR |
