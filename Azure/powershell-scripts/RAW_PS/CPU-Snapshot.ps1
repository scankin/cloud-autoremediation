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
            return $Output
        }
    }

    Function Get-ProcessPercentage {
        try {
            $Top5Processes = @()

            $Processes = Get-WmiObject Win32_PerfFormattedData_PerfProc_Process | 
                         where-object{ $_.Name -ne "_Total" -and $_.Name -ne "Idle"} | 
                         Sort-Object PercentProcessorTime -Descending | 
                         Select-object Name, IDProcess, PercentProcessorTime -First 5

            ForEach ($Process in $Processes){
                $Output = [PSCustomObject]@{
                    ID = $Process.IDProcess
                    ProcessName = $Process.Name
                    CPU = $Process.PercentProcessorTime
                }
                $TopFiveProcesses += $Output
            }
            return $TopFiveProcesses
        } catch {
			$Output = [PSCustomObject]@{
                ID = "Error"
                ProcessName = "Error"
                CPU = "Error"
            }

			return $Output
		}
    }

    Function Get-LastBootup {
        try {
            $SystemUptime = Get-CimInstance -ClassName Win32_OperatingSystem |
                            Select-Object LastBootUpTime

            $uptimeString = $SystemUptime.LastBootUpTime

            return $uptimeString.ToString()
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

    Function Console-Output {
        $UptimeObject = Get-ComputeUptime | Select-Object Days, Hours, Minutes, Seconds
        $SystemInfo = " VM Name: $([System.Net.Dns]::GetHostName()) `n Number of Processes Running: $(Get-NumProcesses) `n Last Bootup: $(Get-LastBootup) `n"
        $SystemInfo += " Total Computer Uptime: $($UptimeObject.Days) Day(s) $($UptimeObject.Hours) Hour(s) $($UptimeObject.Minutes) Minute(s) $($UptimeObject.Seconds) Second(s)"
        
        Write-Output "=========================System Info===================================="
        Write-Output $SystemInfo
        Write-Output "=========================Top 5 Processes================================"
        Get-Processes | Format-Table
        Write-Output "======================Processes Total Uptime============================"
        Get-ProcessesUptime | Format-Table
        Write-Output "======================================================================="
        Get-ProcessPercentage | Format-Table
    }

    Console-Output
}

Invoke-CPUCheck