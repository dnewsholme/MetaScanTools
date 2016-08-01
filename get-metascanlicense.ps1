<#

.SYNOPSIS
Pulls the license information from the metascan api.

.PARAMETER Computername
Name of the metascan server

.PARAMETER Port
Port metascan is running on

.PARAMETER https
If the server is https enabled or not.

.EXAMPLE
Get-MetascanLicense -computername metascan.contoso.com -port 8008

.NOTES


#>

function Get-MetascanLicense {
    PARAM (
        $Computername,
        $port = 8008,
        [switch]$https
        )

    if ($https -eq $true){
        $httpmethod = "https"
    }
    Else {
        $httpmethod = "http"
    }
    $result = invoke-restmethod ('{0}://{1}:{2}/metascan_rest/admin/license' -f $httpmethod,$Computername,$port)

    return $result
}
