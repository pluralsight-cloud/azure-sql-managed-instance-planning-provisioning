:: Step 1: Log in to Azure
az login

:: Set the default subscription (replace with your subscription ID or name if necessary)
az account set --subscription "Your_Subscription_ID_or_Name"

:: Step 2: Create a Resource Group
az group create --name MyResourceGroup --location eastus

:: Step 3: Create a Virtual Network
az network vnet create \
  --name MyVNet \
  --resource-group MyResourceGroup \
  --location eastus \
  --address-prefixes 10.0.0.0/16

:: Step 4: Create a Subnet with Delegation
az network vnet subnet create \
  --name ManagedInstanceSubnet \
  --resource-group MyResourceGroup \
  --vnet-name MyVNet \
  --address-prefixes 10.0.0.0/26 \
  --delegations Microsoft.Sql/managedInstances

:: Step 5: Create a Network Security Group (NSG)
az network nsg create \
  --resource-group MyResourceGroup \
  --name MyNSG

:: Step 6: Create NSG Rules to Allow Required Traffic
:: Allow Outbound Traffic for Azure SQL Managed Instance
az network nsg rule create \
  --resource-group MyResourceGroup \
  --nsg-name MyNSG \
  --name AllowOutboundForMI \
  --priority 1000 \
  --direction Outbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 80 443 12000-13000 1438 1440-1450 1500-1599 4022 11000-11999 14000-14999 20000-20099 30000-30999 3342 5022

:: Allow Inbound Traffic (if using public endpoint)
az network nsg rule create \
  --resource-group MyResourceGroup \
  --nsg-name MyNSG \
  --name AllowInboundForMI \
  --priority 1100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 3342

:: Step 7: Create a Route Table
az network route-table create \
  --resource-group MyResourceGroup \
  --name MyRouteTable

:: Step 8: Associate the NSG and Route Table with the Subnet
:: Associate the NSG
az network vnet subnet update \
  --resource-group MyResourceGroup \
  --vnet-name MyVNet \
  --name ManagedInstanceSubnet \
  --network-security-group MyNSG

:: Associate the Route Table
az network vnet subnet update \
  --resource-group MyResourceGroup \
  --vnet-name MyVNet \
  --name ManagedInstanceSubnet \
  --route-table MyRouteTable

:: Step 9: Obtain the Subnet ID
FOR /F "usebackq tokens=*" %i IN (`az network vnet subnet show --resource-group MyResourceGroup --vnet-name MyVNet --name ManagedInstanceSubnet --query id -o tsv`) DO SET SUBNET_ID=%i
echo %SUBNET_ID%

:: Step 10: Create the Azure SQL Managed Instance
az sql mi create \
  --name MyManagedInstance \
  --resource-group MyResourceGroup \
  --location eastus \
  --admin-user sqladmin \
  --admin-password MyStrongPassword123! \
  --subnet "%SUBNET_ID%" \
  --license-type BasePrice \
  --capacity 8 \
  --storage 32GB \
  --edition GeneralPurpose \
  --family Gen5

:: Step 11: Monitor the Deployment
az sql mi show \
  --name MyManagedInstance \
  --resource-group MyResourceGroup \
  --query "{Name:name, State:state}" \
  --output table

:: Step 15: Retrieve the Managed Instance FQDN
az sql mi show \
  --name MyManagedInstance \
  --resource-group MyResourceGroup \
  --query fullyQualifiedDomainName \
  --output tsv

:: Optional: Clean up resources
:: If you no longer need the resources, uncomment the line below to delete the resource group
:: az group delete --name MyResourceGroup --yes --no-wait
