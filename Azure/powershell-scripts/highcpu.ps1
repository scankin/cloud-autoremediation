[OutputType("PSAzureOperationResponse")]
param (
    [Parameter(Mandatory=$false)]
    [object] $WebhookData
)
$ErrorActionPreference = "stop"

$Script = 'Function Invoke-CPUCheck {  
    #Returns the number of processes running on the machine
    Function Get-NumProcesses {
        try {
            $ProcessCount = (Get-Process).Count
            return $ProcessCount
        }
        catch {
            $ProcessCount = "Error Occured"
            return $ProcessCount
        }
    }

    #Function to get the Top 5 Processes running on the machine
    Function Get-Processes {
        try {

            $TopFiveProcesses = @()

            $Processes = Get-Process | 
                         Sort-Object CPU -desc |
                         Select-Object ProcessName,ID,CPU,Description -First 5

                ForEach ($Process in $Processes){
                    $Output = [PSCustomObject]@{
                        ID = $Process.Id
                        ProcessName = $Process.ProcessName
                        CPU = [math]::round($Process.CPU, 2)
                        Description = $Process.Description
                    }

                    $TopFiveProcesses += $Output
                }
                return $TopFiveProcesses
            
        }
        catch {
            $Output = [PSCustomObject]@{
                ID = "Error"
                ProcessName = "Error"
                CPU = "Error"
                Description = "Error"
            }
            return $TopFiveProcess
        }
    }

    Function Get-LastBootup {
        try {
            $SystemUptime = Get-CimInstance -ClassName Win32_OperatingSystem |
                            Select-Object LastBootUpTime

            $uptimeString = $SystemUptime.LastBootUpTime

            return $uptimeString
        }
        catch {
            $SystemUptime = "Error"
            return $SystemUptime
        }
    }
  #Get how long top processes have been running for
    Function Get-ProcessesUptime {
        try {
            $Uptimes = @()
            $Processes = Get-Processes
                ForEach($Process in $Processes){
                    #Get the Uptime Value for each Process
                    $Uptime = New-TimeSpan -Start (Get-Process -id $Process.Id).StartTime |
                            Select-Object Days, Hours, Minutes, Seconds

                    $Output = [PSCustomObject]@{
                        ProcessName = $Process.ProcessName
                        Days = $Uptime.Days
                        Hours = $Uptime.Hours
                        Minutes = $Uptime.Minutes
                        Seconds = $Uptime.Seconds
                    }

                    $Uptimes += $Output
                }
                return $Uptimes
        }catch{
            $Output = [PSCustomObject]@{
                ProcessName = "Error"
                Days = "Error"
                Hours = "Error"
                Minutes = "Error"
                Seconds = "Error"
            }
        
            return $Output
        }
    }

    #Function to get the Uptime of the PC
    Function Get-ComputeUptime {
        try{
            $ComputerUptime = (Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime |
                              Select-Object Days, Hours, Minutes, Seconds

            $Output = [PSCustomObject]@{
                Days = $ComputerUptime.Days
                Hours = $ComputerUptime.Hours
                Minutes = $ComputerUptime.Minutes
                Seconds = $ComputerUptime.Seconds
            }

            return $Output
        }catch{
            $Output = [PSCustomObject]@{
                Days = "Error"
                Hours = "Error"
                Minutes = "Error"
                Seconds = "Error"
            }

            return $Output
        }
    }

    Function Create-Log{
        #Adds the date & System Info to Log
        $logRecord = "$(Get-Date -format "MM/dd/yyyy HH:mm:ss") "
        $logRecord = $logRecord + "SystemInfo(Processes: $(Get-NumProcesses), LastBootTime: $(Get-LastBootup), ComputerUptime($(Get-ComputeUptime))) "
        $logRecord = $logRecord + "ProcessInfo("
        
        #Loops through each of the top 5 processes, adding the information to the log
        $Counter = 0
        $ProcessLog = Get-Processes
        ForEach($Process in $ProcessLog){
            $logRecord = $logRecord + "ProcessName[$($Counter)]: $($Process.ProcessName) CPUMetric[$($Counter)]: $($Process.CPU) "
            $Counter += 1
        }

        Write-Output $logRecord

    }

    Function Create-JSON{

        $UptimeObject = Get-ComputeUptime | Select-Object Days, Hours, Minutes, Seconds

        $UpTime = [ordered]@{"Days" = "$($UptimeObject.Days)"; "Hours" = "$($UptimeObject.Hours)"; "Minutes" = "$($UptimeObject.Minutes)"; "Seconds" = "$($UptimeObject.Seconds)"}
        
        $ProcessList = New-Object System.Collections.ArrayList
        $Processes = Get-Processes
        $Counter = 0
        ForEach($Process in $Processes){
            $ProcessItem = [ordered]@{"ID" = "$($Process.Id)";"Name" = "$($Process.ProcessName)"; "CPUMetric" = "$($Process.CPU)"}
            $ProcessList += $ProcessItem
            $Counter += 1
        }
        
        $SystemInfo = [ordered]@{"NumProcesses" = "$(Get-NumProcesses)"; "LastBootup" = "$(Get-LastBootup)"; "UpTime" = $UpTime}
        $SystemInfo.Add("Processes", $ProcessList)
        $output = [ordered]@{"VMName" = "$([System.Net.Dns]::GetHostName())"; "SystemInfo" = $SystemInfo}



        Write-Output $output | ConvertTo-Json -Depth 100
    }

    Create-JSON
}

Invoke-CPUCheck'

#Gets the Run As Account service principle connection
$ServicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
Add-AzAccount -ServicePrincipal -TenantId $ServicePrincipalConnection.TenantId -ApplicationId $ServicePrincipalConnection.ApplicationId -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint | Out-Null

#Outputs the script as a file which can be run
Out-File -InputObject $Script -FilePath Script.ps1

if($WebhookData){
    $WebhookBody = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)
    $schemaID = $WebhookBody.$schemaID

    if($schemaID = "AzureMonitorMetricAlert"){
        #Collects the infromation needed from the Metric Alert Webhook to run on VM
        $AlertContext = [object] ($WebhookBody.data).context 
        $ResourceGroup = $AlertContext.resourceGroupName
        $VMScaleSet = $AlertContext.resourceName
        #Checks the Script file has been made
        if(Test-Path -Path Script.ps1 -PathType Leaf){
            #Writes the output of the file to the runbook
            $ScaleSet = Get-AzVmss -ResourceGroupName $ResourceGroup -VMScaleSetName $VMName
            foreach($instance in $ScaleSet){
                $VM = Get-AzVMssVM -ResourceGroupName $instance.resourceGroupName -VMScaleSetName $instance.Name
                $RunScript = Invoke-AzVmssVMRunCommand -ResourceGroupName $VM.resourceGroupName -VMScaleSetName $instance.Name -InstanceID $VM.InstanceID -CommandId 'RunPowerShellScript' -ScriptPath Script.ps1
                $JSONOut = $RunScript.Value[0].Message
                Write-Output $JSONOut
                Invoke-WebRequest 'https://autoslackmessage.azurewebsites.net/api/HttpTrigger1?code=vIbsptXMuHdXt8UagIUoAaEL26RhUCnvhWqxC3RGQW4hsF6VmtD5Pg==' -SessionVariable 'Session' -Body $JSONOut -Method 'POST'
            }
        }else{
            Write-Output "Script File was not Found"
        }
    }else{
        Write-Output "Script schema was not correct"
    }
}else{
    Write-Output "There was no Webhook Data"
}

Disconnect-AzAccount -ApplicationID $ServicePrincipalConnection.ApplicationID -TenantID $ServicePrincipalConnection.TenantID | Out-Null