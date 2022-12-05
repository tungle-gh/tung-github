function Get-Resources {
    [CmdletBinding()]   
    Param
    (
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true
        )]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )    
    BEGIN {}
    PROCESS { 
        Foreach ($Computer in $ComputerName) {
            try {  
                # Processor utilization 
                $cpu = (Get-WmiObject -ComputerName $computer -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
                # Memory utilization 
                $ComputerMemory = Get-WmiObject -ComputerName $computer -Class win32_operatingsystem -ErrorAction Stop 
                $Memory = ((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory) * 100) / $ComputerMemory.TotalVisibleMemorySize) 
                $RoundMemory = [math]::Round($Memory, 2) 
                # Free disk space 
                $driveData = Get-PSDrive C | Select-Object Used, Free
                $total = $driveData.Used + $driveData.Free
                $Free_C = [Math]::Round($driveData.Free / 1GB)
                $percentageFree_C = 100 - ([Math]::Round($driveData.Free / $total, 2) * 100)
                # Write results 
                $properties = [ordered]@{
                    ComputerName   = $Computer
                    'CPU Usage'    = $cpu
                    'RAM Usage'    = $RoundMemory
                    'C: Free GB'   = $Free_C
                    'C: Percentage' = $percentageFree_C
                }
            } 
            catch { 
                $properties = [ordered]@{
                    ComputerName   = $Computer
                    'CPU Usage'    = $null
                    'RAM Usage'    = $null
                    'C: Free GB'   = $null
                    'C: Percentage' = $null
                }
            }
            finally {
                $obj = New-Object -Typename PSCustomObject -Property $properties
                Write-Output $obj
                # Write log information into a CSV log file
                $logPath = 'C:\Scripts\Logs' #log path location
                $logFile = "$logPath\check.csv" #log file
                if (-not (Test-Path -Path $logPath -ErrorAction Stop )) {
                    # Create a CSV log file
                    New-Item -ItemType Directory -Path $logPath -ErrorAction Stop | Out-Null
                    New-Item -ItemType File -Path $logFile -ErrorAction Stop | Out-Null
                }
                # Apppend content to CSV file
                $obj | Select-Object ComputerName, 'CPU Usage', 'RAM Usage', 'C: Percentage' | Export-csv -NoTypeInformation -append $logFile
            }
        }
        #monior free C hard drive
        if ($percentageFree_C -le 10) {
            $messageSplat = @{
                    BotToken ="965385337:AAH9FHX92cHcMdkR8y2olckKUJtpdHAMfAA"
                    ChatID = "824628585"
                    Message = "[LOW SPACE] Drive C at: $percentageFree_C%"
                    #Message     = "[LOW SPACE] Drive at: $percentFreeD%"
                    ErrorAction = 'Stop'
                }
                Send-TelegramTextMessage @messageSplat
            }
        #monior RAM usage
            if ($RoundMemory -ge 80) {    
            $messageSplat = @{
                BotToken    = "965385337:AAH9FHX92cHcMdkR8y2olckKUJtpdHAMfAA"
                ChatID      = "824628585"
                Message     = "[LOW SPACE] Memory at: $RoundMemory%"
                #Message     = "[LOW SPACE] Drive at: $percentFreeD%"
                ErrorAction = 'Stop'
            }
            Send-TelegramTextMessage @messageSplat
        }
        #monior CPU usage
        if ($cpu -ge 80) {
            $messageSplat = @{
                BotToken    = "965385337:AAH9FHX92cHcMdkR8y2olckKUJtpdHAMfAA"
                ChatID      = "824628585"
                Message     = "[High Usage] CPU at: $CPU%"
                #Message     = "[LOW SPACE] Drive at: $percentFreeD%"
                ErrorAction = 'Stop'
            }
            Send-TelegramTextMessage @messageSplat
        }
        #sleep 5
    }
}
