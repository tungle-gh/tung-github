# This script is written by Tung on 2021-10-27.
# Modifiled at 04/10/2022 for getting Last Reboot via Event ID 1074
# Get-date to get information about the date to run the script
$filename = (Get-Date).tostring("dd-MM-yyyy-hh-mm")

# Change PowerShell working directory to C:\Shared 
Set-Location C:\Shared

# Exclude the work group machine due to PS cannot access to that machine.
$excludemachine = "ABC"

# Query all Windows 10, Windows 11 machines on Active Directory
$computers_win_10_11 = (Get-ADComputer -properties OperatingSystem -filter {(operatingsystem -like "*Windows 10*" -or operatingsystem -like "*Windows 11*")}).name | where { ($_ -notlike $excludemachine)}
<#  
    .Description
    This script is used to query Windows updates OS current patch via PS.
    Using Remote PowerShell to run invoke-command for all computers
    $computers_win_10_11 = (Get-ADComputer -properties OperatingSystem -filter {(operatingsystem -like "*Windows 10*" -or operatingsystem -like "*Windows 11*")}).name to retrieve all Windows 10 machine
    # Check the computer is online or NOT
    # If the machine is online, then run the invoke-command to check Windwos Current Patch version. It runs the script Get-CurrentPatchInfo.ps1 under C:\Shared. 
    # Sort OSbuild object 
    After finishing on running the script, it will output a $filename.csv report file under C:\Shared\PSWindowsUpdatesLog directory.
    Below is information that script need to get about WIndows current build.
    # Win10
    $CurrentBuild = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' –Name CurrentBuild).CurrentBuild
    $UBR = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' –Name UBR).UBR
    $OSVersion = $CurrentBuild + "." + $UBR
    # Then Export the result to csv file
    export-csv -NoTypeInformation -append to remove CSV header.
#>


foreach($computer in $computers_win_10_11){
    $ping_result = Test-Connection -ComputerName $computer -Count 1 -Quiet
        if($ping_result){
            Invoke-Command -ComputerName $computer -FilePath "C:\Shared\Get-WindowsVersion.ps1" |
            Select-Object -Property PSComputerName, "OS Build"|
            export-csv -NoTypeInformation -append "C:\Shared\PSWindowsUpdatesLog\$filename.csv"
        }
}

<#  
    .Description 
    This script is used to query the latest Symantec Definition Virus Updates via PS  
    Then it will run the script Get-Symantec.ps1 under C:\Shared. 
    After finishing on running the script, it will output the result to $filename.csv file under C:\Shared\SymantecLog directory.
    Get-ItemProperty -Path 'HKLM:\SOFTWARE\Symantec\Symantec Endpoint Protection\CurrentVersion\Public-Opstate' -Name LatestVirusDefsDate is a Symantec's virus definition vvalue
#>

foreach($computer in $computers_win_10_11){
    $ping_result = Test-Connection -ComputerName $computer -Count 1 -Quiet
    if($ping_result){
        Invoke-Command –ComputerName $computer { Get-ItemProperty -Path 'HKLM:\SOFTWARE\Symantec\Symantec Endpoint Protection\CurrentVersion\Public-Opstate' -Name LatestVirusDefsDate }| 
        Select-Object PSComputerName, LatestVirusDefsDate | 
        export-csv -NoTypeInformation -append "C:\Shared\SymantecLog\$filename.csv" 
}
}


# Query Last Reboot value via Event ID 1074 on 2022-10-04
<#
PS C:\Shared> $eventtest = Get-WinEvent -filterhash @{Logname = 'system';ID=1074} -MaxEvents 1
PS C:\Shared> $eventtest.Properties
Value                                         
-----                                         
C:\Windows\System32\RuntimeBroker.exe (computer1)
computer1                                      
Hardware: Installation (Planned)              
0x84010002                                    
power off                                     
                                              
xyz\admin  
----- 
+Query computer name
PS C:\Shared> $eventtest.Properties[1].value
computer1
+Query user who is doing an action for the event ID 1074
PS C:\Shared> $eventtest.Properties[-1].value
xyz\admin
+ Quey the action of the Event ID 1074
PS C:\Shared> $eventtest.Properties[4].value
power off
+ Query Time created of the event
PS C:\Shared> $eventtest.TimeCreated
Wednesday, September 28, 2022 4:43:37 PM

# Select-onject: Computername, Username, TimeCreated and Category
# @{ expression={$_.TimeCreated}; label='Last Reboot' }: Change TimeCreated column to 'Last Reboot'
#> 

foreach($computer in $computers_win_10_11){
    $ping_result = Test-Connection -ComputerName $computer -Count 1 -Quiet
    if($ping_result){
        Invoke-Command –ComputerName $computer {Get-WinEvent -filterhash @{Logname = 'system';ID=1074} -MaxEvents 1 | `
            Select-Object @{Name="Computername";Expression = {$_.properties[1].value}}, `
            @{Name="UserName";Expression = { ($_.properties[-1]).value}}, TimeCreated, ` 
            #@{Name="LastReboot";Expression = TimeCreated},`
            #TimeCreated.tostring("dd-mm-yyyy"), `
            @{Name="Category";Expression = {$_.properties[4].value}}} | `
        Select-Object ComputerName, @{ expression={$_.TimeCreated}; label='Last Reboot' }, Username, Category | 
        export-csv -NoTypeInformation -append "C:\Shared\LastReboot\$filename.csv" 
}
}
