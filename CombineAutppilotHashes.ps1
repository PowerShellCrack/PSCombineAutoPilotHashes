
##*========================================================================
##* BUILD PATHS
##*========================================================================

#Get all csv files, import them
Get-ChildItem -Path "$PSScriptRoot\Files" -Filter *.csv |
    Select-Object -ExpandProperty FullName |
    Import-Csv |
    Export-Csv "$PSScriptRoot\Files\CombinedList.csv" -NoTypeInformation -Append
