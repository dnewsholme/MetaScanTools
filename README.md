# MetaScan-Tools
A group of Powershell cmdlets to send files to scanned with metascan and to get information about the installation.

## Request MetaScan
```powershell
Request-MetaScan -file C:\temp\file.txt -metascanserver 192.168.49.10 -email -mailserver someserver -senderaddress metascan@domain.com -recipientaddress alerts@domain.com
```

## Get Metascan Engines Information
```powershell
Get-MetascanEngies
```

## Get Metascan Statistics
```powershell
Get-MetascanStatstics -Computername "671630-lteitg04" -checkperiod 1
```
