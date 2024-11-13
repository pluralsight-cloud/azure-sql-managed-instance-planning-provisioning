@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the Virtual Network')
param vnetName string = 'myVNet'

@description('Address prefix for the Virtual Network')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Name of the Managed Instance Subnet')
param miSubnetName string = 'ManagedInstanceSubnet'

@description('Address prefix for the Managed Instance Subnet')
param miSubnetPrefix string = '10.0.0.0/26' // At least /26 for Managed Instance

@description('Name of the Network Security Group')
param nsgName string = 'myNSG'

@description('Name of the Route Table')
param routeTableName string = 'myRouteTable'

@description('Name of the Azure SQL Managed Instance')
param miName string = 'myManagedInstance'

@description('Administrator username for the Managed Instance')
param miAdminUsername string = 'sqladmin'

@secure()
@description('Administrator password for the Managed Instance')
param miAdminPassword string

@description('License type for the Managed Instance')
@allowed([
  'BasePrice'
  'LicenseIncluded'
])
param licenseType string = 'BasePrice'

@description('Number of vCores for the Managed Instance')
param vCores int = 8

@description('Storage size in GB for the Managed Instance')
param storageSizeInGB int = 32

// Create the Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

// Create the Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowOutboundForMI'
        properties: {
          priority: 1000
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '80'
            '443'
            '12000-13000'
            '1438'
            '1440-1450'
            '1500-1599'
            '4022'
            '11000-11999'
            '14000-14999'
            '20000-20099'
            '30000-30999'
            '3342'
            '5022'
          ]
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowInboundForMI'
        properties: {
          priority: 1100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3342'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Create the Route Table
resource routeTable 'Microsoft.Network/routeTables@2024-03-01' = {
  name: routeTableName
  location: location
}

// Create the Managed Instance Subnet
resource miSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' = {
  parent: vnet
  name: miSubnetName
  properties: {
    addressPrefix: miSubnetPrefix
    networkSecurityGroup: {
      id: nsg.id
    }
    routeTable: {
      id: routeTable.id
    }
    delegations: [
      {
        name: 'sqlManagedInstanceDelegation'
        properties: {
          serviceName: 'Microsoft.Sql/managedInstances'
        }
      }
    ]
  }
}

// Create the Azure SQL Managed Instance
resource sqlMI 'Microsoft.Sql/managedInstances@2023-05-01-preview' = {
  name: miName
  location: location
  properties: {
    administratorLogin: miAdminUsername
    administratorLoginPassword: miAdminPassword
    subnetId: miSubnet.id
    licenseType: licenseType
    vCores: vCores
    storageSizeInGB: storageSizeInGB
    requestedBackupStorageRedundancy: 'Local'
    publicDataEndpointEnabled: false
    zoneRedundant: false
    collation: 'SQL_Latin1_General_CP1_CI_AS'  // Database collation
    minimalTlsVersion: '1.2'  // TLS version
    proxyOverride: 'Redirect'  // Network connectivity option
    timezoneId: 'UTC'  // Time zone
  }
}

// Output the Managed Instance FQDN
output miFQDN string = sqlMI.properties.fullyQualifiedDomainName
