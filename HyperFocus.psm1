# Default file path for the to-do list
$script:defaultFilePath = Join-Path $env:USERPROFILE 'hyperfocus_list.txt'

# Initialize the hyperFocusTasks list as an empty ArrayList if the default file does not exist
$script:hyperFocusTasks = if (Test-Path -Path $script:defaultFilePath) {
    Import-HyperFocusTasks $script:defaultFilePath
} else {
    New-Object System.Collections.ArrayList
}

<#
.SYNOPSIS
    Adds a HyperFocus task.
.DESCRIPTION
    Creates and adds a HyperFocus task with the provided details and exports it to the default file.
.PARAMETER item
    The description of the task.
.PARAMETER priority
    The priority of the task. Default is 'Medium'.
.PARAMETER dueDate
    The due date for the task. Optional.
.PARAMETER status
    The status of the task. Default is 'Not Started'.
#>
function Add-HyperFocusTask {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$item,

        [ValidateSet('High', 'Medium', 'Low')]
        [string]$priority = 'Medium', 

        [string]$dueDate = $null,      

        [ValidateSet('Not Started', 'In Progress', 'On Hold', 'Completed', 'Cancelled')]
        [string]$status = 'Not Started' 
    )

    $hyperfocus = New-Object PSObject -Property @{
        'Item' = $item
        'Priority' = $priority
        'DueDate' = $dueDate
        'Status' = $status
    }
    $script:hyperFocusTasks.Add($hyperfocus) | Out-Null
    Export-HyperFocusTasks $script:defaultFilePath 
}

<#
.SYNOPSIS
    Adds multiple HyperFocus tasks.
.DESCRIPTION
    Creates and adds multiple HyperFocus tasks with the provided details and exports them to the default file.
.PARAMETER items
    An array of descriptions for the tasks.
.PARAMETER priority
    The priority of the tasks. Default is 'Medium'.
.PARAMETER dueDate
    The due date for the tasks. Optional.
.PARAMETER status
    The status of the tasks. Default is 'Not Started'.
#>
function Add-HyperFocusTasks {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$items,

        [ValidateSet('High', 'Medium', 'Low')]
        [string]$priority = 'Medium',

        [string]$dueDate = $null,      

        [ValidateSet('Not Started', 'In Progress', 'On Hold', 'Completed', 'Cancelled')]
        [string]$status = 'Not Started' 
    )

    # Create and add HyperFocus tasks for each item
    $items | ForEach-Object {
        $hyperfocus = New-Object PSObject -Property @{
            'Item' = $_
            'Priority' = $priority
            'DueDate' = $dueDate
            'Status' = $status
        }
        $script:hyperFocusTasks.Add($hyperfocus) | Out-Null
    }
    Export-HyperFocusTasks $script:defaultFilePath 
}

<#
.SYNOPSIS
    Removes a HyperFocus task by index.
.DESCRIPTION
    Removes a HyperFocus task by the given index and exports the changes to the default file.
.PARAMETER index
    The index of the task to remove.
#>
function Remove-HyperFocusTask {
    param([int]$index)
    if ($index -ge 0 -and $index -lt $script:hyperFocusTasks.Count) {
        $script:hyperFocusTasks.RemoveAt($index)
    } else {
        Write-Host "Invalid index. Please provide an index between 0 and $($script:hyperFocusTasks.Count - 1)."
    }
    Export-HyperFocusTasks $script:defaultFilePath 
}

<#
.SYNOPSIS
    Gets HyperFocus tasks with optional sorting and filtering.
.DESCRIPTION
    Retrieves HyperFocus tasks and allows sorting by priority and filtering by priority or status.
.PARAMETER sortByPriority
    Sort tasks by priority if set to 'true'.
.PARAMETER filterByPriority
    Filter tasks by a specific priority.
.PARAMETER filterByStatus
    Filter tasks by a specific status.
#>
function Get-HyperFocusTasks {
    param(
        [string]$sortByPriority,
        [string]$filterByPriority,
        [string]$filterByStatus
    )
    
    $result = $script:hyperFocusTasks

    if ($filterByPriority) {
        $result = $script:hyperFocusTasks | Where-Object { $_.Priority -eq $filterByPriority }
    }

    if ($sortByPriority -eq 'true') {
        $result = $result | Sort-Object { switch ($_.Priority) { 'High' {1} 'Medium' {2} 'Low' {3} } }
    }

    for ($i = 0; $i -lt $result.Count; $i++) {
        $color = switch ($result[$i].Priority) {
            'High' { 'Red' }
            'Medium' { 'Yellow' }
            'Low' { 'Green' }
            default { 'White' }
        }

        $statusSymbol = switch ($result[$i].Status) {
            'Completed' { '✓' }
            'In Progress' { '⚙️' }
            'Not Started' { '❗' }
            'On Hold' { '⏸️' }
            default { '' }
        }
        Write-Host "$($i): $statusSymbol $($result[$i].Item) - Priority: $($result[$i].Priority) - Due Date: $($result[$i].DueDate) - Status: $($result[$i].Status)" -ForegroundColor $color
    }
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
    Exports all HyperFocus tasks to the specified filename.
.PARAMETER filename
    The name of the file to export to.
#>
function Export-HyperFocusTasks {
    param([string]$filename)
    Remove-Item -Path $filename -ErrorAction Ignore 
    $script:hyperFocusTasks | ForEach-Object {
        "$($_.Item), $($_.Priority), $($_.DueDate), $($_.Status)" | Out-File -FilePath $filename -Append
    }
}

<#
.SYNOPSIS
    Imports HyperFocus tasks from a file.
.DESCRIPTION
    Imports HyperFocus tasks from the specified filename.
.PARAMETER filename
    The name of the file to import from.
#>
function Import-HyperFocusTasks {
    param([string]$filename)
    $content = Get-Content -Path $filename
    $content = @($content) 
    $script:hyperFocusTasks = New-Object System.Collections.ArrayList
    $content | ForEach-Object {
        $item, $priority, $dueDate, $status = $_.Split(',').Trim()
        $hyperfocus = New-Object PSObject -Property @{
            'Item' = $item
            'Priority' = $priority
            'DueDate' = $dueDate
            'Status' = $status
        }
        $script:hyperFocusTasks.Add($hyperfocus) | Out-Null
    }
}

<#
.SYNOPSIS
    Updates the status of a HyperFocus task by index.
.DESCRIPTION
    Updates the status of a HyperFocus task by the given index and exports the changes to the default file.
.PARAMETER index
    The index of the task to update.
.PARAMETER status
    The new status for the task.
#>
function Update-HyperFocusStatus {
    param(
        [int]$index,
        [string]$status
    )

    $validStatuses = 'Not Started', 'In Progress', 'On Hold', 'Completed', 'Cancelled'

    if ($validStatuses -notcontains $status) {
        Write-Host "Invalid status. Please choose one of the following: $($validStatuses -join ', ')"
        return
    }

    if ($index -ge 0 -and $index -lt $script:hyperFocusTasks.Count) {
        $script:hyperFocusTasks[$index].Status = $status
        Export-HyperFocusTasks $script:defaultFilePath 
    } else {
        Write-Host "Invalid index. Please provide an index between 0 and $($script:hyperFocusTasks.Count - 1)."
    }
}

# Default file path for the to-do list
$script:defaultFilePath = Join-Path $env:USERPROFILE 'hyperfocus_list.txt'

# Initialize the to-do list as an empty ArrayList if the default file does not exist
$script:hyperFocusTasks = New-Object System.Collections.ArrayList

# Check if the default file path exists
if (Test-Path -Path $script:defaultFilePath) {
    Import-HyperFocusTasks $script:defaultFilePath
} else {
    $script:hyperFocusTasks = New-Object System.Collections.ArrayList
}

<#
.SYNOPSIS
    Displays available HyperFocus commands.
.DESCRIPTION
    Shows the available HyperFocus commands and their usage.
#>
function Show-HyperFocusHelp {
    "Available commands:"
    "Add-HyperFocusTask '<item>' [priority] [dueDate] [status] - Add a HyperFocus task (enclose item in quotes). Priority can be High, Medium, or Low."
    "Get-HyperFocusTasks [sortByPriority] [filterByPriority] [filterByStatus] - Show all HyperFocus tasks. Sort by priority or filter by priority (High, Medium, Low), and status."
    "Remove-HyperFocusTask <index> - Remove a HyperFocus task by index."
    "Update-HyperFocusStatus <index> <status> - Update the status of a HyperFocus task by index. Status can be Not Started, In Progress, On Hold, Completed, or Cancelled."
    "Clear-HyperFocusTasks - Clear all HyperFocus tasks."
    "Export-HyperFocusTasks '<filename>' - Export HyperFocus tasks to a file."
    "Import-HyperFocusTasks '<filename>' - Import HyperFocus tasks from a file."
    "Show-HyperFocusHelp - Display this help menu."
}
