

<#
    .SYNOPSIS
        Searches folder for hardware hashes in csv files and
        combines them to a compatible list for Autopilot import
    .LINK

    .PARAMETER HashFilesPath
        Specify a folder path to the Autopilot hash files.

    .PARAMETER Append
        Adds to an existing file. WARNING: could have duplicates if same csv exist

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
        Version: 2.0.1
        github: https://github.com/PowerShellCrack/PSCombineAutoPilotHashes

#>
Param(
    [ValidateScript({Test-Path $_ -PathType Container})]
    [String]$HashFilesPath,
    [switch]$Append
)
##*=============================================
##* Runtime Function - REQUIRED
##*=============================================



##*========================================================================
##* BUILD PATHS AND VARIABLES
##*========================================================================
#region VARIABLES: Building paths & values
# get paths because PowerShell ISE & other editors have different results
[string]$ScriptPath = ($PWD.ProviderPath, $PSScriptRoot)[[bool]$PSScriptRoot]

#overwrite default path if specified and found
If($HashFilesPath){
    $CSVFilesPath = $HashFilesPath
}Else{
    [string]$CSVFilesPath = Join-Path -Path $ScriptPath -ChildPath 'Files'
}

If($Append -and -Not(Test-Path "$ScriptPath\CombinedHashes.csv" -ErrorAction SilentlyContinue) ){
    #you can't append if there is not a file that exists existing
    $Append = $false
}
#remove list file if found
ElseIf( (Test-Path "$ScriptPath\CombinedHashes.csv" -ErrorAction SilentlyContinue) -and !$Append){
    Remove-item "$ScriptPath\CombinedHashes.csv" -Force | Out-Null
}
##*========================================================================
##* MAIN LOGIC
##*========================================================================
$OutfileParams = @{
    Encoding=[System.Text.Encoding]::ASCII
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

        Out-File "$ScriptPath\CombinedHashes.csv" @OutfileParams
        #Export-Csv "$ScriptPath\CombinedList.csv" -NoTypeInformation -Force -Append

    Write-Host ("Combined hashes is located in the file: {0}" -f "$ScriptPath\CombinedHashes.csv") -ForegroundColor Green
}
Else{
    Write-Host ("Files folder [{0}] does not exist" -f $CSVFilesPath) -ForegroundColor Red
    Write-Host (" 1. Create the [Files folder] or use parameter [-HashFilesPath `"<path to folder>`"]") -ForegroundColor Red
    Write-Host (" 2. Copy all Autopilot csv's to it") -ForegroundColor Red
    Write-Host (" 3. Rerun the script") -ForegroundColor Red
}
