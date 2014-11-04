<#
.SYNOPSIS
CompareCloudToOnPremises.ps1
#>

#requires -version 2

[CmdletBinding()]
param (

	[Parameter( Mandatory=$false)]
	[string]$ADWSserver

)


#...................................
# Variables
#...................................

$scriptname = "CompareCloudToOnPremises.ps1"
$now = Get-Date

$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$logfile = "$myDir\$scriptname.log"

$report = @()

#...................................
# Logfile Strings
#...................................

$logstring0 = "====================================="
$logstring1 = " $scriptname"


#...................................
# Initialization Strings
#...................................

$initstring0 = "Initializing..."


#...................................
# Functions
#...................................


# This function will prompt for authentication and connect to Exchange Online 
Function Connect-EXOnline {

    $URL = "https://ps.outlook.com/powershell"
    
    $Credentials = Get-Credential

    $EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $URL -Credential $Credentials -Authentication Basic -AllowRedirection -Name "Exchange Online"

    Import-PSSession $EXOSession -Prefix EXO

}

#This function will disconnect the PS Session "Exchange Online". This may
#leave other PS Sessions open to EXO if others have been created.
Function Disconnect-EXOnline {
    
    Remove-PSSession -Name "Exchange Online"

}


#...................................
# Initialize
#...................................

try {
    Import-Module ActiveDirectory -ErrorAction STOP
}
catch {
    Write-Warning $_.Exception.Message
    EXIT
}


#...................................
# Script
#...................................

Write-Host "Connecting to Exchange Online..."

Connect-EXOnline

Write-Host "Retrieving mailbox list from Exchange Online"
$cloudusers = Get-EXOUser

Write-Host "Retrieving user accounts list from Active Directory"

if ($ADWSserver)
{
    $onpremusers = Get-ADUser -Filter * -Properties * -Server $ADWSserver
}
else
{
    $onpremusers = Get-ADUser -Filter * -Properties *
}

foreach ($clouduser in $cloudusers)
{

    Write-Host "Processing: $clouduser"
    $reportObj = New-Object PSObject
    $reportObj | Add-Member NoteProperty -Name "Name" -Value $clouduser.Name
    $reportObj | Add-Member NoteProperty -Name "UPN" -Value $clouduser.UserPrincipalName
    $reportObj | Add-Member NoteProperty -Name "Email Address" -Value $clouduser.WindowsEmailAddress


    $onpremuser = $null

    $onpremuser = $onpremusers | Where {$_.UserPrincipalName -eq $clouduser.UserPrincipalName}

    if ($onpremuser)
    {
        $reportObj | Add-Member NoteProperty -Name "On-Prem Name" -Value $onpremuser.Name
        $reportObj | Add-Member NoteProperty -Name "On_Prem UPN" -Value $onpremuser.UserPrincipalName
        $reportObj | Add-Member NoteProperty -Name "SamAccountName" -Value $onpremuser.SamAccountName
        $reportObj | Add-Member NoteProperty -Name "On-Prem Email Address" -Value $onpremuser.EmailAddress
        $reportObj | Add-Member NoteProperty -Name "Target Address" -Value $onpremuser.targetAddress
    }
    else
    {
        $reportObj | Add-Member NoteProperty -Name "On-Prem Name" -Value "No match"
        $reportObj | Add-Member NoteProperty -Name "On_Prem UPN" -Value "No match"
        $reportObj | Add-Member NoteProperty -Name "SamAccountName" -Value "No match"
        $reportObj | Add-Member NoteProperty -Name "On-Prem Email Address" -Value "No match"
        $reportObj | Add-Member NoteProperty -Name "Target Address" -Value "No match"
    }

    $report +=$reportObj

}

Write-Host "Disconnecting from Exchange Online"
Disconnect-EXOnline

Write-Host "Writing report to CSV file"
$report | Export-CSV -NoTypeInformation CompareCloudToOnPremises-Report.csv

#...................................
# End
#...................................

Write-Host "Finished."

