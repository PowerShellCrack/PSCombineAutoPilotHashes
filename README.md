# PSCombineAutopilotHashes

This is a simple script that will Combine multiple Autopilot Exported csv files into a single Autopilot list to be imported into Autopilot Devices

## Parameters

- **HashFilesPath** --> Specify a folder path to the Autopilot hash files.
- **Append** -->Adds to an existing file. 



## How to use

1. Download Repo
2. Copy all csv files to __Files__ folder
2. run _CombineAutopilotHashes.ps1_ using  PowerShell

```powershell
    PS> .\CombineAutopilotHashes.ps1
 ```
> RESULT: Searches in Files folder in same directory as script and builds combined list

```powershell
    PS> .\CombineAutopilotHashes.ps1 -HashFilesPath C:\AutopilotExports
 ```
> RESULT: Searches in C:\AutopilotExports for csv files and builds combined list

 ```powershell
    PS> .\CombineAutopilotHashes.ps1 -HashFilesPath C:\AutopilotExports -Append
 ```
> RESULT: Searches in C:\AutopilotExports for csv files, and imports existing combined list and adds more entries
> WARNING: This could have duplicates if same csv exist (don't use -Append if that is the case)

3. Import _CombinedHashes.csv_ to Autopilot devices (if _Online_ parameter is not used)


## Output

Script will output a _CombinedHashes.csv_ file in root. Use this to import device intune using the WindowsAutopilotIntune module

 ```powershell
Install-Module  WindowsAutopilotIntune -MinimumVersion 5.3 -Scope AllUsers
Connect-MgGraph
Import-AutopilotCSV -csvFile .\CombinedHashes.csv
 ```

## TODO

- check what is already imported and only import new
- A UI that will show all imports

# DISCLAIMER
> Even though I have tested this to the extend that I could I want to ensure your aware of Microsoft’s position on developing scripts.

This Sample Code is provided for the purpose of illustration only and is not
intended to be used in a production environment.  THIS SAMPLE CODE AND ANY
RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a
nonexclusive, royalty-free right to use and modify the Sample Code and to
reproduce and distribute the object code form of the Sample Code, provided
that You agree: (i) to not use Our name, logo, or trademarks to market Your
software product in which the Sample Code is embedded; (ii) to include a valid
copyright notice on Your software product in which the Sample Code is embedded;
and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and
against any claims or lawsuits, including attorneys’ fees, that arise or result
from the use or distribution of the Sample Code.

This posting is provided "AS IS" with no warranties, and confers no rights. Use
of included script samples are subject to the terms specified
at https://www.microsoft.com/en-us/legal/copyright.
