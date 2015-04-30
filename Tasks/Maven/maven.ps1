param (
    [string]$mavenPOMFile,
    [string]$options,
    [string]$goals,
    [string]$jdkVersion,
    [string]$jdkArchitecture
)

Write-Verbose 'Entering Maven.ps1'
Write-Verbose "mavenPOMFile = $mavenPOMFile"
Write-Verbose "options = $options"
Write-Verbose "goals = $goals"
Write-Verbose "jdkVersion = $jdkVersion"
Write-Verbose "jdkArchitecture = $jdkArchitecture"

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

#Verify Maven POM file is specified
if(!$mavenPOMFile)
{
    throw (Get-LocalizedString -Key "Maven POM file is not specified")
}

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

if($jdkVersion -and $jdkVersion -ne "default")
{
    $jdkPath = Get-JavaDevelopmentKitPath -Version $jdkVersion -Arch $jdkArchitecture
    if (!$jdkPath) 
    {
        throw (Get-LocalizedString -Key "Could not find JDK {0} {1}, please make sure the selected JDK is installed properly" -ArgumentList $jdkVersion, $jdkArchitecture)
    }

    Write-Host (Get-LocalizedString -Key "Setting {0} to {1}" -ArgumentList 'JAVA_HOME', $jdkPath)
    $env:JAVA_HOME = $jdkPath
    Write-Verbose "JAVA_HOME set to $env:JAVA_HOME"
}

Write-Verbose "Creating a new timeline for logging events"
$timeline = Start-Timeline -Context $distributedTaskContext

Write-Verbose "Running Maven..."
Invoke-Maven -MavenPomFile $mavenPOMFile -Options $options -Goals $goals -Timeline $timeline

Write-Verbose "Leaving script Maven.ps1"




