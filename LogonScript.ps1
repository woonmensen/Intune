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
if (-not (Test-Path "$env:userprofile\Application Data\Microsoft\Handtekeningen\woonmensen.htm")){
	write-host "Nieuwe handtekening wordt gekopieerd"
	copy "$s" "$env:userprofile\Application Data\Microsoft\Handtekeningen\woonmensen.htm"
	copy "$s" "$env:userprofile\Application Data\Microsoft\Signatures\woonmensen.htm"
}

Stop-Transcript
