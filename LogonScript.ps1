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
$t = "$ENV:APPDATA\Microsoft\Signatures\woonmensen ($ENV:USERNAME@woonmensen.nl).htm"
if (-not (Test-Path "$t")){
	New-Item -ItemType Directory -Force -Path "$ENV:APPDATA\Microsoft\Signatures"
	write-host "Nieuwe handtekening: $t"
	copy "$s" "$t"
}

# Pas de verwijzing naar het plaatje in de handtekening aan, als dat nog niet gebeurd is.
# Op deze wijze overschrijven we geen persoonlijke aanpassingen.
# Per 24-06-2022 is de handtekening niet meer https://www.woonmensen.nl/maillogo, maar is het https://www.woonmensen.nl/handtekening/
$src = "$ENV:APPDATA\Microsoft\Signatures\woonmensen.htm"
$tstr = "https://www.woonmensen.nl/handtekening/"

$fstr = "https://www.woonmensen.nl/maillogo"
if ((Get-Content $src | %{$_ -match $fstr}) -contains $true) {
	write-host "De handtekening wordt gewijzigd, verwijzing naar de nieuwe publieke website"
    $s = [RegEx]::escape($fstr)
    (Get-Content $src) -replace $s,$tstr | Set-Content $src
}

# Word Sjablonen verversen indien aangepast:
$s = "$basedir\WordSjablonen\Startup\wm_gen.dotm"
if (test-path "$s"){
    # Source path bestaat, we bevinden ons in ons domein.
	# Oude sjablonen verwijderen (we gebruiken geen /MIR want we willen geen eigen sjablonen van users verwijderen:
	$oude_sjablonen = "MT\Beslisdocument MT.dotm","MT\20210708 Format voortgangsrapportage MT.dotm","MT\20210708 Format memo MT.dotm","MT\20210708 Format beslisdocument MT.dotm"
	foreach ($f in $oude_sjablonen){
		Remove-Item "$ENV:APPDATA\Microsoft\WM-Sjablonen\$f" -ErrorAction Ignore
	}
	
	# Copy actie starten:
    $t = "$ENV:APPDATA\Microsoft\Word\Startup"
	if (-not (Test-Path "$t")){
		New-Item -ItemType Directory -Force -Path "$t"
	}
    xcopy "$s" "$t" /D /Q /Y /R /C /K /I
    
    $s = "$basedir\WordSjablonen\Sjablonen"
    $t = "$ENV:APPDATA\Microsoft\WM-Sjablonen"
	if (-not (Test-Path "$t")){
		New-Item -ItemType Directory -Force -Path "$t"
	}
    xcopy "$s" "$t" /D /Q /Y /R /C /K /S /I
}

# OpenVPN instellingen kopieren:
$sd = "\\fs02\install\_Software_Woonmensen\Standaard\OpenVPN\ras.woonmensen.nl-medewerkers"
$td = "$ENV:USERPROFILE\OpenVPN\config\ras.woonmensen.nl-medewerkers"
if (test-path "$sd"){
	write-host "De OpenVPN configuratie wordt gekopieerd"
	xcopy "$sd" "$td" /D /Y /R /C /K /I
}

Stop-Transcript
