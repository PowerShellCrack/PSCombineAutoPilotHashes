# PSCombineAutopilotHashes

This is a simple script that will Combine multiple Autopilot Exported csv files into a single Autopilot list to be imported into Autopilot Devices

## How to use

1. Copy all csv files to Files folder
2. Run

```powershell
    .\CombineAutopilotHashes.ps1
```

3. Import CombinedHashes.csv to Autopilot devices

## TODO / ISSUES

- Group tag support. If the first CSV does nto have a group tag, then all are ignored
- UI; launch UI to browse for path
- Intune (MS graph) support.
