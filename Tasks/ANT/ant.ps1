param (
    [string]$antBuildFile,
    [string]$options,
    [string]$targets,
    [string]$jdkVersion,
    [string]$jdkArchitecture
)

Write-Verbose 'Entering Ant.ps1'
Write-Verbose "antBuildFile = $antBuildFile"
Write-Verbose "options = $options"
Write-Verbose "targets = $targets"
Write-Verbose "jdkVersion = $jdkVersion"
Write-Verbose "jdkArchitecture = $jdkArchitecture"

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

#Verify Ant build file is specified
if(!$antBuildFile)
{
    throw (Get-LocalizedString -Key "Build file parameter is not specified")
}

if($jdkVersion -and $jdkVersion -ne "default")
{
    $jdkPath = Get-JavaDevelopmentKitPath -Version $jdkVersion -Arch $jdkArchitecture
    if (!$jdkPath) 
    {
        throw (Get-LocalizedString -Key "Could not find JDK {0} {1}, please make sure the selected JDK is installed properly" -ArgumentList $jdkVersion, $jdkArchitecture)
    }

    Write-Verbose "Setting JAVA_HOME to $jdkPath"
    $env:JAVA_HOME = $jdkPath
    Write-Verbose "JAVA_HOME set to $env:JAVA_HOME"
}

Write-Verbose "Creating a new timeline for logging events"
$timeline = Start-Timeline -Context $distributedTaskContext

Write-Verbose "Running Ant..."
Invoke-Ant -AntBuildFile $antBuildFile -Options $options -Targets $targets -Timeline $timeline

Write-Verbose "Leaving script Ant.ps1"




