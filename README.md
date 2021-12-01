# PSCombineAutopilotHashes

This is a simple script that will Combine multiple Autopilot Exported csv files into a single Autopilot list to be imported into Autopilot Devices

## How to use

1. Copy all csv files to __File__ folder
2. Run use PowerShell

```powershell
    .\CombineAutopilotHashes.ps1
```

3. Import _CombinedHashes.csv_ to Autopilot devices

## TODO / ISSUES

- Group tag support. If the first CSV does not have a group tag, then all are ignored
- Intune (MS graph) support; auto imports devices automatically
- UI; launch UI to browse for path
- Progress bar for status
