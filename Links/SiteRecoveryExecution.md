
# ASR Execution

Execution of ASR should be controlled by multiple controls as its a sensitive action that can cause significant disruptions to your infrastructure. ASR can be triggered in several ways. 
- Azure portal by failover/failover of single replicated items, recovery plans comprising underlying Virtual machines. Regardless, Ensure its fully protected by RBAC 

https://docs.microsoft.com/en-us/azure/site-recovery/site-recovery-role-based-linked-access-control

- If pipelines are being built in Azure Devops/Github ensure they are controlled by Branch controls, Environment based approvals. 

Below scripts are available to perform Test Failover and Failover. They can be used in pipelines/workflows to automate the ASR execution. 

The Scripts expects,
- Recovery Plan Name
- Recovery Services Vault Name
- Test Virtual Network name
- Mode(TestFailover,Cleanup)
- Direction(PrimaryToRecovery,RecoveryToPrimary)

https://github.com/aravindsundaram/AzureSiteRecovery/blob/main/Scripts/ExecuteTestFailover.ps1

The Scripts expects,
- Recovery Plan Name
- Recovery Services Vault Name
- Mode(DR,Commit,Reprotect)
- Direction(PrimaryToRecovery,RecoveryToPrimary)

For eg: Mode DR is responsible to failover or failback Virtual machines depending on the direction. 

https://github.com/aravindsundaram/AzureSiteRecovery/blob/main/Scripts/ExecuteFailoverFailback.ps1
