Get-all-Parallel.PS1

----
#$filename = (Get-Date).tostring("dd-MM-yyyy-hh-mm")
Set-Location C:\Shared

# Exclude the work group machine due to PS cannot access to that machine.
#$excludemachine = @('ABC', 'XYZ')

# Query all Windows 10, Windows 11 machines on Active Directory
$computers = (Get-ADComputer -properties OperatingSystem -filter {(operatingsystem -like "*Windows 10*" -or operatingsystem -like "*Windows 11*")}).name | where { ($_ -notlike 'ABC') -and ($_ -notlike 'YYY') -and ($_ -notlike 'XYZ')}
#$computers = Get-Content C:\Shared\TESTMACHINE.txt

$computers | foreach-object -parallel {
    $computer = $_
    $ping_result = Test-Connection -ComputerName $_ -Count 1 -Quiet
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
    # outputing to csv file
    $filename = (Get-Date).tostring("dd-MM-yyyy-hh-mm")
    $winrm_obj | export-csv -NoTypeInformation -append "C:\Shared\Daily-PS-Logs\$filename.csv"
    #$outputbox.text = ($winrm_obj | format-list | out-string).TrimStart()
    }
    #($winrm_obj | format-table | out-string).TrimStart() 
}

---
PS C:\Shared\Backup> Measure-Command {.\get-all-parallel.PS1}

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 38
Milliseconds      : 245
Ticks             : 382451068
TotalDays         : 0.000442651699074074
TotalHours        : 0.0106236407777778
TotalMinutes      : 0.637418446666667
TotalSeconds      : 38.2451068
TotalMilliseconds : 38245.1068

---
With 
    #($winrm_obj | format-table | out-string).TrimStart() 
} -ThrottleLimit 10

PS C:\Shared\Backup> Measure-Command {.\get-all-parallel.PS1}

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 24
Milliseconds      : 773
Ticks             : 247730611
TotalDays         : 0.000286725244212963
TotalHours        : 0.00688140586111111
TotalMinutes      : 0.412884351666667
TotalSeconds      : 24.7730611
TotalMilliseconds : 24773.0611

---
-ThrottleLimit 20
PS C:\Shared\Backup> Measure-Command {.\get-all-parallel.PS1}

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 9
Milliseconds      : 555
Ticks             : 95550571
TotalDays         : 0.000110590938657407
TotalHours        : 0.00265418252777778
TotalMinutes      : 0.159250951666667
TotalSeconds      : 9.5550571
TotalMilliseconds : 9555.0571
