########################################################
##
## MSBuild.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## MSBuild commands
##
#######################################################

$MSBuildPath = "C:\Program Files (x86)\MSBuild\14.0\bin"

# Todo: Add checks for MSBuild path

function Clear-MSBuild
{
<#
.SYNOPSIS

Clears MSBuild build

.DESCRIPTION

Clear-MSBuild clears MSBuild solution build

.PARAMETER Path

Path to MSBuild solution (default: .)

.EXAMPLE

PS> Clear-MSBuild -Path .

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
                    ."$MSBuildPath/msbuild" $sln.FullName "/t:Clean"
                #} "Cleaning solution with MSBuild failed"
            }
        }
    }
    end {}
}


function Invoke-MSBuild
{
<#
.SYNOPSIS

Builds MSBuild solution

.DESCRIPTION

Invoke-MSBuild builds MSBuild solution in specified configuration

.PARAMETER Path

Path to MSBuild solution (default: .)

.PARAMETER Config

Build configuration - Release or Debug (default: Debug)

.PARAMETER Platform

Build platform - Any CPU, x64 or x86

.EXAMPLE

PS> Invoke-MSBuild -Path .

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
        if ($Config -eq $null -or $Config -eq '') { $Config = 'Debug' }
        if ($Platform -eq $null -or $Platform -eq '') { $Platform = 'Any CPU' }

        Invoke-At $Path {
            $slns = Get-Item -Path *.sln
            foreach ($sln in $slns)
            {
                Invoke-External { 
                    ."$MSBuildPath/msbuild" $sln.FullName "/t:Build" "/p:Configuration=$Config" #"/p:Platform=`"$Platform`""
                } "Build solution with MSBuild failed"
            }
        }
    }
    end {}
}


function Invoke-MSRebuild
{
<#
.SYNOPSIS

Rebuilds MSBuild solution

.DESCRIPTION

Invoke-MSRebuild rebuilds MSBuild solution in specified configuration

.PARAMETER Path

Path to MSBuild solution (default: .)

.PARAMETER Config

Build configuration - Release or Debug (default: Debug)

.PARAMETER Platform

Build platform - Any CPU, x64 or x86

.EXAMPLE

PS> Invoke-MSBuild -Path .

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
        if ($Config -eq $null -or $Config -eq '') { $Config = 'Debug' }
        if ($Platform -eq $null -or $Platform -eq '') { $Platform = 'Any CPU' }

        Invoke-At $Path {
            $slns = Get-Item -Path *.sln
            foreach ($sln in $slns)
            {
                Invoke-External { 
                    ."$MSBuildPath/msbuild" $sln.FullName "/t:Rebuild" "/p:Configuration=$Config" #"/p:Platform=`"$Platform`""
                } "Build solution with MSBuild failed"
            }
        }
    }
    end {}
}
