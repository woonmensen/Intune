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

# Pas de verwijzing naar het plaatje in de handtekening aan, als dat nog niet gebeurd is.
# Op deze wijze overschrijven we geen persoonlijke aanpassingen.
$src = "$ENV:APPDATA\Microsoft\Signatures\woonmensen.htm"
$fstr = "http://home.woonmensen.nl/woonmensen.png"
$tstr = "https://www.woonmensen.nl/media/1112/handtekening.png"

if ((Get-Content $src | %{$_ -match $fstr}) -contains $true) {
	write-host "De handtekening wordt gewijzigd, verwijzing naar de publieke website"
    $s = [RegEx]::escape($fstr)
    (Get-Content $src) -replace $s,$tstr | Set-Content $src
}

# Word Sjablonen verversen indien aangepast:
$s = "$basedir\WordSjablonen\Startup\wm_gen.dotm"
if (test-path "$s"){
    # Source path bestaat, we bevinden ons in ons domein, copy actie starten:
    $t = "$ENV:APPDATA\Microsoft\Word\Startup"
    xcopy "$s" "$t" /D /Q /Y /R /C /K /I
    
    $s = "$basedir\WordSjablonen\Sjablonen"
    $t = "$ENV:APPDATA\Microsoft\WM-Sjablonen"
    xcopy "$s" "$t" /D /Q /Y /R /C /K /S /I
}

Stop-Transcript
