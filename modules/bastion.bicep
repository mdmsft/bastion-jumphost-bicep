param resourceSuffix string
param subnetId string
param location string = resourceGroup().location
param scaleUnits int

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: 'pip-${resourceSuffix}-bas'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2021-03-01' = {
  name: 'bas-${resourceSuffix}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    scaleUnits: scaleUnits
    dnsName: resourceSuffix
    enableTunneling: true
    enableFileCopy: true
    disableCopyPaste: false
    enableIpConnect: true
    enableShareableLink: true
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          publicIPAddress: {
            id: publicIpAddress.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}
