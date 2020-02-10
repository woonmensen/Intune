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

# Verwijder overbodige ikonen van het bureaublad
Remove-Item "$env:public\Desktop\Google Chrome.lnk" -ErrorAction Ignore
Remove-Item "$env:public\Desktop\PDF-XChange Editor.lnk" -ErrorAction Ignore
Remove-Item "$env:userprofile\Desktop\Microsoft Edge.lnk" -ErrorAction Ignore

Stop-Transcript
