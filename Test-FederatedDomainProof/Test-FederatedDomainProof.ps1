<#
.SYNOPSIS
Test-FederatedDomainProof.ps1 - Test the federated domain proof TXT record exists in DNS.

.DESCRIPTION 
This PowerShell script checks DNS for the TXT record containing the federated domain
proof string that must be created when setting up a Hybrid Exchange/Office 365 configuration.
The script must be run from within the Exchange organization that you are testing. In other
words, you can't test Org A's federated domain proof record from Org B.

.OUTPUTS
Results are output to the console.

.PARAMETER Domain
The domain name to check.

.EXAMPLE
.\Test-FederatedDomainProof.ps1 -Domain exchangeserverpro.net

.NOTES
Written by: Paul Cunningham

Find me on:

* My Blog:	https://paulcunningham.me
* Twitter:	https://twitter.com/paulcunningham
* LinkedIn:	https://au.linkedin.com/in/cunninghamp/
* Github:	https://github.com/cunninghamp

Change Log
V1.00, 10/08/2015 - Initial version
#>

#requires -version 2

param (
    [Parameter(Mandatory=$true)]
    [string]$Domain
)


#...................................
# Script
#...................................


#Add Exchange 2010 snapin if not already loaded in the PowerShell session
if (Test-Path $env:ExchangeInstallPath\bin\RemoteExchange.ps1)
{
	. $env:ExchangeInstallPath\bin\RemoteExchange.ps1
	Connect-ExchangeServer -auto -AllowClobber
}
else
{
    Write-Warning "Exchange Server management tools are not installed on this computer."
    EXIT
}

Write-Host "Get federated domain proof for domain $domain"

$proof = (Get-FederatedDomainProof -DomainName $domain).Proof

Write-Host "Proof: $proof"

Write-Host "Lookup TXT records for domain $domain"
try {

    $txts = @(Resolve-DnsName -Name $domain -Type TXT -Server 8.8.8.8 -ErrorAction STOP).Strings

    Write-Host "TXT records:"
    $txts
}
catch
{
    Write-Warning $_.Exception.Message
    EXIT
}

Write-Host "Compare proof to TXT records"

if ($txts -contains $proof)
{
    Write-Host -ForegroundColor Green "Proof found in TXT records."
}
else
{
    Write-Host -ForegroundColor Red "Proof not found in TXT records."
}


#...................................
# Finished
#...................................
