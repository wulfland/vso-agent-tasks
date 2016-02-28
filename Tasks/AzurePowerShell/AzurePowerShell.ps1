Trace-VstsEnteringInvocation $MyInvocation

<#
ENDPOINT_AUTH_ED6BA75E-EF4F-4306-9F3E-270DC5F43F01 {"parameters":{"certificate":"..."},"scheme":"Certificate"}
ENDPOINT_URL_ED6BA75E-EF4F-4306-9F3E-270DC5F43F01 https://management.core.windows.net/
INPUT_CONNECTEDSERVICENAME ed6ba75e-ef4f-4306-9f3e-270dc5f43f01
INPUT_CONNECTEDSERVICENAMEARM
INPUT_CONNECTEDSERVICENAMESELECTOR ConnectedServiceName
INPUT_SCRIPTARGUMENTS
INPUT_SCRIPTPATH c:\temp\azurepowershell.ps1
#>

# Get inputs.
$scriptPath = Get-VstsInput -Name ScriptPath -Require
$scriptArguments = Get-VstsInput -Name ScriptArguments

# Validate the script path and args do not contains new-lines. Otherwise, it will
# break invoking the script via Invoke-Expression.
if ($scriptPath -match '^[^\r\n]*$') {
    throw (Get-VstsLocString -Key InvalidScriptPath0 -ArgumentList $scriptPath)
}

if ($scriptArguments -match '^[^\r\n]*$') {
    throw (Get-VstsLocString -Key InvalidScriptArguments0 -ArgumentList $scriptPath)
}

# Initialize Azure.
Import-Module $PSScriptRoot\ps_modules\AzureHelpers
Initialize-Azure
Remove-Module -Name AzureHelpers

# Trace the expression as it will be invoked.
$scriptCommand = "& '$($scriptPath.Replace("'", "''"))' $scriptArguments"
Write-Verbose $scriptCommand

# Remove all commands imported from VstsTaskSdk, other than Out-Default.
Get-ChildItem -LiteralPath function: |
    Where-Object { $_.Source -eq 'VstsTaskSdk' -and $_.Name -ne 'Out-Default' } |
    Remove-Item

# For compatibility with the legacy handler implementation, set the error action
# preference to continue. An implication of changing the preference to Continue,
# is that Invoke-VstsTaskScript will no longer handle setting the result to failed.
$ErrorActionPreference = 'Continue'

# Run the user's script. Redirect the error pipeline to the output pipeline to enable
# a couple goals due to compatibility with the legacy handler implementation:
# 1) STDERR from external commands needs to be converted into error records. Piping
#    the redirected error output to an intermediate command before it is piped to
#    Out-Default will implicitly perform the conversion.
# 2) The task result needs to be set to failed if an error record is encountered.
#    As mentioned above, the requirement to handle this is an implication of changing
#    the error action preference.
Invoke-Expression -Command $scriptCommand 2>&1 |
    ForEach-Object {
        # Put the object back into the pipeline. When doing this, the object needs
        # to be wrapped in an array to prevent unraveling.
        ,$_

        # Set the task result to failed if the object is an error record.
        if ($_ -is [System.Management.Automation.ErrorRecord]) {
            "##vso[task.complete result=Failed]"
        }
    }
