function Get-IPaddress {
    <#
    .SYNOPSIS
        Output the IP-based Geolocation of the given IP address via PowerShell.
    .DESCRIPTION
        This PowerShell script outputs the geographic location of the given IP address.
    .PARAMETER IPAddress
        Specifies the IP address
    .EXAMPLE
        PS> Get-IPaddress 8.8.8.8
    .INPUTS
        String
    .OUTPUTS
        PSCustomObject
    .NOTES
        Author:  Tung
        Date: 2022-11-15
    #>
    [CmdletBinding()]
    Param (
            [Parameter(
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
     
            [string[]]
                $IPaddress = ""
        )
    BEGIN {}
    PROCESS {
    try {
        if ($IPaddress -eq "" ) {
            $IPaddress = read-host "Enter IP address to check Geo-IP information"
        }
        $result = Invoke-RestMethod -Method Get -Uri http://ip-api.com/json/$IPaddress
        # Create a PSCustomObject to contain Geo-IP information
        $myObject = [PSCustomObject]@{
            IP = $result.query
            City = $result.City
            Country = $result.Country
            Region = $result.Region
            ISP = $result.isp
            }
    }
    catch
    {
        #"Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
        $_
    }
    finally {
        $myObject | format-list
        #$myObject | ConvertTo-Json
    }   
    }
}
