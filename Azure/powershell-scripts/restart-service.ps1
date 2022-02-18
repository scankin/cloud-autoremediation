
param($ServiceName)

#Get the service
$objService = Get-Service -Name $ServiceName

#Gives the runbook 10 attempts to restart the service
for($attempts = 0; $attempts -le 9; $attepmts += 1){
    Write-Output "Attempt: $($attempts + 1)"
    try{
        if($objService.Status -ne "Running"){
            Write-Output "$($objService.Name) is currently not running."
            Write-Output "The runbook will attempt to start the service."

            #Start the service
            Start-Service $objService
            #Sleep for a minute to allow service to start
            Start-Sleep 60
            
            #Check to see if the service is running, if it is, exit loop
            if($objService.Status -eq "Running"){
                Write-Output "$($objService.Name) is now Running."
                break
            }else{
                Write-Output "The service did not start, the runbook will reattempt to start the service."
            }

        #If the service is still running, restart the service
        }else{
            Write-Output "${objService.Name} is currently running."
            Write-Output "The runbook will attempt to restart the service."

            #Restart the service
            Restart-Service $objService
            #Sleep to allow for service to restart
            Start-Sleep 60
            
            if(objService.Status -eq "Running"){
                Write-Output "$($objService.Name) has restarted successfully."
                break
            }else{
                Write-Output "The service did not restart, the runbook will reattempt to start the service"
            }
        }
    }catch{
        Write-Output "An unexpected error with the runbook occured"
    }
}

#Check for the final result
# False = Service is not running
# True = Service is running
if ($objService.Status -eq "Running") {
    Write-Output "True"
} else {
    Write-Output "False"
}