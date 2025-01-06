Start-Transcript -Path $(Join-Path $env:temp "DriveMapping.log")

$driveMappingConfig=@()

######################################################################
#                section script configuration                        #
######################################################################

<#

   Add your internal Active Directory Domain name and custom network drives below

#>

$dnsDomainName= "wm.local"

if ( Test-Path \\fs3\install\f_fs3.txt ) {
	$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    		DriveLetter = "F"
    		UNCPath= "\\fs3\progs"
    		Description="Programmas"
	}
} else {
	$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    		DriveLetter = "F"
    		UNCPath= "\\fs02\progs"
    		Description="Programmas"
	}
}

if ( Test-Path \\fs3\install\g_fs3.txt ) {
	$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
		DriveLetter = "G"
		UNCPath= "\\fs3\data"
		Description="Data"
	}
} else {
	$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
	    DriveLetter = "G"
	    UNCPath= "\\fs02\data"
	    Description="Data"
	}
}

if ( Test-Path \\fs3\install\h_fs3.txt ) {
	$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
	    DriveLetter = "H"
	    UNCPath= "\\fs3\data_alg"
	    Description="Data Algemeen"
	}
} else {
	$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
	    DriveLetter = "H"
	    UNCPath= "\\fs02\data_alg"
	    Description="Data Algemeen"
	}
}

if ( Test-Path \\fs3\install\s_fs3.txt ) {
	$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
	    DriveLetter = "S"
	    UNCPath= "\\fs3\scans"
	    Description="Scans"
	}
} else {
	$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
	    DriveLetter = "S"
	    UNCPath= "\\fs02\scans"
	    Description="Scans"
	}
}

if ( Test-Path \\fs3\install\t_fs3.txt ) {
	$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
	    DriveLetter = "T"
	    UNCPath= "\\fs3\tvb"
	    Description="TVB"
	}
} else {
	$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
	    DriveLetter = "T"
	    UNCPath= "\\fs02\tvb"
	    Description="TVB"
	}
}

if (Test-Path \\fs3\install\u_fs3.txt) {
	$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
	    DriveLetter = "U"
	    UNCPath= "\\fs3\data\PersoonlijkeMappen\$env:USERNAME"
	    Description="Persoonlijke Mappen"
	}
} else {
	$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
	    DriveLetter = "U"
	    UNCPath= "\\fs02\data\PersoonlijkeMappen\$env:USERNAME"
	    Description="Persoonlijke Mappen"
	}
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

#Remove old mappings
Write-Output "smb mappings:"
Get-SmbMapping
Write-Output "Removing obsolete mappings"
Get-SmbMapping | Remove-SmbMapping -Force
#Get-SmbMapping | Where-Object { $_.RemotePath -eq '\\fs02\tvb' } | Remove-SmbMapping -Force
Get-SmbMapping

#Map drives
$driveMappingConfig.GetEnumerator() | ForEach-Object {

        Write-Output "Mapping network drive $($PSItem.UNCPath)"

        New-PSDrive -PSProvider FileSystem -Name $PSItem.DriveLetter -Root $PSItem.UNCPath -Description $PSItem.Description -Persist -Scope global

        (New-Object -ComObject Shell.Application).NameSpace("$($PSItem.DriveLetter):").Self.Name=$PSItem.Description
}

Stop-Transcript
