
# Azure SQL Managed Instance Deployment Scripts

This repository contains scripts to automate the deployment of Azure SQL Managed Instance using both Azure CLI and PowerShell.

## Prerequisites

- Azure subscription
- Azure CLI installed (for main.cmd)
- PowerShell Az module installed (for main.ps1)
- Sufficient permissions to create resources in Azure

## Scripts

### Azure CLI (main.cmd)
The batch script `main.cmd` creates an Azure SQL Managed Instance using Azure CLI commands. It handles:
- Resource group creation
- Virtual network and subnet configuration
- Network Security Group setup
- SQL Managed Instance deployment

### PowerShell (main.ps1)
The PowerShell script `main.ps1` creates an Azure SQL Managed Instance using Az PowerShell commands. It handles:
- Resource group creation
- Virtual network and subnet configuration
- Network Security Group setup
- SQL Managed Instance deployment

## Usage

### Using Azure CLI (main.cmd)

main.cmd while adding the subscription id, resource group name, location, and managed instance name.


### Using PowerShell (main.ps1)

.\main.ps1 while adding the subscription id, resource group name, location, and managed instance name.


## Notes

- Deployment can take several hours to complete
- Ensure your subscription has enough quota for SQL Managed Instance
- The virtual network requires specific subnet configuration
- NSG rules are configured according to SQL Managed Instance requirements

## Security Considerations

- Scripts create necessary security rules for SQL MI communication
- Ensure proper RBAC permissions are in place
- Review and modify security settings as per your requirements
