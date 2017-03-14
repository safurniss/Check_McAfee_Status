#TODO - Error checking for registry keys - 32bit & 64 bit servers
#TODO - Documentation
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true)]
		[string]$AgentVersion,
		
	[Parameter(Mandatory=$true)]
		[string]$VScanVersion,
		
	[Parameter(Mandatory=$true)]
		[string]$EngineVersion,
		
	[Parameter(Mandatory=$true)]
		[int]$WarnDays,
		
	[Parameter(Mandatory=$true)]
		[int]$CritDays
)

# -AgentVersion 5.0.4.283 -VScanVersion 8.8.0.1599 -EngineVersion 5800.7501 -WarnDays 2 -CritDays 5

# Clear output screen - for testing
CLS

# Initialise variables
$NagiosStatus = "0"	# 0 = OK, 1 = WARNING, 2 = CRITICAL, 3 = UNKNOWN
$NagiosDescription = ""
$NagiosPerfData = "| 0;" + $WarnDays + ";" + $CritDays
$EngineStatus = "0"

# Script Functions
function Test-RegistryEntry ([string] $key, [string] $name)
{
    Get-ItemProperty -Path "$key" -Name "$name" -ErrorAction SilentlyContinue | Out-Null;
    return $?;
}

function Read-RegistryEntry ([string] $key, [string] $name)
{   
    if ( Test-RegistryEntry $key $name )
    {         
        return (Get-ItemProperty -Path $key -Name $name).$name;       
    }
    else
    {
        return '';
    }
}

$key = 'HKLM:\SOFTWARE\Wow6432Node\McAfee\AVEngine'
$name = "AVDatVersion"
$AVDatVersion = Read-RegistryEntry $key $name
if($AVDatVersion -eq '')
	{
		$key = 'HKLM:\SOFTWARE\McAfee\AVEngine'
		$AVDatVersion = Read-RegistryEntry $key $name
	}

$key = 'HKLM:\SOFTWARE\Wow6432Node\McAfee\AVEngine'
$name = "AVDatDate"
$AVDatDate = Read-RegistryEntry $key $name
if($AVDatDate -eq '')
	{
		$key = 'HKLM:\SOFTWARE\McAfee\AVEngine'
		$AVDatDate = Read-RegistryEntry $key $name
		if($AVDatDate -eq '')
			{
				$NagiosDescription = $NagiosDescription + "UNKNOWN:DAT Date "
			}
	}
else
	{
		$DateDiff = (Get-Date) - (Get-Date $AVDatDate)
	}
if($DateDiff.Days -gt $WarnDays)
	{
		$NagiosStatus = "1"
		$NagiosDescription = "DAT date (" + $AVDatDate + ") is " + $DateDiff.Days + " days old! "
		$NagiosPerfData = "| " + $DateDiff.Days + ";" + $WarnDays + ";" + $CritDays
		
		if($DateDiff.Days -gt $CritDays)
			{
				$NagiosStatus = "2"
				$NagiosDescription = "DAT date (" + $AVDatDate + ") is " + $DateDiff.Days + " days old! "
				$NagiosPerfData = "| " + $DateDiff.Days + ";" + $WarnDays + ";" + $CritDays
			}
	}

$key = 'HKLM:\SOFTWARE\Wow6432Node\McAfee\Agent'
$name = "AgentVersion"
$AgentValue = Read-RegistryEntry $key $name
if($AgentValue -eq '')
	{
		$key = 'HKLM:\SOFTWARE\McAfee\Agent'
		$AgentValue = Read-RegistryEntry $key $name
		if($AgentValue -eq '')
			{
				$NagiosDescription = $NagiosDescription + "- UNKNOWN:Agent Version "
			}
		elseif($AgentValue -ne $AgentVersion)
			{
				if($NagiosStatus -ne "2")
					{
						$NagiosStatus = "1"
						$NagiosDescription = $NagiosDescription + "- Agent Version: " + $AgentValue + " "	
					}
					
				if($NagiosStatus -eq "2")
					{
						$NagiosDescription = $NagiosDescription + "- Agent Version: " + $AgentValue + " "	
					}
			}
	}

elseif($AgentValue -ne $AgentVersion)
	{
		if($NagiosStatus -ne "2")
			{
				$NagiosStatus = "1"
				$NagiosDescription = $NagiosDescription + "- Agent Version: " + $AgentValue + " "	
			}
			
		if($NagiosStatus -eq "2")
			{
				$NagiosDescription = $NagiosDescription + "- Agent Version: " + $AgentValue + " "	
			}
	}
	

$key = 'HKLM:\SOFTWARE\Wow6432Node\McAfee\DesktopProtection'
$name = "szProductVer"
$VScanVal = Read-RegistryEntry $key $name
if($VScanVal -eq '')
	{
		$key = 'HKLM:\SOFTWARE\McAfee\DesktopProtection'
		$VScanVal = Read-RegistryEntry $key $name
		if($VScanVal -eq '')
			{
				$NagiosDescription = $NagiosDescription + "- UNKNOWN:VirusScan Version "
			}
		elseif($VScanVal -ne $VScanVersion)
			{
				if($NagiosStatus -ne "2")
					{
						$NagiosStatus = "1"
						$NagiosDescription = $NagiosDescription + "- VirusScan Version: " + $VScanVal + " "	
					}
					
				if($NagiosStatus -eq "2")
					{
						$NagiosDescription = $NagiosDescription + "- VirusScan Version: " + $VScanVal + " "	
					}
			}
	}

elseif($VScanVal -ne $VScanVersion)
	{
		if($NagiosStatus -ne "2")
			{
				$NagiosStatus = "1"
				$NagiosDescription = $NagiosDescription + "- VirusScan Version: " + $VScanVal + " "	
			}
			
		if($NagiosStatus -eq "2")
			{
				$NagiosDescription = $NagiosDescription + "- VirusScan Version: " + $VScanVal + " "	
			}
	}
	

$key = 'HKLM:\SOFTWARE\Wow6432Node\McAfee\AVEngine'
$name = "EngineVersionMajor"
$EngineMajVal = Read-RegistryEntry $key $name
if($EngineMajVal -eq '')
	{
		$key = 'HKLM:\SOFTWARE\McAfee\AVEngine'
		$EngineMajVal = Read-RegistryEntry $key $name
		if($EngineMajVal -eq '')
			{
				$EngineStatus = "1"
			}
	}

$key = 'HKLM:\SOFTWARE\Wow6432Node\McAfee\AVEngine'
$name = "EngineVersionMinor"
$EngineMinVal = Read-RegistryEntry $key $name
if($EngineMinVal -eq '')
	{
		$key = 'HKLM:\SOFTWARE\McAfee\AVEngine'
		$EngineMinVal = Read-RegistryEntry $key $name
		if($EngineMinVal -eq '')
			{
				$EngineStatus = "1"
			}
	}
if($EngineStatus -eq "0")
	{
		$EngineVal = "$EngineMajVal.$EngineMinVal"
		if($EngineVal -ne $EngineVersion)
			{	
				if($NagiosStatus -le "2")
					{
						$NagiosStatus = "1"
						$NagiosDescription = $NagiosDescription + "- Engine Version: " + $EngineVal + " "
					}
					
				elseif($NagiosStatus -eq "2")
					{
						$NagiosDescription = $NagiosDescription + "- Engine Version: " + $EngineVal + " "
					}
			}
	}
else
	{
		$NagiosStatus = "1"
		$NagiosDescription = $NagiosDescription + "- UNKNOWN:Engine Version "
	}


# Output, what level should we tell our caller?
if ($NagiosStatus -eq "3") 
	{
		Write-Host "UNKNOWN:" $NagiosDescription" "$NagiosPerfData
	} 
elseif ($NagiosStatus -eq "2") 
	{
		Write-Host "CRITICAL:" $NagiosDescription" "$NagiosPerfData
	} 
elseif ($NagiosStatus -eq "1")
	{
		Write-Host "WARNING:" $NagiosDescription" "$NagiosPerfData
	} 
else 
	{
		Write-Host "OK: DAT:" $AVDatVersion "- Agent:" $AgentValue "- VirusScan:" $VScanVal "- Engine:" $EngineVal $NagiosPerfData
	}

exit $NagiosStatus