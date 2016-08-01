<#

.SYNOPSIS
Queries the specified metascan server and retrieves operational statistics

.DESCRIPTION
Queries the specified metascan server and retrieves operational statistics

.EXAMPLE
Get-MetascanStatstics -Computername "671630-lteitg04" -checkperiod 1

.NOTES


#>
function Get-MetascanStatstics{
    param (
        [String]$Computername = $env:COMPUTERNAME,
        $port = 8008,
        $CheckPeriod=1,
        [switch]$https
        )

    $unknown = 3
    $critical = 2
    $warning = 1
    $ok = 0
    if ($https -eq $true){
      $http = "https"
    }
    Else {$http = "http"}
    #MetaScan Rest API
    $statusapi = "$http://" + $Computername + ":$port/metascan_rest/status"
    $scanhistoryapi = "$http://" + $Computername + ":$port/metascan_rest/stat/scanhistory/$CheckPeriod"
    $fileuploadapi = "$http://" + $Computername + ":$port/metascan_rest/stat/fileuploads/$CheckPeriod"
    $queueapi = "$http://" + $Computername + ":$port/metascan_rest/file/inqueue"

    #Query the rest interface
    $statusresult = invoke-restmethod $statusapi -method get -timeoutsec 5
    $scanhistoryresult = invoke-restmethod $scanhistoryapi -method get -timeoutsec 5
    $fileuploadresult = invoke-restmethod $fileuploadapi -method get -timeoutsec 5
    $queueresult = invoke-restmethod $queueapi -method get -timeoutsec 5



    if (!($statusresult)){
        $result = "Could not connect to rest api"
    }

    Else{
        #Calculate totals for check CheckPeriod
        $scanhistoryresult.total_scanned_files | %{$totalscan +=$_}
        $scanhistoryresult.total_infected | %{$totalinfect +=$_}
        $scanhistoryresult.avg_scan_time | %{$totalavgscan +=$_}
        if($totalavgscan -gt 0)
        {$totalavgscan = ($totalavgscan / ($scanhistoryresult.avg_scan_time | ? {$_ -ne 0}).count)}

        $result = New-Object psobject
        $result | Add-Member -MemberType NoteProperty -Name 'Metascan Server Running Since' -Value $statusresult.server_started
        $result | Add-Member -MemberType NoteProperty -Name 'Version' -Value $statusresult.metascan_ver
        $result | Add-Member -MemberType NoteProperty -Name "Files scanned" -Value $totalscan
        $result | Add-Member -MemberType NoteProperty -Name "Infected files" -Value $totalinfect
        $result | Add-Member -MemberType NoteProperty -Name "Average scan time" -Value $totalavgscan
        $result | Add-Member -MemberType NoteProperty -Name "Total number of items in queue" -Value $queueresult.in_queue
        }
return $result
}
