Function Invoke-ServiceRestart {
    try{
		$objService = Get-Service -Name "gremlind"
		$attempts = 0
        Do{
			$attempts += 1
            #Restart the service
            Restart-Service $objService
            #Sleep to allow for service to restart
            Start-Sleep 30
        }Until(($attempts -ge 5) -Or ($objService.Status -eq "Running"))

        $status = [PSCustomObject]@{
            VMName = $([System.Net.Dns]::GetHostName())
            Service = $objService.Name
            Status = $status
            Attempts = ($attempts + 1)
        }

        return ConvertTo-Json $status
    }catch{
        $status = [PSCustomObject]@{
            VMName = "Error"
            Service = "Error"
            Status = "Error"
            Attempts = "Error"
        }

		return ConvertTo-Json $status
    }
}

Service-Restart