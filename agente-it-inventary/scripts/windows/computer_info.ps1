function Get-MemorySlots {
    $slots = Get-CimInstance -ClassName Win32_PhysicalMemory
    $slotInfo = @()

    $slotNumber = 1
    foreach ($slot in $slots) {
        $slotInfo += @{
            "Size"  = "SLOT $slotNumber Size: $($slot.Capacity / 1GB)GB"
            "Speed" = "SLOT $slotNumber Speed: $($slot.Speed)MHz"
            "Type"  = "SLOT $slotNumber Type: $($slot.MemoryType)"
        }
        $slotNumber++
    }

    return $slotInfo
}

function Get-SystemInfo {
    $computerModel = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
    $cpuModel = (Get-CimInstance -ClassName Win32_Processor).Name
    $memory = (Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB
    $disk = Get-Volume | Measure-Object -Property SizeRemaining -Sum | ForEach-Object { $_.Sum / 1GB }
    $diskModel = Get-Disk | ForEach-Object { $_.Model }
    $diskPartitions = (Get-Volume | ForEach-Object { $_.DriveLetter }) -join " | "
    $ipAddress = (Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.PrefixOrigin -eq 'Dhcp' }).IPAddress
    $ipType = if ((Get-NetIPConfiguration).NetAdapter.Status -contains "Up") { "Dinámica" } else { "Estática" }
    $osName = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
    $osFull = $osName
    $osRelease = (Get-CimInstance -ClassName Win32_OperatingSystem).Version
    $users_loggedin_this_year = (Get-Content -Path (Get-LogFilePath) | Where-Object { $_ -notmatch '^(root|reboot)' -and $_ -match (Get-Date -Format 'yyyy') } | Measure-Object).Count

    $memorySlots = Get-MemorySlots

    $jsonOutput = @{
        result = @(
            @{
                field      = "Modelo de equipo"
                value      = $computerModel
                data_group = "hardware"
                not_show   = "true"
            },
            @{
                field      = "CPU"
                value      = $cpuModel
                data_group = "hardware"
                not_show   = "true"
            },
            @{
                field      = "Ram memory"
                value      = "{0:N2} GB" -f $memory
                data_group = "hardware"
            },
            @{
                field      = "Memory slots"
                value      = ($memorySlots | ForEach-Object { $_.Size }) -join "`n"
                data_group = "hardware"
                not_show   = "true"
            },
            @{
                field      = "Memory slots speed"
                value      = ($memorySlots | ForEach-Object { $_.Speed }) -join "`n"
                data_group = "hardware"
                not_show   = "true"
            },
            @{
                field      = "Memory slots type"
                value      = ($memorySlots | ForEach-Object { $_.Type }) -join "`n"
                data_group = "hardware"
                not_show   = "true"
            },
            @{
                field      = "Hard disc"
                value      = "{0:N2} GB" -f $disk
                data_group = "hardware"
            },
            @{
                field      = "Hard disc model"
                value      = $diskModel -join "`n"
                data_group = "hardware"
                not_show   = "true"
            },
            @{
                field      = "Hard disc partitions"
                value      = $diskPartitions
                data_group = "hardware"
                not_show   = "true"
            },
            @{
                field      = "IP"
                value      = $ipAddress
                data_group = "network"
            },
            @{
                field      = "IP - tipo"
                value      = $ipType
                data_group = "network"
            },
            @{
                field      = "OS"
                value      = $osName
                data_group = "system"
                not_show   = "true"
            },
            @{
                field      = "OS Fullname"
                value      = $osFull
                data_group = "system"
            },
            @{
                field      = "OS release"
                value      = $osRelease
                data_group = "system"
            },
            @{
                field      = "OS release"
                value      = $osRelease
                data_group = "system"
            },
            @{
                field      = "Usuarios en $(Get-Date -Format 'yyyy')"
                value      = $users_loggedin_this_year
                data_group = "system"
            }
        )
    }

    $jsonOutput | ConvertTo-Json -Depth 3
}

Get-SystemInfo
