# Query-all and save in the console, not CSV files. 

# This script is written by Tung on 2021-11-12.
# Modifiled at 04/10/2022 for getting Last Reboot via Event ID 1074
# Updated on 2022-08-26 with Windows 11
# Get-date to get information about the date to run the script
$filename = (Get-Date).tostring("dd-MM-yyyy-hh-mm")

# Change PowerShell working directory to C:\Shared 
Set-Location C:\Shared

# Exclude the work group machine due to PS cannot access to that machine.
#$excludemachine = @('ABC', 'XYZ')

# Query all Windows 10, Windows 11 machines on Active Directory
#$computers = (Get-ADComputer -properties OperatingSystem -filter {(operatingsystem -like "*Windows 10*" -or operatingsystem -like "*Windows 11*")}).name | where { ($_ -notlike 'ABC') -and ($_ -notlike 'XYZ')}
$computers = Get-Content C:\Shared\tungmachine.txt

$results = @()

foreach ($computer in $computers) {
    $ping_result = Test-Connection -ComputerName $computer -Count 1 -Quiet
    if ($ping_result) {
        # Creating PowerShell Remoting session to use invoke-command later. Using this to run multiple commands into invoke-command session. 
        # https://stackoverflow.com/questions/58134110/how-to-use-multiple-commands-into-invoke-command-with-multiple-outputs
        $WinRM_session = New-PSSession -ComputerName $computer
        # Creating an ordered hashtable
        $myobject = [ordered]@{Computername = $computer }
        if ($WinRM_session) {       
            # Querying Windows OS build
            $CurrentBuild_Code = Invoke-Command -Session $WinRM_session -ScriptBlock { (Get-ItemProperty -PATH 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion') } -ErrorAction SilentlyContinue
            Try {
                $DisplayVersion = $CurrentBuild_Code.DisplayVersion
            }
            Catch {
                $DisplayVersion = $null
            }
            if ($null -ne $DisplayVersion) {
                $myobject.add('Windows OS Build', $DisplayVersion + "." + $CurrentBuild_Code.CurrentBuild + "." + $CurrentBuild_Code.UBR)
            }
            else {
                $myobject.add('Windows OS Build', $CurrentBuild_Code.CurrentBuild + "." + $CurrentBuild_Code.UBR)
            }

            # Querying Symantec
            $Symantec_Code = Invoke-Command -Session $WinRM_session -ScriptBlock { (Get-ItemProperty -PATH 'HKLM:\SOFTWARE\Symantec\Symantec Endpoint Protection\CurrentVersion\Public-Opstate') } -ErrorAction SilentlyContinue
            $Symantec_Update = [string]($Symantec_Code.LatestVirusDefsDate) + " " + "r" + [string]($Symantec_Code.LatestVirusDefsRevision)
            $myobject.add('Symantec_DefsDate', $Symantec_Update)

            # Querying LastReboot
            $LastReboot_code = Invoke-Command -Session $WinRM_session -ScriptBlock { Get-WinEvent -filterhash @{Logname = 'system'; ID = 1074 } -MaxEvents 1 | `
                        Select-Object @{Name = "Computername"; Expression = { $_.properties[1].value } }, `
                        @{Name = "UserName"; Expression = { ($_.properties[-1]).value } }, @{ expression = { $_.TimeCreated }; label = 'Last Reboot' }, `
                    @{Name = "Category"; Expression = { $_.properties[4].value } } } -ErrorAction SilentlyContinue
            $myobject.add('LastReboot', $LastReboot_code.'Last Reboot')
            $myobject.add('UserName', $LastReboot_code.'Username')
            $myobject.add('Category', $LastReboot_code.'Category')
        }

    # Tearing down PowerShell Remoting connection
    $WinRM_session | Remove-PSSession
    # Creating a PSCustomObject
    $winrm_obj = New-Object -TypeName psobject -Property $myobject
    $results += $winrm_obj  
    # outputing to csv file
    #$winrm_obj | export-csv -NoTypeInformation -append "C:\Shared\Daily-PS-Logs\$filename.csv"
    }
}
$results | format-table

---
PS C:\Shared> C:\Shared\PS Scripts\Query-all2.PS1

Computername Windows OS Build Symantec_DefsDate LastReboot             UserName       Category
------------ ---------------- ----------------- ----------             --------       --------
ABC         22H2.19045.2364     2022-01-05 r23   12/16/2021 4:16:21 PM  cisa\abc    restart 
XYZ         22H2.19045.2364     2022-01-05 r23   12/15/2021 10:54:53 AM cisa\xyz    restart 
