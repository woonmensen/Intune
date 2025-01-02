Start-Transcript -Path $(Join-Path $env:temp "DriveMapping.log")

$driveMappingConfig=@()

######################################################################
#                section script configuration                        #
######################################################################

<#

   Add your internal Active Directory Domain name and custom network drives below

#>

$dnsDomainName= "wm.local"

$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    DriveLetter = "F"
    UNCPath= "\\fs02\progs"
    Description="Programmas"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "G"
    UNCPath= "\\fs02\data"
    Description="Data"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "H"
    UNCPath= "\\fs02\data_alg"
    Description="Data Algemeen"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "S"
    UNCPath= "\\fs02\scans"
    Description="Scans"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "T"
    UNCPath= "\\fs3\tvb"
    Description="TVB"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "U"
    UNCPath= "\\fs02\data\PersoonlijkeMappen\$env:USERNAME"
    Description="Persoonlijke Mappen"
}

######################################################################
#               end section script configuration                     #
######################################################################

$connected=$false
$retries=0
$maxRetries=3

Write-Output "Starting script..."
do {
    
    if (Resolve-DnsName $dnsDomainName -ErrorAction SilentlyContinue){
    
        $connected=$true

    } else{
 
        $retries++
        
        Write-Warning "Cannot resolve: $dnsDomainName, assuming no connection to fileserver"
 
        Start-Sleep -Seconds 3
 
        if ($retries -eq $maxRetries){
            
            Throw "Exceeded maximum numbers of retries ($maxRetries) to resolve dns name ($dnsDomainName)"
        }
    }
 
}while( -not ($Connected))

#Remove old drives (temp)
Remove-PSDrive -Name T -Force

#Map drives
    $driveMappingConfig.GetEnumerator() | ForEach-Object {

        Write-Output "Mapping network drive $($PSItem.UNCPath)"

        New-PSDrive -PSProvider FileSystem -Name $PSItem.DriveLetter -Root $PSItem.UNCPath -Description $PSItem.Description -Persist -Scope global

        (New-Object -ComObject Shell.Application).NameSpace("$($PSItem.DriveLetter):").Self.Name=$PSItem.Description
}

Stop-Transcript
