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

$RestartScript = "try {
    $objService = Get-Service -Name $VMServiceName
    if($objService.Status -ne 'Running'){
        for($attempts = 0; $attempts -le 9; $attepmts += 1){
            Write-Output '$($objService.Name) is currently not running.'
            Write-Output 'The runbook will attempt to start the service.'

            #Start the service
            Start-Service $objService.
            #Sleep for a minute to allow service to start
            Start-Sleep 60
            
            #Check to see if the service is running, if it is, exit loop
            if($objService.Status -eq 'Running'){
                Write-Output '$($objService.Name) is now Running.'
                break
            }else{
                Write-Output 'The service did not start, the runbook will reattempt to start the service.'
            }
        }

        if($objService.Status -ne 'Running') {
            Write-Output 'The service did not restart after $($attempts) attempts'
        }
    } else {
        Write-Output 'The Service was already running'
    }
} catch {
    Write-Output 'An error occured when attempting to run the script'
}"

try{
    #Gets the Run As Account service principle connection
    $ServicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
    Add-AzAccount -ServicePrincipal -TenantId $ServicePrincipalConnection.TenantId -ApplicationId $ServicePrincipalConnection.ApplicationId -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint | Out-Null

    #Outputs the script as a file which can be run
    Out-File -InputObject $RestartScript -FilePath RestartScript.ps1
    
    if(Test-Path -Path RestartScript.ps1 -PathType Leaf){
        #Writes the output of the file to the runbook
        $ScaleSet = Get-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $ScaleSetName
        foreach($instance in $ScaleSet){
            $VM = Get-AzVMssVM -ResourceGroupName $instance.resourceGroupName -VMScaleSetName $instance.Name
            $RunScript = Invoke-AzVmssVMRunCommand -ResourceGroupName $VM.resourceGroupName -VMScaleSetName $instance.Name -InstanceID $VM.InstanceID -CommandId 'RunPowerShellScript' -ScriptPath RestartScript.ps1
            Write-Output $RunScript.Value[0].Message
        }
    }else{
        Write-Output "Script File was not Found"
    }

} catch {
    Write-Output "There was an issue getting the service principle connection"
}
