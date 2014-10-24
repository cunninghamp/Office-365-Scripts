<#
.SYNOPSIS
CompareOnPremisesToCloud.ps1
#>

#requires -version 2

[CmdletBinding()]
param ()


#...................................
# Variables
#...................................

$scriptname = $MyInvocation.MyCommand.Name
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
$initstring1 = "Loading the Exchange Server PowerShell snapin"
$initstring2 = "The Exchange Server PowerShell snapin did not load."
$initstring3 = "Setting scope to entire forest"


#...................................
# Functions
#...................................


# This function will prompt for authentication and connect to Exchange Online 
Function Connect-EXOnline {

    $URL = "https://ps.outlook.com/powershell"
    
    $Credentials = Get-Credential -Message "Enter your Office 365 admin credentials"

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

Import-Module ActiveDirectory

#...................................
# Script
#...................................


Connect-EXOnline

$cloudmailboxes = Get-EXOMailbox

$onpremusers = Get-ADUser -Filter * -Properties *

foreach ($onpremuser in $onpremusers)
{

    $reportObj = New-Object PSObject
    $reportObj | Add-Member NoteProperty -Name "Name" -Value $onpremuser.Name
    $reportObj | Add-Member NoteProperty -Name "SamAccountName" -Value $onpremuser.SamAccountName
    $reportObj | Add-Member NoteProperty -Name "UPN" -Value $onpremuser.UserPrincipalName
    $reportObj | Add-Member NoteProperty -Name "Email Address" -Value $onpremuser.EmailAddress
    $reportObj | Add-Member NoteProperty -Name "Target Address" -Value $onpremuser.targetAddress

    $cloudmailbox = $null

    $cloudmailbox = $cloudmailboxes | Where {$_.Name -eq $onpremuser.Name}

    if ($cloudmailbox)
    {
        $reportObj | Add-Member NoteProperty -Name "Cloud Name" -Value $cloudmailbox.Name
        $reportObj | Add-Member NoteProperty -Name "Cloud Email Address" -Value $cloudmailbox.PrimarySMTPAddress
    }
    else
    {
        $reportObj | Add-Member NoteProperty -Name "Cloud Name" -Value "Not matched"
        $reportObj | Add-Member NoteProperty -Name "Cloud Email Address" -Value "Not matched"
    }

    $report +=$reportObj

}





Disconnect-EXOnline

$report | Export-CSV -NoTypeInformation report.csv

#...................................
# End
#...................................



