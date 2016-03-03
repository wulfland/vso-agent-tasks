param (
    [string]$workingDirectory,
    [string]$script,    
    [string]$codeCoverage,
    [string]$OutputFile
    )

Write-Verbose "Entering script RunPesterTests.ps1" -Verbose
Write-Verbose "workingDirectory = $workingDirectory" -Verbose
Write-Verbose "script = $script" -Verbose
Write-Verbose "codeCoverage = $codeCoverage" -Verbose
Write-Verbose "OutputFile = $OutputFile" -Verbose

import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

$ErrorActionPreference = "Stop"

$tempDir = $env:TEMP

$modulePath = Join-Path $tempDir Pester-master\Pester.psm1

if (-not(Test-Path $modulePath)) {
    Write-Verbose "Pester module not found. Download it from 'https://github.com/pester/Pester/archive/master.zip'." -Verbose   
    
	# Note: PSGet and chocolatey are not supported in hosted vsts build agent  
    $tempFile = Join-Path $TempDir pester.zip
    Invoke-WebRequest https://github.com/pester/Pester/archive/master.zip -OutFile $tempFile
    
    [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
    [System.IO.Compression.ZipFile]::ExtractToDirectory($tempFile, $tempDir)
    
    Remove-Item $tempFile
    
    Write-Verbose "Done." -Verbose  
}

Import-Module $modulePath -DisableNameChecking

$scripts = @()

# check for script pattern
if ($script.Contains("*") -Or $script.Contains("?"))
{
    Write-Verbose "Pattern found in script parameter. Calling Find-Files."
    Write-Verbose "Calling Find-Files with pattern: $script"    
    $scripts = Find-Files -SearchPattern $script -RootFolder $workingDirectory
    Write-Verbose "Found files: $scripts"
}
else
{
    Write-Verbose "No Pattern found in script parameter."
    $script = $script.Replace(';;', "`0") # Barrowed from Legacy File Handler
    foreach ($scriptFile in $script.Split(";"))
    {
        $scripts += ,($scriptFile.Replace("`0",";"))
    }
}

$coverageFiles = @()

# check for script pattern
if ($codeCoverage.Contains("*") -Or $codeCoverage.Contains("?"))
{
    Write-Verbose "Pattern found in codeCoverage parameter. Calling Find-Files."
    Write-Verbose "Calling Find-Files with pattern: $codeCoverage"    
    $coverageFiles = Find-Files -SearchPattern $codeCoverage -RootFolder $workingDirectory
    Write-Verbose "Found files: $coverageFiles"
}
else
{
    Write-Verbose "No Pattern found in codeCoverage parameter."
    $codeCoverage = $codeCoverage.Replace(';;', "`0") # Barrowed from Legacy File Handler
    foreach ($file in $codeCoverage.Split(";"))
    {
        $coverageFiles += ,($file.Replace("`0",";"))
    }
}

$result = Invoke-Pester -script $scripts -CodeCoverage $coverageFiles -PassThru -OutputFile $outputFile -OutputFormat NUnitXml -EnableExit

$result


Write-Verbose "Leaving script RunPesterTests.ps1" -Verbose