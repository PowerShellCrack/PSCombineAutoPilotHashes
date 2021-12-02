
<#
    .SYNOPSIS
        Searches folder for hardware hashes in csv files and
        combines them to a compatible list for Autopilot import
    .LINK

    .NOTES
    Author: Dick Tracy II
    Version: 1.0.1
#>

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
##* BUILD PATHS
##*========================================================================
#region VARIABLES: Building paths & values
# Use function to get paths because Powershell ISE & other editors have different results
[string]$scriptPath = Get-ScriptPath
[string]$scriptRoot = Split-Path -Path $scriptPath -Parent
[string]$CSVFilesPath = Join-Path -Path $scriptRoot -ChildPath 'Files'



#remove list file if found
If(Test-Path "$scriptRoot\CombinedHashes.csv" -ErrorAction SilentlyContinue){
    Remove-item "$scriptRoot\CombinedHashes.csv" -Force | Out-Null
}

If(Test-Path $CSVFilesPath)
{
    #Get all csv files, import them
    Get-ChildItem -Path $CSVFilesPath -Filter *.csv |
        #Grab the full path
        Select-Object -ExpandProperty FullName |
        #import all CSV files as an object
        Import-Csv |
        #Force all columns (even if Group tag does not exist in some csv)
        Select-Object 'Device Serial Number','Windows Product ID','Hardware Hash','Group Tag' |
        #by forcing headers, powershell quotes all values
        #convert object list to CSV; then remove the quotes
        ConvertTo-CSV -NoTypeInformation | ForEach-Object {$_ -Replace '"', ""; Write-host ("{0}" -f $_.split(',')[0])} |
        #Export the CSV content using normal output
        # Using Export-CSV will cause output to be calculated as length and not a list
        Out-File "$scriptRoot\CombinedHashes.csv" -Force -Encoding ascii
        #Export-Csv "$scriptRoot\CombinedList.csv" -NoTypeInformation -Force -Append

    Write-Host ("Combine File is located here: {0}" -f "$scriptRoot\CombinedHashes.csv") -ForegroundColor Green
}
Else{
    Write-Host ("Create a [Files] folder and copy all Autopilot csv's") -ForegroundColor Red
}
