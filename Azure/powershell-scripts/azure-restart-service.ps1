[OutputType("PSAzureOperationResponse")]
param (
    [Parameter(Mandatory=$false)]
    [object] $WebhookData
)
$ErrorActionPreference = "stop"

$RestartScript = 'Function Service-Restart {
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

Service-Restart'

try{
    #Gets the Run As Account service principle connection
    $ServicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
    Add-AzAccount -ServicePrincipal -TenantId $ServicePrincipalConnection.TenantId -ApplicationId $ServicePrincipalConnection.ApplicationId -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint | Out-Null

    #Outputs the script as a file which can be run
    Out-File -InputObject $RestartScript -FilePath RestartScript.ps1
    if($WebhookData){
    	$WebhookBody = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)
    	$schemaID = $WebhookBody.$schemaID

		if($schemaID = "AzureMonitorMetricAlert"){
			#Collects the infromation needed from the Metric Alert Webhook to run on VM
        	$AlertContext = [object] ($WebhookBody.data).context 
        	$ResourceGroup = $AlertContext.resourceGroupName
        	$VMScaleSet = $AlertContext.resourceName

			if(Test-Path -Path RestartScript.ps1 -PathType Leaf){
				$ResultArray = @()
				
				#Writes the output of the file to the runbook
				$ScaleSet = Get-AzVmss -ResourceGroupName $ResourceGroup -VMScaleSetName $VMScaleSet

				foreach($instance in $ScaleSet){
					try{
						$VM = Get-AzVMssVM -ResourceGroupName $instance.resourceGroupName -VMScaleSetName $instance.Name

						Invoke-AzVmssVMRunCommand -ResourceGroupName $VM.resourceGroupName -VMScaleSetName $instance.Name -InstanceID $VM.InstanceID -CommandId 'EnableAdminAccount' | Out-Null
						$RunScript = Invoke-AzVmssVMRunCommand -ResourceGroupName $VM.resourceGroupName -VMScaleSetName $instance.Name -InstanceID $VM.InstanceID -CommandId 'RunPowerShellScript' -ScriptPath RestartScript.ps1

						Write-Output $RunScript.Value[0].Message

						#$Result = ConvertFrom-Json $RunScript.Value[0].Message
						#$ResultArray +=$Result
					} catch {
						$ErrMsg = "Powershell exception :: Line# $($_.InvocationInfo.ScriptLineNumber) :: $($_.Exception.Message)"
						Write-Output "Script failed to run"
						Write-Output $ErrMsg
					}
				}

			}else{
				$ErrMsg = "Powershell exception :: Line# $($_.InvocationInfo.ScriptLineNumber) :: $($_.Exception.Message)"
				Write-Output "Script failed to run"
				Write-Output $ErrMsg
			}
		}
	} else {
		Write-Output "There was Webhook Data passed in"
	}
} catch {
        $ErrMsg = "Powershell exception :: Line# $($_.InvocationInfo.ScriptLineNumber) :: $($_.Exception.Message)"
        Write-Output "Script failed to run"
        Write-Output $ErrMsg
}


Function Send-Message {
    try{
        $ResultsArray = Invoke-Function
        $GoodArray = @()
        $BadArray = @()

        foreach($result in $ResultsArray){
            if($result.Status -ne "Running"){
                $BadArray += $result
            } else {
                $GoodArray += $result
            }
        }

        if($BadArray.Length -ge 1){
            $OutputMessage = "The following services on the following VMs did not restart. `n"

            foreach($BadResult in $BadArray){
                $OutputMessage += "VMName: $($BadResult.VMName) Service Name: $($BadResult.Service) Restart Attempts: $($BadResult.Attempts)`n"
            }

            $payload = [PSCustomObject]@{
                username = "AzureBot"
                text = $OutputMessage
            }

            Invoke-WebRequest -UseBasicParsing 'https://hooks.slack.com/services/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' -SessionVariable 'Session' -Body (ConvertTo-Json $payload) -Method 'POST'

        }
      }catch{
        Write-Output 'An unexpected error occured'
      }
}

Send-Message