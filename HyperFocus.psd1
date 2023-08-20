#
# Module manifest for module 'HyperFocus'
#

@{

    # Script module or binary module file associated with this manifest
    RootModule = 'HyperFocus.psm1'

    # Version number of this module
    ModuleVersion = '0.1.0-alpha'

    # ID used to uniquely identify this module
    GUID = '371f06fe-17a9-45ad-8323-71283c230e2a'

    # Author of this module
    Author = 'Trent Johnson'

    # Copyright statement for this module
    Copyright = '(c) Trent Johnson. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'HyperFocus task management module'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @('Add-HyperFocusTask', 'Add-HyperFocusTasks', 'Remove-HyperFocusTask', 'Get-HyperFocusTasks', 'Clear-HyperFocusTasks', 'Export-HyperFocusTasks', 'Import-HyperFocusTasks', 'Update-HyperFocusStatus', 'Show-HyperFocusHelp')

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('HyperFocus', 'TaskManagement')

            # A URL to the license for this module.
            LicenseUri = 'https://opensource.org/licenses/MIT'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/ludothegreat/HyperFocus'

            # ReleaseNotes of this module
            ReleaseNotes = 'Initial release of HyperFocus'

        } # End of PSData hashtable

    } # End of PrivateData hashtable

} # End of manifest hashtable
