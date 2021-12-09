

<#
    .SYNOPSIS
        Searches folder for hardware hashes in csv files and
        combines them to a compatible list for Autopilot import
    .LINK

    .PARAMETER HashFilesPath
        Specify a folder path to the Autopilot hash files.

    .PARAMETER Append
        Adds to an existing file. WARNING: could have duplicates if same csv exist

    .PARAMETER Online
        Add hashes to Windows Autopilot via the Intune Graph API

    .EXAMPLE
        .\CombineAutopilotHashes.ps1

        RESULT: Searches in Files folder in same directory as script and builds combined list

    .EXAMPLE
        .\CombineAutopilotHashes.ps1 -HashFilesPath C:\AutopilotExports

        RESULT: Searches in C:\AutopilotExports for csv files and builds combined list

    .EXAMPLE
        .\CombineAutopilotHashes.ps1 -HashFilesPath C:\AutopilotExports -Online

        RESULT: Searches in C:\AutopilotExports for csv files, builds combined list then imports them into Autopilot devices

    .NOTES
        Author: Dick Tracy II
        Version: 2.0.0
        github: https://github.com/PowerShellCrack/PSCombineAutoPilotHashes

#>
Param(
    [String]$HashFilesPath,
    [switch]$Append,
    [switch]$Online
)
##*=============================================
##* Runtime Function - REQUIRED
##*=============================================

#region FUNCTION: Check if running in ISE
Function Test-IsISE {
    # Set-StrictMode -Version latest
    try {
        return ($null -ne $psISE);
    }
    catch {
        return $false;
    }
}
#endregion

#region FUNCTION: Check if running in Visual Studio Code
Function Test-VSCode{
    if($env:TERM_PROGRAM -eq 'vscode') {
        return $true;
    }
    Else{
        return $false;
    }
}
#endregion

#region FUNCTION: Find script path for either ISE or console
Function Get-ScriptPath {
    <#
        .SYNOPSIS
            Finds the current script path even in ISE or VSC
        .LINK
            Test-VSCode
            Test-IsISE
    #>
    param(
        [switch]$Parent
    )

    Begin{}
    Process{
        Try{
            if ($PSScriptRoot -eq "")
            {
                if (Test-IsISE)
                {
                    $ScriptPath = $psISE.CurrentFile.FullPath
                }
                elseif(Test-VSCode){
                    $context = $psEditor.GetEditorContext()
                    $ScriptPath = $context.CurrentFile.Path
                }Else{
                    $ScriptPath = (Get-location).Path
                }
            }
            else
            {
                $ScriptPath = $PSCommandPath
            }
        }
        Catch{
            $ScriptPath = '.'
        }
    }
    End{

        If($Parent){
            Split-Path $ScriptPath -Parent
        }Else{
            $ScriptPath
        }
    }

}
#endregion


##*========================================================================
##* BUILD PATHS AND VARIABLES
##*========================================================================
#region VARIABLES: Building paths & values
# Use function to get paths because Powershell ISE & other editors have different results
[string]$scriptPath = Get-ScriptPath
[string]$scriptRoot = Split-Path -Path $scriptPath -Parent
[string]$CSVFilesPath = Join-Path -Path $scriptRoot -ChildPath 'Files'

If($HashFilesPath){
    If(Test-Path $HashFilesPath -PathType Container){$CSVFilesPath = $HashFilesPath}
}

If($Append -and -Not(Test-Path "$scriptRoot\CombinedHashes.csv" -ErrorAction SilentlyContinue) ){
    #you can't append if there is non existing
    $Append = $false
}
#remove list file if found
ElseIf( (Test-Path "$scriptRoot\CombinedHashes.csv" -ErrorAction SilentlyContinue) -and !$Append){
    Remove-item "$scriptRoot\CombinedHashes.csv" -Force | Out-Null
}
##*========================================================================
##* MAIN LOGIC
##*========================================================================
$OutfileParams = @{
    Encoding='ascii'
    Append=$Append
    Force=$(!$Append)
}

If(Test-Path $CSVFilesPath)
{
    $i=0
    #Get all csv files, import them
    Get-ChildItem -literalPath $CSVFilesPath -Filter *.csv |
        #Grab the full path
        Select-Object -ExpandProperty FullName -OutVariable CSVName |
        #import all CSV files as an object
        Import-Csv |
        #Force all columns (even if Group tag does not exist in some csv)
        Select-Object 'Device Serial Number','Windows Product ID','Hardware Hash','Group Tag','Assigned User' |
        #by forcing headers, powershell quotes all values
        #convert object list to CSV
        ConvertTo-CSV -NoTypeInformation | ForEach-Object {
            #remove the quotes
            $Value = $_ -Replace '"', ""

            #out the headers but no output to screen (only if append is false; otherwise ASSUME header is already in file)
            If($Value -eq 'Device Serial Number,Windows Product ID,Hardware Hash,Group Tag,Assigned User'){
                If(!$Append){$Value}
            }
            #out the headers and to screen
            ElseIf($Value -notmatch '^,,,,$'){
                $Value
                Write-host ("Found serial number [{0}] in file [{1}]" -f $Value.split(',')[0],$CSVName[$i])
                $i++
            }
        } |
        #Export the CSV content using normal output
        # Using Export-CSV will cause output to be calculated as length and not a list

        Out-File "$scriptRoot\CombinedHashes.csv" @OutfileParams
        #Export-Csv "$scriptRoot\CombinedList.csv" -NoTypeInformation -Force -Append

    Write-Host ("Combined hashes is located in the file: {0}" -f "$scriptRoot\CombinedHashes.csv") -ForegroundColor Green
}
Else{
    Write-Host ("Create a [Files] folder and copy all Autopilot csv's to it") -ForegroundColor Red
}

#Code from Get-WindowsAutopilotInfo.ps1 with some modifications (:P)
If($Online)
{
    # Get WindowsAutopilotIntune module (and dependencies)
    $module = Import-Module WindowsAutopilotIntune -PassThru -ErrorAction Ignore
    if (-not $module) {
        Write-Host "Installing module WindowsAutopilotIntune"
        Install-Module WindowsAutopilotIntune -Force
    }
    Import-Module WindowsAutopilotIntune -Scope Global

    $graph = Connect-MSGraph
	Write-Host ("Connected to Intune tenant {0}" -f $graph.TenantId)

    # Add the devices
    $importStart = Get-Date
    $imported = @()
    Import-Csv -Path "$scriptRoot\CombinedHashes.csv" | % {
        $imported += Add-AutopilotImportedDevice -serialNumber $_.'Device Serial Number' -hardwareIdentifier $_.'Hardware Hash' -groupTag $_.'Group Tag' -assignedUser $_.'Assigned User'
    }

    # Wait until the devices have been imported
    $deviceCount = $imported.Length

    $processingCount = 1
    while ($processingCount -gt 0)
    {
        $current = @()
        #set back to zero
        $processingCount = 0
        #check device state (add to process count if impoting still)
        $imported | % {
            $device = Get-AutopilotImportedDevice -id $_.id
            if ($device.state.deviceImportStatus -eq "unknown") {
                $processingCount = $processingCount + 1
            }
            $current += $device
        }
        if ($processingCount -gt 0){
            Write-Host ("Waiting for {0} of {1} to be imported" -f $processingCount,$deviceCount)
            Start-Sleep 30
        }
    }
    $importDuration = (Get-Date) - $importStart
    $importSeconds = [Math]::Ceiling($importDuration.TotalSeconds)
    $successCount = 0
    $current | % {
        If($device.state.deviceErrorCode -eq 0){
            Write-Host ("{0}: {1}; Exitcode:{2}" -f $device.serialNumber, $device.state.deviceImportStatus, $device.state.deviceErrorCode, $device.state.deviceErrorName) -ForegroundColor Green
        }Else{
            Write-Host ("{0}: {1}; Exitcode:{2} - {3}" -f $device.serialNumber, $device.state.deviceImportStatus, $device.state.deviceErrorCode, $device.state.deviceErrorName) -ForegroundColor Red
        }

        if ($device.state.deviceImportStatus -eq "complete") {
            $successCount = $successCount + 1
        }
    }
    Write-Host ("{0} devices imported successfully.  Elapsed time to complete import: {1} seconds" -f $successCount,$importSeconds)

    # Wait until the devices can be found in Intune (should sync automatically)
    $syncStart = Get-Date
    $processingCount = 1
    while ($processingCount -gt 0)
    {
        $autopilotDevices = @()
        $processingCount = 0
        $current | % {
            if ($device.state.deviceImportStatus -eq "complete") {
                $device = Get-AutopilotDevice -id $_.state.deviceRegistrationId
                if (-not $device) {
                    $processingCount = $processingCount + 1
                }
                $autopilotDevices += $device
            }
        }
        $deviceCount = $autopilotDevices.Length
        Write-Host ("Waiting for {0} of {1} to be synced" -f $processingCount,$deviceCount)
        if ($processingCount -gt 0){
            Start-Sleep 30
        }
    }
    $syncDuration = (Get-Date) - $syncStart
    $syncSeconds = [Math]::Ceiling($syncDuration.TotalSeconds)
    Write-Host ("All devices synced.  Elapsed time to complete sync: {0} seconds" -f $syncSeconds)

}
