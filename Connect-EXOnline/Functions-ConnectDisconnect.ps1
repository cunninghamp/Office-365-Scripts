<#
These functions can be added to your PowerShell profile to allow you to
quickly and easily connect to Exchange Online (Office 365).

For more info on how they are used see:
http://exchangeserverpro.com/powershell-function-connect-office-365/
http://exchangeserverpro.com/create-powershell-profile

Written by: Paul Cunningham

Find me on:

* My Blog:	https://paulcunningham.me
* Twitter:	https://twitter.com/paulcunningham
* LinkedIn:	https://au.linkedin.com/in/cunninghamp/
* Github:	https://github.com/cunninghamp

Change Log:
V1.00, 14/10/2014 - Initial version
V1.01, 22/05/2016 - Updated with new PowerShell endpoint URL
V1.02, 27/09/2016 - Connect-EXOnline updated with new functionality for using stored credentials
#>

Function Connect-EXOnline {

    <#
    .SYNOPSIS
    Connect-EXOnline.ps1 - Connect to Exchange Online

    .DESCRIPTION 
    This function will connect to Exchange Online using PowerShell.

    .PARAMETER UseCredential
    Uses a stored credential on the computer for authenticating with
    Exchange Online. For more information on using stored credentials
    refer to

    .PARAMETER Prefix
    Prefixes the Exchange Online cmdlets with the value that you specify
    (such as "Cloud")so that they can be used alongside the on-premises
    Exchange cmdlets of the same name.

    .EXAMPLE
    Connect-EXOnline
    Prompts for authentication and connects to Exchange Online.

    .EXAMPLE
    Connect-EXOnline -UseCredential admin@tenant.onmicrosoft.com
    Uses the stored credential for admin@tenant.onmicrosoft.com to connect
    to Exchange Online.

    .EXAMPLE
    Connect-EXOnline -UseCredential admin@tenant.onmicrosoft.com -Prefix EXO
    Uses the stored credential for admin@tenant.onmicrosoft.com to connect
    to Exchange Online, and prefixes the cmdlets with "EXO", for example
    Get-EXOMailbox instead of Get-Mailbox.

    .NOTES
    Written by: Paul Cunningham

    Find me on:

    * My Blog:	http://paulcunningham.me
    * Twitter:	https://twitter.com/paulcunningham
    * LinkedIn:	http://au.linkedin.com/in/cunninghamp/
    * Github:	https://github.com/cunninghamp

    For more Office 365 tips, tricks and news
    check out Practical 365.

    * Website:	https://practical365.com
    * Twitter:	https://twitter.com/practical365
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string]$UseCredential,

        [Parameter(Mandatory=$false)]
        [string]$Prefix
        )

    $URL = "https://outlook.office365.com/powershell-liveid/"
    
    if ($UseCredential) {
        $Credentials = Get-StoredCredential -UserName $UseCredential
    }
    else {
        $Credentials = Get-Credential -Message "Enter your Office 365 admin credentials"
    }

    $EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $URL -Credential $Credentials -Authentication Basic -AllowRedirection -Name "Exchange Online"

    if ($Prefix) {
        Import-PSSession $EXOSession -Prefix $Prefix
    }
    else {
        Import-PSSession $EXOSession
    }
}

#This function will disconnect the PS Session "Exchange Online". This may
#leave other PS Sessions open to EXO if others have been created.
Function Disconnect-EXOnline {
    
    Remove-PSSession -Name "Exchange Online"

}
