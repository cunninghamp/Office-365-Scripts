#Get-ImmutableID.ps1
#Written By: Paul Cunningham
#
#Change Log
#V1.0, 9/1/2015 - Initial version
#
#.SYNOPSIS 
#Calculates the immutable ID of an on-premises Active Directory user object.
#
#.EXAMPLE
#.\Get-ImmutableID.ps1 user1@domain.com
#

#...................................
# Static Variables
#...................................



#...................................
# Functions
#...................................



#...................................
# Script
#...................................

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$UserName
)

try
{
    Import-Module ActiveDirectory -ErrorAction STOP
    $user = Get-ADUser $UserName -ErrorAction STOP
    $guid = [GUID]($user).ObjectGUID
    $bytearray = $guid.ToByteArray()

    $immutableID = [system.convert]::ToBase64String($bytearray)

    Write-Host "User: $UserName"
    Write-Host "ImmutableID: $immutableID"

}
catch
{
    Write-Warning $_.Exception.Message
    EXIT
}

