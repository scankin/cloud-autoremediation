
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

            $uptimeString = "Days: $($ComputerUptime.Days) Hours: $($ComputerUptime.Hours) Minutes: $($ComputerUptime.Minutes) Seconds: $($ComputerUptime.Seconds)"

            return $uptimeString
        }catch{
            $uptimeString = "Days: Error Hours: Error Minutes: Error Seconds: Error"
            return ComputerUptime
        }
    }

    Function Create-Log{
        $file = 'c:\SysLogs\cpu-log.log'

        #Checks to see if the log file exists
        if(-not(Test-Path -Path $file -PathType Leaf)){
            try {
                New-Item -ItemType File -Path $file -Force -ErrorAction Stop
                Create-Log
            }
            catch {
                $errorMessage = "The file does not exist and has not been created."
                Write-Output $errorMessage
            }
        } else {
            $logRecord = "$(Get-Date -format 'MM/dd/yyyy HH:mm:ss') "
            $logRecord = $logRecord + "SystemInfo(Processes: $(Get-NumProcesses) LastBootTime: $(Get-LastBootup) ComputerUptime($(Get-ComputeUptime))) "
            $logRecord = $logRecord + "ProcessInfo("
        
            $Counter = 0
            $ProcessLog = Get-Processes
            ForEach($Process in $ProcessLog){
                $logRecord = $logRecord + "ProcessName[$($Counter)]: $($Process.ProcessName) CPUMetric[$($Counter)]: $($Process.CPU) "
                $Counter += 1
            }

            Add-Content -Path $file -Value $logRecord -Encoding utf8
        }
    }

    Create-Log
}

Invoke-CPUCheck