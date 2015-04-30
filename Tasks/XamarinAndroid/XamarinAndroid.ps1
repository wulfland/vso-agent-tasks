param(
    [string]$project, 
    [string]$target, 
    [string]$configuration,
    [string]$outputDir,
    [string]$msbuildLocation, 
    [string]$msbuildArguments,
    [string]$jdkVersion,
    [string]$jdkArchitecture
)

Write-Verbose "Entering script XamarinAndroid.ps1"
Write-Verbose "project = $project"
Write-Verbose "target = $target"
Write-Verbose "configuration = $configuration"
Write-Verbose "outputDir = $outputDir"
Write-Verbose "msbuildLocation = $msbuildLocation"
Write-Verbose "msbuildArguments = $msbuildArguments"
Write-Verbose "jdkVersion = $jdkVersion"
Write-Verbose "jdkArchitecture = $jdkArchitecture"

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

if (!$project)
{
    throw (Get-LocalizedString -Key "{0} parameter not set on script" -ArgumentList 'project')
}

# check for project pattern
if ($project.Contains("*") -or $project.Contains("?"))
{
    Write-Verbose "Pattern found in solution parameter. Calling Find-Files."
    Write-Verbose "Find-Files -SearchPattern $project"
    $projectFiles = Find-Files -SearchPattern $project
    Write-Verbose "projectFiles = $projectFiles"
}
else
{
    Write-Verbose "No Pattern found in project parameter."
    $projectFiles = ,$project
}

if (!$projectFiles)
{
    throw (Get-LocalizedString -Key "No project with search pattern '{0}' was found." -ArgumentList $project)
}

# construct build parameters
$timeline = Start-Timeline -Context $distributedTaskContext

$args = $msbuildArguments;

if ($configuration)
{
    Write-Verbose "adding configuration: $configuration"
    $args = "$args /p:configuration=$configuration"
}

if ($target)
{
    Write-Verbose "adding target: $target"
    $args = "$args /t:$target"
}

# Always build the APK file
Write-Verbose "adding target: PackageForAndroid"
$args = "$args /t:PackageForAndroid"

if ($outputDir) 
{
    Write-Verbose "adding OutputPath: $outputDir"
    $args = "$args /p:OutputPath=$outputDir"
}

if ($jdkVersion -and $jdkVersion -ne "default")
{
    $jdkPath = Get-JavaDevelopmentKitPath -Version $jdkVersion -Arch $jdkArchitecture
    if (!$jdkPath) 
    {
        throw (Get-LocalizedString -Key "Could not find JDK {0} {1}, please make sure the selected JDK is installed properly" -ArgumentList $jdkVersion, $jdkArchitecture)
    }

    Write-Verbose "adding JavaSdkDirectory: $jdkPath"
    $args = "$args /p:JavaSdkDirectory=`"$jdkPath`""
}

Write-Verbose "args = $args"

# build each project file
foreach ($pf in $projectFiles)
{
    Invoke-MSBuild $pf -Timeline $timeline -LogFile "$pf.log" -ToolLocation $msBuildLocation -CommandLineArgs $args
}

Write-Verbose "Leaving script XamarinAndroid.ps1"
