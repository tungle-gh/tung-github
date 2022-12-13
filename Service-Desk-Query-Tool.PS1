<#
.SYNOPSIS
    This is s sample IT service desk query tool.
.DESCRIPTION
    Using Windows Forms .NET to create the tool via Visual Studio 2022 Commmunity version.
    Checking Windows OS, RAM/CPU, free disk space via CIM (WS-Man)
    Checkng Windows OS build, Symantec antivirus update definition and last reboot by using EventViewer via WinRM 
.EXAMPLE
    C:\PS\.\Service-Desk-Query-Tool.PS1
.INPUTS
    String
.OUTPUTS
    Output the checking result of the computer
.NOTES
    Author:  Tung
    Date: 2022-11-28
#>

# Creating Windows Forms .NET for PowerShell GUI 
# Loading external assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Query = New-Object System.Windows.Forms.Form

$label1 = New-Object System.Windows.Forms.Label
$InputBox = New-Object System.Windows.Forms.TextBox
$CPUCheck = New-Object System.Windows.Forms.CheckBox
$Comcomputerheck = New-Object System.Windows.Forms.CheckBox
$DiskCheck = New-Object System.Windows.Forms.CheckBox
$OSBuildCheck = New-Object System.Windows.Forms.CheckBox
$SymantecCheck = New-Object System.Windows.Forms.CheckBox
$LastRebootCheck = New-Object System.Windows.Forms.CheckBox
$label2 = New-Object System.Windows.Forms.Label
$CMIRadio = New-Object System.Windows.Forms.RadioButton
$WinRMRadio = New-Object System.Windows.Forms.RadioButton
$Executebutton = New-Object System.Windows.Forms.Button
$OutputBox = New-Object System.Windows.Forms.TextBox
#
# label1
#
$label1.AutoSize = $true
$label1.Location = New-Object System.Drawing.Point(55, 17)
$label1.Margin = New-Object System.Windows.Forms.Padding(5, 0, 5, 0)
$label1.Name = "label1"
$label1.Size = New-Object System.Drawing.Size(127, 16)
$label1.TabIndex = 0
$label1.Text = "ComputerName"

#
# InputBox
#
$InputBox.Location = New-Object System.Drawing.Point(22, 42)
$InputBox.Margin = New-Object System.Windows.Forms.Padding(5, 4, 5, 4)
$InputBox.Name = "InputBox"
$InputBox.Size = New-Object System.Drawing.Size(193, 23)
$InputBox.TabIndex = 1

#
# CPUCheck
#
$CPUCheck.AutoSize = $true
$CPUCheck.Location = New-Object System.Drawing.Point(360, 68)
$CPUCheck.Name = "CPUCheck"
$CPUCheck.Size = New-Object System.Drawing.Size(146, 20)
$CPUCheck.TabIndex = 2
$CPUCheck.Text = "CPU/RAM Info"
$CPUCheck.UseVisualStyleBackColor = $true

#
# Comcomputerheck
#
$Comcomputerheck.AutoSize = $true
$Comcomputerheck.Location = New-Object System.Drawing.Point(360, 16)
$Comcomputerheck.Name = "Comcomputerheck"
$Comcomputerheck.Size = New-Object System.Drawing.Size(156, 20)
$Comcomputerheck.TabIndex = 3
$Comcomputerheck.Text = "Computer Info"
$Comcomputerheck.UseVisualStyleBackColor = $true

#
# DiskCheck
#
$DiskCheck.AutoSize = $true
$DiskCheck.Location = New-Object System.Drawing.Point(360, 122)
$DiskCheck.Name = "DiskCheck"
$DiskCheck.Size = New-Object System.Drawing.Size(116, 20)
$DiskCheck.TabIndex = 4
$DiskCheck.Text = "Disk Info"
$DiskCheck.UseVisualStyleBackColor = $true

#
# OSBuildCheck
#
$OSBuildCheck.AutoSize = $true
$OSBuildCheck.Location = New-Object System.Drawing.Point(549, 17)
$OSBuildCheck.Name = "OSBuildCheck"
$OSBuildCheck.Size = New-Object System.Drawing.Size(186, 20)
$OSBuildCheck.TabIndex = 5
$OSBuildCheck.Text = "Windows OS Build"
$OSBuildCheck.UseVisualStyleBackColor = $true

# SymantecCheck
#
$SymantecCheck.AutoSize = $true
$SymantecCheck.Location = New-Object System.Drawing.Point(549, 69)
$SymantecCheck.Name = "SymantecCheck"
$SymantecCheck.Size = New-Object System.Drawing.Size(106, 20)
$SymantecCheck.TabIndex = 6
$SymantecCheck.Text = "Symantec"
$SymantecCheck.UseVisualStyleBackColor = $true

#
# LastRebootCheck
#
$LastRebootCheck.AutoSize = $true
$LastRebootCheck.Location = New-Object System.Drawing.Point(549, 122)
$LastRebootCheck.Name = "LastRebootCheck"
$LastRebootCheck.Size = New-Object System.Drawing.Size(126, 20)
$LastRebootCheck.TabIndex = 7
$LastRebootCheck.Text = "LastReboot"
$LastRebootCheck.UseVisualStyleBackColor = $true

#
# label2
#
$label2.AutoSize = $true
$label2.Location = New-Object System.Drawing.Point(21, 117)
$label2.Margin = New-Object System.Windows.Forms.Padding(5, 0, 5, 0)
$label2.Name = "label2"
$label2.Size = New-Object System.Drawing.Size(87, 16)
$label2.TabIndex = 8
$label2.Text = "Protocol"

#
# CMIRadio
#
$CMIRadio.AutoSize = $true
$CMIRadio.Location = New-Object System.Drawing.Point(40, 151)
$CMIRadio.Name = "CMIRadio"
$CMIRadio.Size = New-Object System.Drawing.Size(95, 20)
$CMIRadio.TabIndex = 9
$CMIRadio.TabStop = $true
$CMIRadio.Text = "CIM"
$CMIRadio.UseVisualStyleBackColor = $true

#
# WinRMRadio
#
$WinRMRadio.AutoSize = $true
$WinRMRadio.Location = New-Object System.Drawing.Point(40, 187)
$WinRMRadio.Name = "WinRMRadio"
$WinRMRadio.Size = New-Object System.Drawing.Size(75, 20)
$WinRMRadio.TabIndex = 10
$WinRMRadio.TabStop = $true
$WinRMRadio.Text = "WinRM"
$WinRMRadio.UseVisualStyleBackColor = $true

#
# Executebutton
#
$Executebutton.Location = New-Object System.Drawing.Point(360, 162)
$Executebutton.Name = "Executebutton"
$Executebutton.Size = New-Object System.Drawing.Size(224, 36)
$Executebutton.TabIndex = 11
$Executebutton.Text = "Execute"
$Executebutton.UseVisualStyleBackColor = $true

#
# OutputBox
#
$OutputBox.Location = New-Object System.Drawing.Point(22, 226)
$OutputBox.Multiline = $true
$OutputBox.Name = "OutputBox"
$OutputBox.Size = New-Object System.Drawing.Size(713, 267)
$OutputBox.TabIndex = 12

#
# Query
#
$Query.ClientSize = New-Object System.Drawing.Size(739, 500)
$Query.Controls.Add($OutputBox)
$Query.Controls.Add($Executebutton)
$Query.Controls.Add($WinRMRadio)
$Query.Controls.Add($CMIRadio)
$Query.Controls.Add($label2)
$Query.Controls.Add($LastRebootCheck)
$Query.Controls.Add($SymantecCheck)
$Query.Controls.Add($OSBuildCheck)
$Query.Controls.Add($DiskCheck)
$Query.Controls.Add($Comcomputerheck)
$Query.Controls.Add($CPUCheck)
$Query.Controls.Add($InputBox)
$Query.Controls.Add($label1)
$Query.Font = New-Object System.Drawing.Font("Lucida Console", 12, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, 0)
$Query.Margin = New-Object System.Windows.Forms.Padding(5, 4, 5, 4)
$Query.Name = "Query"
$Query.Text = "IT Sevice Desk Query Tool"

# Writing a function to query the remote machine information
function execute-query {
    $computer = $inputbox.text
    # Check if the $computer is NOT NULL
    if (-not ([string]::IsNullOrEmpty($computer))){
        # use Ping to detect the machine is UP or DOWN
        $ping_result = Test-Connection -ComputerName $computer -Count 1 -Quiet
        if ($ping_result) {
            # 
            if ($CMIRadio.Checked) {
                # Using CIM via WS-Man protocol
                $option = New-CimSessionOption -Protocol wsman 
                $session = New-CimSession -ComputerName $computer -SessionOption $option
                # create a hash table
                $myobject = [ordered]@{Computername = $computer }
                if ($Comcomputerheck.checked) {
                    $os = Get-CimInstance -ClassName win32_operatingsystem -CimSession $session
                    $IPaddress = (Get-CimInstance -CimSession $Session -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'").IPAddress[0]
                    $myobject.add('OsVersion', $os.version)
                    #$myobject.add('Build', $os.buildnumber)
                    $myobject.add('OS Installed Date', $os.InstallDate)
                    $myobject.add('IP address', $IPaddress)
                    $myobject.add('OS', $os.caption)
                }
                if ($CPUcheck.checked) {
                    $cs = Get-CimInstance -ClassName win32_computersystem -CimSession $session
                    # Querying CPU information

                    $CPU_var = (Get-Counter '\Processor(_Total)\% Processor Time' -computer $computer).CounterSamples.CookedValue
                    $CPU_utilization = [Math]::Round($CPU_var) 
                    $myobject.add('Logical Processors', $cs.numberoflogicalprocessors)
                    $myobject.add('Processors', $cs.numberofprocessors)
                    $myobject.add('CPU Utilization', [string]($CPU_utilization) + '%')

                    # Querying RAM Usage information
                    $ComputerMemory = Get-CimInstance -ClassName win32_operatingsystem -CimSession $session
                    $Memory = ((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory) * 100) / $ComputerMemory.TotalVisibleMemorySize)
                    $RoundMemory = [math]::Round($Memory, 2)
                    $myobject.add('Memory Usage', [string]([Math]::Round($RoundMemory)) + '%')
                }
                if ($diskcheck.checked) {
                    # Geting physical hard drives C: and D: which are not CDROM drive
                    $disk = Get-CimInstance -ClassName win32_logicaldisk -Filter "DriveType=3" -CimSession $session | Select-Object -Property DeviceID, FreeSpace, Size 
                    # Query C: drive
                    if ($disk.deviceID -eq "C:") {
                        #$myobject.add('C: Drive', $disk.DeviceID[0])
                        $myobject.add('C: Free', [string]([Math]::Round($disk.Freespace[0] / 1GB)) + 'GB')
                        $myobject.add('C: Size', [string]([Math]::Round($disk.size[0] / 1GB)) + 'GB')
                        $myobject.add('C: % Free', [string]([Math]::Round($disk.Freespace[0] / $disk.size[0], 2) * 100) + '%')
                    }
                    # Query D: drive
                    if ($disk.deviceID -eq "D:") {
                        #$myobject.add('D: Drive', $disk.DeviceID[0])
                        $myobject.add('D: Free', [string]([Math]::Round($disk.Freespace[1] / 1GB)) + 'GB')
                        $myobject.add('D: Size', [string]([Math]::Round($disk.size[1] / 1GB)) + 'GB')
                        $myobject.add('D: % Free', [string]([Math]::Round($disk.Freespace[1] / $disk.size[1], 2) * 100) + '%')
                    }
                }

                $session | Remove-CimSession
                $obj = New-Object -TypeName psobject -Property $myobject
                $outputbox.text = ($obj | format-list | out-string).TrimStart()
            }
            if ($WinRMRadio.Checked) {
                # create a hash table  
                $myobject = [ordered]@{Computername = $computer }
                # Using WinRM to query remote machine information
                $WinRM_session = New-PSSession -ComputerName $computer
                if ($WinRM_session) {
                    if ($OSBuildCheck.checked) {
                        # Query Windows OS build by getting its information on Registry
                        $CurrentBuild_Code = Invoke-Command -Session $WinRM_session -ScriptBlock { (Get-ItemProperty -PATH 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion') }
                        Try {

                            $DisplayVersion = $CurrentBuild_Code.DisplayVersion
                        }
                        Catch {
                            $DisplayVersion = $null
                        }
                        if ($null -ne $DisplayVersion) {
                            # Windows 10/11
                            $myobject.add('Windows OS Build', $DisplayVersion + "." + $CurrentBuild_Code.CurrentBuild + "." + $CurrentBuild_Code.UBR)
                        }
                        else {
                            # Widows server 2016 does not have "Displayversion" information 
                            $myobject.add('Windows OS Build', $CurrentBuild_Code.CurrentBuild + "." + $CurrentBuild_Code.UBR)
                        }
                    }
                } 

                if ($SymantecCheck.checked) {
                    # Query Symantec antivirus update definition by getting its information on Registry
                    $Symantec_Code = Invoke-Command -Session $WinRM_session -ScriptBlock { (Get-ItemProperty -PATH 'HKLM:\SOFTWARE\Symantec\Symantec Endpoint Protection\CurrentVersion\Public-Opstate') } -ErrorAction SilentlyContinue
                    $Symantec_Update = [string]($Symantec_Code.LatestVirusDefsDate) + " " + "r" + [string]($Symantec_Code.LatestVirusDefsRevision)
                    $myobject.add('Symantec_DefsDate', $Symantec_Update)
                }

                if ($LastRebootCheck.checked) {
                    # Query Last Reboot information via Event Viewer with Event ID is 1074, then output Username, TimeCreated and Category of its value
                    $LastReboot_code = Invoke-Command -Session $WinRM_session -ScriptBlock { Get-WinEvent -filterhash @{Logname = 'system'; ID = 1074 } -MaxEvents 1 | Select-Object `
                        @{Name = "Computername"; Expression = { $_.properties[1].value } }, `
                        @{Name = "UserName"; Expression = { ($_.properties[-1]).value } }, @{ expression = { $_.TimeCreated }; label = 'Last Reboot' }, ` 
                        @{Name = "Category"; Expression = { $_.properties[4].value } } } 
                    $myobject.add('LastReboot', $LastReboot_code.'Last Reboot')
                    $myobject.add('UserName', $LastReboot_code.'Username')
                    $myobject.add('Category', $LastReboot_code.'Category')
                    }
                }

                $WinRM_session | Remove-PSSession
                $winrm_obj = New-Object -TypeName psobject -Property $myobject
                $outputbox.text = ($winrm_obj | format-list | out-string).TrimStart()
                #$WinRM_session | Remove-PSSession
            }
        }
    }
}

$Executebutton.add_click({ execute-query })
[void]$query.ShowDialog()
