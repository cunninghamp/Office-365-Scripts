Function Connect-EXOnline {

    $URL = "https://ps.outlook.com/powershell"
    
    $Credentials = Get-Credential -Message "Enter your Office 365 admin credentials"

    $EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $URL -Credential $Credentials -Authentication Basic -AllowRedirection -Name "Office 365"

    Import-PSSession $EXOSession

}

Function Disconnect-EXOnline {
    
    Remove-PSSession -Name "Exchange Online"

}