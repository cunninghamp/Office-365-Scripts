<#
These functions can be added to your PowerShell profile to allow you to
quickly and easily connect to the Office 365 Compliance Center.

For more info on how they are used see:
http://exchangeserverpro.com/powershell-function-connect-office-365-compliance-center/
http://exchangeserverpro.com/create-powershell-profile


Written by: Paul Cunningham

Find me on:

* My Blog:	http://paulcunningham.me
* Twitter:	https://twitter.com/paulcunningham
* LinkedIn:	http://au.linkedin.com/in/cunninghamp/
* Github:	https://github.com/cunninghamp

For more Exchange Server tips, tricks and news
check out Exchange Server Pro.

* Website:	http://exchangeserverpro.com
* Twitter:	http://twitter.com/exchservpro

Change Log:
V1.00, 8/7/2014 - Initial version
#>

# This function will prompt for authentication and connect to the Office 365 Compliance Center 
Function Connect-ComplianceCenter {

    $URL = "https://ps.compliance.protection.outlook.com/powershell-liveid/"
    
    $Credentials = Get-Credential -Message "Enter your Office 365 admin credentials"

    $EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $URL -Credential $Credentials -Authentication Basic -AllowRedirection -Name "Compliance Center"

    Import-PSSession $EXOSession

}

#This function will disconnect the PS Session "Compliance Center". This may
#leave other PS Sessions open to Office 365 if others have been created.
Function Disconnect-ComplianceCenter {
    
    Remove-PSSession -Name "Compliance"

}