
Function Invoke-CPUCheck {  
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
        [Array]$Uptimes = @()
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
        
    }
 }

 echo "Num Processes: "
 Get-NumProcesses
 echo "Top 5 Processes: "
 Get-Processes | Format-Table -AutoSize
 echo "Process Uptimes: "
 Get-ProcessesUptime | Format-Table -AutoSize

}
