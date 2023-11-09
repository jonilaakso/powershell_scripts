# Set Static IP for network adapter

# Disable IPV6:
Write-Host "Disabling IPv6 from adapters"
Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6

#Get adapter ifIndex number:
Get-NetAdapter

# Get the ip address of that adapter:
# Get-NetIPAddress -InterfaceIndex <number>

#Set IP to adapter

Write-Host ""
Write-Host ""
$adapterIndex = Read-Host -Prompt "Please enter the ifIndex number of the adapter you want to change"
$newStaticIP = Read-Host -Prompt "Insert new desired IP-address"
$newDefGateway = Read-Host -Prompt "Insert new Default Gateway"

$continue = Read-Host -Prompt "Continue with IP:$newStaticIP and Gateway: $newDefGateway ? (y/n)"

while ($continue -eq 'n') {
    $newStaticIP = Read-Host -Prompt "Insert new desired IP-address"
    $newDefGateway = Read-Host -Prompt "Insert new Default Gateway"
    $continue = Read-Host -Prompt "Continue with IP:$newStaticIP and Gateway: $newDefGateway ? (y/n)"
 }


Write-Host "Changing ip to $newStaticIP and Gateway to $newDefGateway"

#Change static IP & Gateway & DNS
#Try to set new ip
try {

    New-NetIPAddress -InterfaceIndex $adapterIndex -IPAddress $newStaticIP -DefaultGateway $newDefGateway -PrefixLength 8
    Set-DnsClientServerAddress -InterfaceIndex $adapterIndex -ServerAddresses $newDefGateway,8.8.8.8
}

catch {
#Remove old IP-address and gateway
    Remove-NetIPAddress -InterfaceIndex $adapterIndex -Confirm:$false
    Remove-NetRoute -InterfaceIndex $adapterIndex -Confirm:$false

    New-NetIPAddress -InterfaceIndex $adapterIndex -IPAddress $newStaticIP -DefaultGateway $newDefGateway -PrefixLength 8
    Set-DnsClientServerAddress -InterfaceIndex $adapterIndex -ServerAddresses $newDefGateway,8.8.8.8
    }


#Disable net-adapter and enable it 
Disable-NetAdapter Ethernet -Confirm:$false
Enable-NetAdapter Ethernet