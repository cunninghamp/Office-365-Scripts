$reportfound = @()
$reportnotfound = @()

$cloudmailboxes = Import-CSV .\migration.csv

foreach ($cloudmailbox in $cloudmailboxes)
{
    try {
        Get-Mailbox $cloudmailbox.PrimarySMTPAddress -ErrorAction STOP
        $reportfound += "$($cloudmailbox.PrimarySMTPAddress) was found"

    }
    catch
    {
        $reportnotfound += "$($cloudmailbox.PrimarySMTPAddress) was not found"
    }

    
}

$reportfound | Out-File found.txt

$reportnotfound | Out-File notfound.txt