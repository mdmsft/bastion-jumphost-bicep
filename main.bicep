param project string = 'contoso'
param product string = 'ams'
param location string = resourceGroup().location
param region string = 'weu'
param environment string = 'dev'
param deploymentName string = '${deployment().name}-${uniqueString(utcNow())}'

param networkAddressPrefix string = '192.168.254.0/23'
param deployBastion bool = false
param bastionScaleUnits int = 2
param workspaceDailyQuotaGb int = 1
param workspaceRetentionInDays int = 30
param sshKeyData string
param jumphostVmSize string = 'Standard_D2d_v5'
param jumphostImagePublisher string = 'Canonical'
param jumphostImageOffer string = '0001-com-ubuntu-server-focal'
param jumphostImageSku string = '20_04-lts-gen2'
param jumphostImageVersion string = 'latest'
param jumphostDiskSizeGB int = 64

var resourceSuffix = '${project}-${environment}-${region}'

module workspace 'modules/workspace.bicep' = {
  name: '${deploymentName}-workspace'
  params: {
    location: location
    dailyQuotaGb: workspaceDailyQuotaGb
    resourceSuffix: resourceSuffix
    retentionInDays: workspaceRetentionInDays
  }
}

module network 'modules/network.bicep' = {
  name: '${deploymentName}-network'
  params: {
    location: location
    addressPrefix: networkAddressPrefix
    resourceSuffix: resourceSuffix
  }
}

module bastion 'modules/bastion.bicep' = if (deployBastion) {
  name: '${deploymentName}-bastion'
  params: {
    location: location
    subnetId: network.outputs.bastionSubnetId
    scaleUnits: bastionScaleUnits
    resourceSuffix: resourceSuffix
  }
}

module jumphost 'modules/jumphost.bicep' = {
  name: '${deploymentName}-jumphost'
  params: {
    location: location
    product: product
    adminUsername: 'azure'
    diskSizeGB: jumphostDiskSizeGB
    imageOffer: jumphostImageOffer
    imagePublisher: jumphostImagePublisher
    imageSku:  jumphostImageSku
    imageVersion: jumphostImageVersion
    sshKeyData: sshKeyData
    resourceSuffix: resourceSuffix
    subnetId: network.outputs.defaultSubnetId
    vmSize: jumphostVmSize
  }
}
