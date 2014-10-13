$mailboxes = Get-Mailbox -ResultSize Unlimited | select PrimarySmtpAddress

$domains = @()

foreach ($mailbox in $mailboxes)
{
    $domain = $mailbox.PrimarySmtpAddress.Split("@")[1]

    $domains += $domain
}

$domains | Group-Object | Select name,count

