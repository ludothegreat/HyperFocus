# Initialize the hyperFocusTasks list
function Initialize-HyperFocus {
    $script:defaultFilePath = Join-Path $env:USERPROFILE 'hyperfocus_list.txt'
    if (Test-Path -Path $script:defaultFilePath) {    
        Import-HyperFocusTasks -Path $script:defaultFilePath
    } else {
        $script:hyperFocusTasks = New-Object System.Collections.ArrayList
    }
}

# Import-HyperFocusTasks function
function Import-HyperFocusTasks {
    param([string]$Path)
    if (Test-Path -Path $Path) {
        $Content = Get-Content -Path $Path
        $Content = @($Content)
        $script:hyperFocusTasks = New-Object System.Collections.ArrayList
        $Content | ForEach-Object {
            $Item, $Priority, $DueDate, $Status = $_.Split(',').Trim()
            $Hyperfocus = New-Object PSObject -Property @{
                'Item' = $Item
                'Priority' = $Priority
                'DueDate' = $DueDate
                'Status' = $Status
            }
            $script:hyperFocusTasks.Add($Hyperfocus) | Out-Null
        }
    } else {
        Write-Host "File not found. Initializing an empty task list."
        $script:hyperFocusTasks = New-Object System.Collections.ArrayList
    }
}

# Call Initialize-HyperFocus when the module is imported
Initialize-HyperFocus

<#
.SYNOPSIS
    Adds one or multiple HyperFocus tasks.
.DESCRIPTION
    Creates and adds one or multiple HyperFocus tasks with the provided details and exports them to the default file.
.PARAMETER -Items
    The description(s) of the task(s). Can be a single string or an array of strings.
.PARAMETER -Priority
    The priority of the task(s). Default is 'Medium'.
.PARAMETER -DueDate
    The due date for the task(s). Default is null (no due date).
.PARAMETER -Status
    The status of the task(s). Default is 'Not Started'.
#>
function Add-HyperFocusTask {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)]
        [string[]]$Items = @('Default Task'),

        [ValidateSet('High', 'Medium', 'Low')]
        [string]$Priority = 'Medium',

        [string]$DueDate = $null,      

        [ValidateSet('Not Started', 'In Progress', 'On Hold', 'Completed', 'Cancelled')]
        [string]$Status = 'Not Started' 
    )
    
    # Ensure the hyperFocusTasks array exists
    if ($null -eq $script:hyperFocusTasks) {
        $script:hyperFocusTasks = New-Object System.Collections.ArrayList
    }

    # Loop through each item to create and add HyperFocus tasks
    $Items | ForEach-Object {
        $hyperfocus = New-Object PSObject -Property @{
            'Item' = $_
            'Priority' = $Priority
            'DueDate' = $DueDate
            'Status' = $Status
        }

        $script:hyperFocusTasks.Add($hyperfocus) | Out-Null
    }

    # Export the updated tasks list to file
    Export-HyperFocusTasks -Path $script:defaultFilePath
}

<#
.SYNOPSIS
    Removes a HyperFocus task by index.
.DESCRIPTION
    Removes a HyperFocus task by the given index and exports the changes to the default file.
.PARAMETER -Index
    The index of the task to remove.
#>
function Remove-HyperFocusTask {
    param([int]$Index)
    if ($Index -ge 0 -and $Index -lt $script:hyperFocusTasks.Count) {
        $script:hyperFocusTasks.RemoveAt($Index)
    } else {
        Write-Host "Invalid index. Please provide an index between 0 and $($script:hyperFocusTasks.Count - 1)."
    }
    Export-HyperFocusTasks -Path $script:defaultFilePath 
}

<#
.SYNOPSIS
    Gets HyperFocus tasks with optional sorting and filtering.
.DESCRIPTION
    Retrieves HyperFocus tasks and allows sorting by priority and filtering by priority or status.
.PARAMETER -SortByPriority
    Sort tasks by priority if set to 'true'.
.PARAMETER -FilterByPriority
    Filter tasks by a specific priority.
.PARAMETER -FilterByStatus
    Filter tasks by a specific status.
#>
function Get-HyperFocusTasks {
    param(
        [string]$SortByPriority,
        [string]$FilterByPriority,
        [string]$FilterByStatus
    )
    
    $Result = $script:hyperFocusTasks

    if ($FilterByPriority) {
        $Result = $script:hyperFocusTasks | Where-Object { $_.Priority -eq $FilterByPriority }
    }

    if ($SortByPriority -eq 'true') {
        $Result = $Result | Sort-Object { switch ($_.Priority) { 'High' {1} 'Medium' {2} 'Low' {3} } }
    }

    Write-Host "HyperFocus Tasks:"
    Write-Host "`n`r" # Newline for better visibility

    for ($i = 0; $i -lt $Result.Count; $i++) {
        $Color = switch ($Result[$i].Priority) {
            'High' { 'Red' }
            'Medium' { 'Yellow' }
            'Low' { 'Green' }
            default { 'White' }
        }

        $StatusSymbol = switch ($Result[$i].Status) {
            'Completed' { '✓' }
            'In Progress' { '⚙️' }
            'Not Started' { '❗' }
            'On Hold' { '⏸️' }
            default { '' }
        }

        Write-Host "`t$($i): $StatusSymbol $($Result[$i].Item) - Priority: $($Result[$i].Priority) - Due Date: $($Result[$i].DueDate) - Status: $($Result[$i].Status)" -ForegroundColor $Color
    }

    Write-Host "`n`r" # Newline for better visibility
}

<#
.SYNOPSIS
    Clears all HyperFocus tasks.
.DESCRIPTION
    Clears all HyperFocus tasks from the list.
#>
function Clear-HyperFocusTasks {
    $script:hyperFocusTasks.Clear()
}

<#
.SYNOPSIS
    Exports HyperFocus tasks to a file.
.DESCRIPTION
    Exports the current list of HyperFocus tasks to the specified file path. If the file exists, it will be overwritten.
.PARAMETER -Path
    The path to the file to export to. If the file already exists, it will be overwritten.
.EXAMPLE
    Export-HyperFocusTasks -Path "C:\Users\JohnDoe\Documents\hyperfocus_list.txt"
    Exports the current list of HyperFocus tasks to "C:\Users\JohnDoe\Documents\hyperfocus_list.txt".
#>
function Export-HyperFocusTasks {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    try {
        # Remove existing file to start fresh; ignore errors if file doesn't exist
        Remove-Item -Path $Path -ErrorAction Ignore

        # Loop through each task and append it to the file
        $script:hyperFocusTasks | ForEach-Object {
            $Line = "$($_.Item), $($_.Priority), $($_.DueDate), $($_.Status)"
            $Line | Out-File -FilePath $Path -Append
        }
    } catch {
        Write-Host "Failed to export tasks: $_"
    }
}


<#
.SYNOPSIS
    Updates a HyperFocus task by index.
.DESCRIPTION
    Updates a specific property of a HyperFocus task by the given index and exports the changes to the default file.
.PARAMETER -Index
    The index of the task to update.
.PARAMETER -Property
    The property to update ('Item', 'Priority', 'DueDate', 'Status').
.PARAMETER -Value
    The new value for the property.
.EXAMPLE
    Update-HyperFocusTask -Index 0 -Property Status -Value "In Progress"
    Updates the status of the task at index 0 to "In Progress."
.EXAMPLE
    Update-HyperFocusTask -Index 1 -Property Priority -Value High
    Updates the priority of the task at index 1 to "High."
#>
function Update-HyperFocusTask {
    param(
        [int]$Index,
        [ValidateSet('Item', 'Priority', 'DueDate', 'Status')]
        [string]$Property,
        [string]$Value
    )

    if ($Index -ge 0 -and $Index -lt $script:hyperFocusTasks.Count) {
        $script:hyperFocusTasks[$Index].$Property = $Value
        Export-HyperFocusTasks -Path $script:defaultFilePath 
    } else {
        Write-Host "Invalid index. Please provide an index between 0 and $($script:hyperFocusTasks.Count - 1)."
    }
}

<#
.SYNOPSIS
    Displays available HyperFocus commands.
.DESCRIPTION
    Shows the available HyperFocus commands and their usage.
.EXAMPLE
    Show-HyperFocusHelp
    Display this help menu.
.EXAMPLE
    Add-HyperFocusTask -Item '<item>' [-Priority] [-DueDate] [-Status]
    Add a single HyperFocus task. Priority can be High, Medium, or Low.
.EXAMPLE
    Add-HyperFocusTasks -Items '<items>' [-Priority] [-DueDate] [-Status]
    Add multiple HyperFocus tasks. Priority can be High, Medium, or Low.
.EXAMPLE
    Get-HyperFocusTasks [-SortByPriority] [-FilterByPriority] [-FilterByStatus]
    Show all HyperFocus tasks. Sort by priority or filter by priority (High, Medium, Low), and status.
.EXAMPLE
    Remove-HyperFocusTask -Index <index>
    Remove a HyperFocus task by index.
.EXAMPLE
    Update-HyperFocusTask -Index <index> -Property <property> -Value <value>
    Update a property of a HyperFocus task by index. Property can be 'Item', 'Priority', 'DueDate', 'Status'.
.EXAMPLE
    Clear-HyperFocusTasks
    Clear all HyperFocus tasks.
.EXAMPLE
    Export-HyperFocusTasks -Path '<filename>'
    Export HyperFocus tasks to a file.
.EXAMPLE
    Import-HyperFocusTasks -Path '<filename>'
    Import HyperFocus tasks from a file.
#>
function Show-HyperFocusHelp {
    Write-Host "Available commands:"
    Write-Host "`n`r" # Newline for better visibility
    
    Write-Host "`t- Add-HyperFocusTask -Item '<item>' [-Priority] [-DueDate] [-Status]"
    Write-Host "`t  Add a single HyperFocus task. Priority can be High, Medium, or Low."
    
    Write-Host "`t- Add-HyperFocusTasks -Items '<items>' [-Priority] [-DueDate] [-Status]"
    Write-Host "`t  Add multiple HyperFocus tasks. Priority can be High, Medium, or Low."
    
    Write-Host "`t- Get-HyperFocusTasks [-SortByPriority] [-FilterByPriority] [-FilterByStatus]"
    Write-Host "`t  Show all HyperFocus tasks. Sort by priority or filter by priority (High, Medium, Low), and status."
    
    Write-Host "`t- Remove-HyperFocusTask -Index <index>"
    Write-Host "`t  Remove a HyperFocus task by index."
    
    Write-Host "`t- Update-HyperFocusTask -Index <index> -Property <property> -Value <value>"
    Write-Host "`t  Update a property of a HyperFocus task by index. Property can be 'Item', 'Priority', 'DueDate', 'Status'."
    
    Write-Host "`t- Clear-HyperFocusTasks"
    Write-Host "`t  Clear all HyperFocus tasks."
    
    Write-Host "`t- Export-HyperFocusTasks -Path '<filename>'"
    Write-Host "`t  Export HyperFocus tasks to a file."
    
    Write-Host "`t- Import-HyperFocusTasks -Path '<filename>'"
    Write-Host "`t  Import HyperFocus tasks from a file."
    
    Write-Host "`t- Show-HyperFocusHelp"
    Write-Host "`t  Display this help menu."

    Write-Host "`n`r" # Newline for better visibility
}
