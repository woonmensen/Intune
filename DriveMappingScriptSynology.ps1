Start-Transcript -Path $(Join-Path $env:temp "DriveMappingSynology.log")
Write-Output "Mapping network drive P to Synology home directory"

$parameters = @{
    Name = "WM Cloud"
    PSProvider = "FileSystem"
    Root = "\\wmhome\home"
    Description = "Persoonlijke WM Cloud opslag."
}
New-PSDrive @parameters

Stop-Transcript