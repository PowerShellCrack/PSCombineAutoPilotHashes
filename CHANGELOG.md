# Change log for PSCombineAutopilotHashes.ps1

## 2.0.1 -July 5, 2023

- Updated script root check; Updated output if errors
- Removed Online Function; use **Import-AutopilotCSV** from _WidowsAutopilotIntune_ module instead
- Added Pester unit testing for local tests
- Updated README.md

## 2.0.0 -December 8, 2021

- Added cleaner output; removed header as a output and added file used
- Added _HashFilesPath_ parameter to allow custom path searches
- Added _Append_ parameter; in case multiple paths are combined; it does not check for same hashes.
- Added _Online_ parameter; code taken from Get-WindowsAutopilotInfo.ps1 with modifications
- Added _Assigned User_ column to headers; can be added when running _Get-WindowsAutopilotInfo.ps1 -AssignedUser user@domain_
- Added LICENSE to git repo
- renamed to PSCombineAutopilotHashes.ps1

## 1.0.1 -December 1, 2021

- Added addition functions to check path; incase script is ran in ISE
- Removed CombineHashes.csv if found; script would append to current list otherwise
- Added "Group Tag" support; Enforce Header selection even if does not exist in some csv
- Added Output to see status

## 1.0.0 - November 30, 2021

- initial build
