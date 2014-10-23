$cloudmailboxes = Import-CSV .\migration.csv

foreach ($cloudmailbox in $cloudmailboxes)
{
    try {
        Get-Mailbox $cloudmailbox -ErrorAction STOP
        $mailboxstatus = "Found"

    }
    catch
    {
        $mailboxstatus = "Not found"
    }

    Write-Host "$cloudmailbox was $mailboxstatus"
}