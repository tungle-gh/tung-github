# Using PSCustomobject
# Get-WindowsVersion -ComputerName $computer | Select-Object 'computerName',  'Windows Edition', 'version', 'OS Build' | sort 'OS Build' -Descending| Format-Table
function Get-WindowsVersion-R {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    $results = @()

    Foreach ($computer in $ComputerName) {
        if (Test-Connection -ComputerName $computer -Count 1 -Quiet) {
            $code = {
                $registryKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
                $productName = (Get-ItemProperty $registryKey -Name ProductName).ProductName
                $version = "N/A"
                try {
                    $version = (Get-ItemProperty $registryKey -Name ReleaseId -ErrorAction Stop).ReleaseId
                }
                catch {}
                $currentBuild = (Get-ItemProperty $registryKey -Name CurrentBuild).CurrentBuild
                $ubr = (Get-ItemProperty $registryKey -Name UBR).UBR
                $osVersion = "$currentBuild.$ubr"
                [pscustomobject]@{
                    "ComputerName" = $env:COMPUTERNAME
                    "Windows Edition" = $productName
                    "Version" = $version
                    "OS Build" = $osVersion
                }
            }

            if ($computer -eq $env:COMPUTERNAME) {
                $result = Invoke-Command -ScriptBlock $code
            } else {
                try {
                    $result = Invoke-Command -ComputerName $computer -ScriptBlock $code -ErrorAction Stop
                } catch {
                    $_
                }
            }

            $results += $result
        }
    }
    return $results
}

--
# Get-WindowsVersion -ComputerName $computer | Select-Object 'computerName',  'Windows Edition', 'version', 'OS Build' | sort 'OS Build' -Descending| Format-Table
ComputerName Windows Edition Version OS Build  
------------ --------------- ------- --------  
ABC         Windows 10 Pro  2009    19045.2364
XYZ         Windows 10 Pro  2009    19045.2364
