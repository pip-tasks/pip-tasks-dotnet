########################################################
##
## VisualStudio.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## Visual Studio commands
##
#######################################################

$VSPath = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE"

# Todo: Add checks for visual studio path

function Clear-VSBuild
{
<#
.SYNOPSIS

Clears Visual Studio build

.DESCRIPTION

Clear-VSBuild clears Visual Studio solution build

.PARAMETER Path

Path to Visual Studio solution (default: .)

.EXAMPLE

PS> Clear-VSBuild -Path .

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipelineByPropertyName=$true)]
        [string] $Path = '.'
    )
    begin {}
    process 
    {
        Invoke-At $Path {
            $slns = Get-Item -Path *.sln
            foreach ($sln in $slns)
            {
                #Invoke-External { 
                    ."$VSPath/devenv" $sln.FullName "/Clean"
                #} "Cleaning Visual Studio build failed"
            }
        }
    }
    end {}
}


function Invoke-VSBuild
{
<#
.SYNOPSIS

Builds Visual Studio solution

.DESCRIPTION

Invoke-VSBuild builds Visual Studio solution in specified configuration

.PARAMETER Path

Path to Visual Studio solution (default: .)

.PARAMETER Config

Build configuration - Release or Debug (default: Debug)

.EXAMPLE

PS> Invoke-VSBuild -Path .

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipelineByPropertyName=$true)]
        [string] $Path = '.',
        [Parameter(Mandatory=$false, Position=1, ValueFromPipelineByPropertyName=$true)]
        [string] $Config = 'Debug',
        [Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName=$true)]
        [string] $Platform = 'Any CPU'
    )
    begin {}
    process 
    {
        Invoke-At $Path {
            $slns = Get-Item -Path *.sln
            foreach ($sln in $slns)
            {
                Invoke-External { 
                    ."$VSPath/devenv" $sln.FullName "/Build" $Config
                } "Build Visual Studio solution failed"
            }
        }
    }
    end {}
}


function Invoke-VSRebuild
{
<#
.SYNOPSIS

Rebuilds Visual Studio solution

.DESCRIPTION

Invoke-VSRebuild rebuilds Visual Studio solution in specified configuration

.PARAMETER Path

Path to Visual Studio solution (default: .)

.PARAMETER Config

Build configuration - Release or Debug (default: Debug)

.EXAMPLE

PS> Invoke-VSBuild -Path .

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipelineByPropertyName=$true)]
        [string] $Path = '.',
        [Parameter(Mandatory=$false, Position=1, ValueFromPipelineByPropertyName=$true)]
        [string] $Config = 'Debug',
        [Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName=$true)]
        [string] $Platform = 'Any CPU'
    )
    begin {}
    process 
    {
        Invoke-At $Path {
            $slns = Get-Item -Path *.sln
            foreach ($sln in $slns)
            {
                Invoke-External { 
                    ."$VSPath/devenv" $sln.FullName "/Rebuild" $Config
                } "Build Visual Studio solution failed"
            }
        }
    }
    end {}
}
