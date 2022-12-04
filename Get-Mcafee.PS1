function Get-Mcafee{
[CmdletBinding()]

Param
(
    [Parameter(Mandatory=$false,
                ValueFromPipelineByPropertyName=$true,
                ValueFromPipeline=$true
                )]
    [string[]]$ComputerName = $env:COMPUTERNAME
)

BEGIN {}
PROCESS {

Foreach ($Computer in $ComputerName)
{ 
    try {
        #$ping = Test-Connection -computerName $Computer -count 1 -Quiet
        #$ping = Test-NetConnection -computerName $Computer -port 5985 -InformationAction SilentlyContinue
        #if($ping)
            $Result = Invoke-Command -ComputerName $Computer -ScriptBlock {Get-ItemProperty -PATH 'HKLM:\SOFTWARE\McAfee\VirusScan\InstallSettings\Substitute'} -ErrorAction Stop  
            $properties = [ordered]@{
                    ComputerName = $Computer
                    'Mcafee Build' = $Result.build
                    'Mcafee Last Update' = $Result.date
                    }

        }  catch {
            Write-Verbose "Coundn't connect to $computer"
            $properties = [ordered]@{
                    ComputerName = $Computer
                    'Mcafee Build' = $Result.build
                    'Mcafee Last Update' = $Result.date
                        } 
        } 
        finally {
            $obj = New-Object -Typename PSCustomObject -Property $properties
            Write-Output $obj 
            
        }
}  
}
}
