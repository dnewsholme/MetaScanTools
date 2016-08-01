<#

.SYNOPSIS
Scans a file and optionally will email report of infected files.

.DESCRIPTION


.PARAMETER File
Full Path to file to be scanned.

.PARAMETER MetascanServer
IP or hostname of the metascan server

.PARAMETER Port
Port of Metascan server

.EXAMPLE
Request-MetaScan -file C:\temp\file.txt -metascanserver 192.168.49.10

.EXAMPLE
Request-MetaScan -file C:\temp\file.txt -metascanserver 192.168.49.10

.NOTES
Daryl Bizsley 2015

#>

function Request-Metascan {
    Param(
        [Parameter(Mandatory=$True,Position=1)][string]$file,
        $MetaScanServer,
        $port,
        [switch]$https
        )

    if($https -eq $true){
      $http = "https"
    }
    else {$http = "http"}
    $filename = (get-item $file)
    $parms = @{
    "Method" = "Post"
    "uri" = ('{0}://{1}:{2}/metascan_rest/file' -f $http,$MetaScanServer,$port)
    }
    #Read file
    $filestream = New-Object System.IO.StreamReader -ArgumentList $filename.Fullname
    $file = $filestream.ReadtoEnd()
    $filestream.close()
    #Encode the file
    Add-Type -AssemblyName System.Web
    $encoded = [System.Web.HttpUtility]::UrlEncode($file)
    #Send file to be scanned.
    $request = Invoke-RestMethod @parms -Headers @{"filename" = ($($filename).Name)} -body $encoded
    #Retrieve Result
    $result = Invoke-RestMethod -Uri ('{0}://{1}:{2}/metascan_rest/file/{3}' -f $http,$MetaScanServer,$port,$request.data_id)
    while (($result.scan_results).progress_percentage -ne 100){
       $result = Invoke-RestMethod -Uri ('{0}://{1}:{2}/metascan_rest/file/{3}' -f $http,$MetaScanServer,$port,$request.data_id)
    }
            $scanresults = New-Object PSObject
            $scanresults | add-member -MemberType NoteProperty -Name FileName -Value ($result.file_info).display_name
            $scanresults | add-member -MemberType NoteProperty -Name FileSize -Value ($result.file_info).file_size
            $scanresults | add-member -MemberType NoteProperty -Name FileInfo -Value ($result.file_info).file_type_description
            $scanresults | add-member -MemberType NoteProperty -Name ScanResult -Value ($result.scan_results).scan_all_result_a
            $scanresults | add-member -MemberType NoteProperty -Name FileSource -Value ($result.source)

    return $scanresults
}
