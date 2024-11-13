# Azure SQL Managed Instance Deployment Demo

This demo provides a step-by-step guide to deploy an **Azure SQL Managed Instance** using an Azure Bicep template. The deployment includes setting up a Virtual Network, Subnet with necessary delegations, Network Security Group (NSG), Route Table, and the Managed Instance itself.

## Key Components

- **Virtual Network (VNet)**: A network environment for the Managed Instance.
- **Subnet**: Configured with necessary delegations and associated with NSG and Route Table.
- **Network Security Group (NSG)**: Controls network traffic with rules specific to SQL Managed Instance.
- **Route Table**: Manages network routes within the VNet.
- **Azure SQL Managed Instance**: The primary managed database service for this demo.

## Deployment Steps

### 1. Prerequisites
Ensure you have:
- **Azure CLI** and **Bicep CLI** installed and updated.
- **Azure subscription** with sufficient permissions.

### 2. Review the Bicep Template
The `main.bicep` file includes parameters for customizations like VNet name, address prefixes, SQL Managed Instance configuration, and more. Modify these as needed.

### 3. Create a Resource Group
Create a resource group to hold the deployment:
```bash
az group create --name MyResourceGroup --location eastus2
```

### 4. Deploy the Template
Use Azure CLI to deploy the Bicep file. 

#### Deploy with Inline Parameters
```bash
az deployment group create \
  --resource-group MyResourceGroup \
  --template-file main.bicep \
  --parameters miAdminPassword='YourStrongPassword123!'
```

Or, Deploy with a Parameters File
Create a parameters.json file for secure password input:
Then, deploy with:

```bash
az deployment group create \
  --resource-group MyResourceGroup \
  --template-file main.bicep \
  --parameters @parameters.json
```



