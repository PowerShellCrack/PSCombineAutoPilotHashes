# PSCombineAutopilotHashes

This is a simple script that will Combine multiple Autopilot Exported csv files into a single Autopilot list to be imported into Autopilot Devices

## How to use

1. Copy all csv files to __File__ folder
2. Run use PowerShell

```powershell
    <#
    .SYNOPSIS
        Searches folder for hardware hashes in csv files and
        combines them to a compatible list for Autopilot import

    .PARAMETER HashFilesPath
        Specify a folder path to the Autopilot hash files.

    .PARAMETER Append
        Adds to an existing file. WARNING: could have duplicates if same csv exist

    .PARAMETER Online
        Add computers to Windows Autopilot via the Intune Graph API

    .EXAMPLE
        .\CombineAutopilotHashes.ps1

        RESULT: Searches in Files folder in same directory as script and builds combined list

    .EXAMPLE
        .\CombineAutopilotHashes.ps1 -HashFilesPath C:\AutopilotExports

        RESULT: Searches in C:\AutopilotExports for csv files and builds combined list

    .EXAMPLE
        .\CombineAutopilotHashes.ps1 -HashFilesPath C:\AutopilotExports -Online

        RESULT: Searches in C:\AutopilotExports for csv files, builds combined list then imports them into Autopilot devices
    #>
```

3. Import _CombinedHashes.csv_ to Autopilot devices (if _Online_ parameter is not used)

## TODO / ISSUES

- UI; launch UI to browse for path
- Progress bar for status
