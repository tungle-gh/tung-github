$inputpath = get-content "/var/log/auth.log"
#$inputpath = get-content "/Users/tungle/Downloads/auth.log.txt"
$regex = "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"
$output = $inputpath | Select-String -Pattern $regex -AllMatches | Select-String "failed password for root" | % { $_.Matches } | % { $_.Value } `
| Group-Object |  Select-Object Name, Count | Where-Object {$_.Count -gt 20}
ForEach($line in $output){
        $IP = $line.Name
	$API = @{
                Uri    = "http://ip-api.com/json/$IP"
                Method = "Get"
            }
        $result = Invoke-RestMethod @API
        #$result = Invoke-RestMethod -Method Get -Uri http://ip-api.com/json/$IP
        # Sleep a second 
        Start-Sleep 1
    	#Write-Output $_count
        $myObject = [PSCustomObject]@{
        	Count = $line.Count
		"IPAddress" = $line.Name
            	#IP = $result.query
            	Country = $result.Country
}
    $myObject
}
