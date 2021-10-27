**Landing Zones for ASR**

Azure Site Recovery primarily operates on Recovery Services Vault and needs to be configured upfront before onboarding Virtual Machines into it. 

However, Before We configure Azure Site Recovery, We would need the below Landing Zone components.

- Resource Groups in Target/Destination region
- Cache Storage Accounts in Source Region 
- An Isolated Test network which will be used for Test Failover 
- Networking setup on the Target/Destination Region i.e Virtual Network, Network Security Group, UDRs if any, Flowlogs etc. 

Generally, Azure Site recovery creates Resource Groups, Cache storage accounts on the fly however to maintain consistency with naming patterns and avoid guid based resource names its good practice to create these Landing Zone resources. 

A simple landing zone can be deployed using Bicep 

https://github.com/aravindsundaram/AzureSiteRecovery/blob/main/Bicep/DeployLz.bicep

**Configuring Recovery Services Vault for ASR**

Under the hood, Recovery Services Vault needs quite a few child resources to enable ASR. 

- Replication Policies
  - Configuration that details the frequency of recovery snapshots and retention of those snapshots
- Replication Fabrics
  - Fabrics representing Source and Target Regions
- Replication Protection Containers
  - Logical containers underneath Fabric for Source and Target regions
- Replication Protection Containers Mappings
  - Associates the Protection Containers to every Replication Policy
- Replication Network and Network Mappings
  - Maps the Source and Target Networks 

Code sample to configure Recovery Services Vault for ASR is below. 

https://github.com/aravindsundaram/AzureSiteRecovery/blob/main/Bicep/ConfigureASR.bicep

A github Workflow to build Landing Zone and Configure ASR is available below. 

https://github.com/aravindsundaram/AzureSiteRecovery/blob/main/.github/workflows/ASR-LandingZones.yml

[![ASR-LandingZones](https://github.com/aravindsundaram/AzureSiteRecovery/actions/workflows/ASR-LandingZones.yml/badge.svg)](https://github.com/aravindsundaram/AzureSiteRecovery/actions/workflows/ASR-LandingZones.yml)
