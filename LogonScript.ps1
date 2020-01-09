Start-Transcript -Path $(Join-Path $env:temp "LogonScript.log")

$basedir = "\\fs02\install\_Intune"

######################################################################
#                reg files inlezen                                   #
######################################################################

$regdir = "$basedir\Regfiles\HKCU\*"
$files = Get-ChildItem "$regdir" -Include "*.reg"
foreach ($file in $files) {
    $out = Invoke-Command {reg import "$file" 2>&1}
    write-host "Reg Import $file : $out"
}

Stop-Transcript
