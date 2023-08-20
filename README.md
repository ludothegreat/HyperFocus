![HyperFocus Logo](logo.png)
# HyperFocus Task Management

A PowerShell script to manage tasks using a "HyperFocus" system. Keep track of tasks, priorities, due dates, and statuses.

## Features

- Add, update, remove, and list HyperFocus tasks.
- Filter and sort tasks by priority and status.
- Export and import tasks to/from a file.

## Usage

You can perform various operations using the following commands:

### Add a new HyperFocus task
```powershell
Add-HyperFocusTask 'Finish the report' 'High' '2023-09-01' 'Not Started'
```

### Get all HyperFocus tasks
```powershell
Get-HyperFocusTasks
```

### Remove a HyperFocus task by index
```powershell
Remove-HyperFocusTask 0
```

### Show help
```powershell
Show-HyperFocusHelp
```

## Dependencies

No specific dependencies. Compatible with PowerShell v5.0 and above.

## Installation

Clone the repository or download the script to your local machine. Run the script using PowerShell.

## Contributing

Please read CONTRIBUTING.md for details on how to contribute to this project.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.
