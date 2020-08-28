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

# Maak een default handtekening in Outlook, indien deze nog niet bestaat.
# Niet overschrijven, de gebruiker zal deze aangepast hebben.
$s = "$basedir\Outlook\woonmensen.htm"
$t = "$ENV:APPDATA\Microsoft\Signatures\woonmensen.htm"
if (-not (Test-Path "$t")){
	New-Item -ItemType Directory -Force -Path "$ENV:APPDATA\Microsoft\Signatures"
	write-host "Nieuwe handtekening: $t"
	copy "$s" "$t"
}

# Word Sjablonen verversen indien aangepast:
$s = "$basedir\WordSjablonen\Startup\wm_gen.dotm"
if (test-path "$s"){
    # Source path bestaat, we bevinden ons in ons domein, copy actie starten:
    $t = "$ENV:APPDATA\Microsoft\Word\Startup\wm_gen.dotm"
    xcopy "$s" "$t" /D /Q /Y /R /C /K
    
    $s = "$basedir\WordSjablonen\Sjablonen"
    $t = "$ENV:APPDATA\Microsoft\WM-Sjablonen"
    xcopy "$s" "$t" /D /Q /Y /R /C /K /S /I
}

Stop-Transcript
