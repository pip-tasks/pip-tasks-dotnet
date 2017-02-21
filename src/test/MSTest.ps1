########################################################
##
## MSTest.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## MSTest commands
##
#######################################################

$VSPath = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE"

# Todo: Add checks for visual studio path

function Invoke-MSTest
{
<#
.SYNOPSIS

Runs MSTest for test projects

.DESCRIPTION

Invoke-MSTest finds test projects inside VS solution and runs tests with them

.PARAMETER Path

Path to Visual Studio solution (default: .)

.PARAMETER Config

Build configuration - Release or Debug (default: Debug)

.EXAMPLE

PS> Invoke-MSTest -Path .

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipelineByPropertyName=$true)]
        [string] $Path = '.',
        [Parameter(Mandatory=$false, Position=1, ValueFromPipelineByPropertyName=$true)]
        [string] $Config = 'Debug',
        [Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName=$true)]
        [string] $Platform = 'x64',
        [Parameter(Mandatory=$false, Position=3, ValueFromPipelineByPropertyName=$true)]
        [string] $Include = './test'
    )
    begin {}
    process 
    {
        if ($Platform -eq $null -or $Platform -eq '') { $Platform = "x64" }

        Invoke-At $Path {
            $tp = Join-Path "bin" $Config
            $ts = Get-ChildItem $Include -Recurse | Where-Object { $_.Name.EndsWith("Test.dll") -and $_.FullName.Contains($tp) }
            foreach ($t in $ts)
            {
                $vstest = "$VSPath/CommonExtensions/Microsoft/TestWindow/vstest.console"
                Invoke-External { 
                    & $vstest $t.FullName "/platform:$Platform"
                } "Running MSTest failed"

                # Invoke-External { 
                #     & "$VSPath/MSTest" "/testcontainer:$($t.FullName)" /nologo 
                # } "Running MSTest failed"
            }
        }
    }
    end {}
}
