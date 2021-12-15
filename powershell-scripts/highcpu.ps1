
#Function CheckHigh-CPU {  
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

            [Array]$TopFiveProcesses = @()

            $Processes = Get-Process | 
                         Sort-Object CPU -desc |
                         Select -first 5 |
                         Select ProcessName,ID,CPU,Description

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
            $TopFiveProcesses = "Error Occured"
            return $TopFiveProcess
        }
    }
  #Get how long top processes have been running for
  Function Get-ProcessesUptime {
    try {
        $Uptimes = @()
        $Processes = Get-Processes
        if($Processes.length() -gt 0){
            ForEach($Process in $Processes){
                $Output = [PSCustomObject]@{
                    ProcessName = $Process.ProcessName
                    Uptime = New-TimeSpan -Start (get-process $Process.ProcessName).StartTime
                }
            }
        }
    }catch{

    }

# }
#}
    echo "Num Processes: "
    Get-NumProcesses
    echo "Top 5 Processes: "
    Get-Processes | Format-Table -AutoSize