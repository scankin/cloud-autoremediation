[OutputType("PSAzureOperationResponse")]
param (
    [Parameter(Mandatory=$false)]
    [object] $VMServiceName,
    [object] $ScaleSetName,
    [object] $ResourceGroupName
)
$ErrorActionPreference = "stop"

If ($null -eq $VMServiceName) {
    $VMServiceName = "gremlind"
}

$StartScript = "Function Service-Start{
    try{
        $objService = Get-Service -Name $VMServiceName

        if($objService.Status -ne 'Running'){
            for($attempts = 0; $attempts -le 9; $attempts += 1){
                Start-Service $objService
                Start-Sleep 60

                if($objService.Status -eq 'Running'){
                    break
                }
            }
        }

        $status = [PSCustomObject]@{
            VMName = $([System.Net.Dns]::GetHostName())
            Service = $VMServiceName
            Status = $objService.Status
            Attempts = $attempts
        }

        return ConvertTo-Json $status
    } catch {
        Write-Output 'Unexpected Error Occured'
    }
}

Service-Start"

Function Invoke-Function {
    try{
        #Gets the Run As Account service principle connection
        $ServicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
        Add-AzAccount -ServicePrincipal -TenantId $ServicePrincipalConnection.TenantId -ApplicationId $ServicePrincipalConnection.ApplicationId -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint | Out-Null

        #Outputs the script as a file which can be run
        Out-File -InputObject $StartScript -FilePath StartScript.ps1
    
        if(Test-Path -Path StartScript.ps1 -PathType Leaf){
            $ResultArray = @()
            
            #Writes the output of the file to the runbook
            $ScaleSet = Get-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $ScaleSetName

            foreach($instance in $ScaleSet){
                try{
                    $VM = Get-AzVMssVM -ResourceGroupName $instance.resourceGroupName -VMScaleSetName $instance.Name
                    $RunScript = Invoke-AzVmssVMRunCommand -ResourceGroupName $VM.resourceGroupName -VMScaleSetName $instance.Name -InstanceID $VM.InstanceID -CommandId 'RunPowerShellScript' -ScriptPath StartScript.ps1
                
                    $Result = ConvertFrom-Json $RunScript.Value[0].Message
                    $ResultArray +=$Result
                } catch {
                    Write-Output "An unexpected error has occured"
                }
            }
        }else{
            Write-Output "Script File was not Found"
        }

    } catch {
    Write-Output "There was an issue getting the service principle connection"
    }
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
        }else{
            Write-Output 'All Services Started as Expected'
        }
      }catch{
        Write-Output 'An unexpected error occured'
      }
}

Send-Message