########################################################
##
## Nuget.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## Nuget commands
##
#######################################################

$NugetPath = "$PSScriptRoot/../../lib/nuget"

function Clear-NugetPackages
{
<#
.SYNOPSIS

Clears Nuget packages

.DESCRIPTION

Clear-NugetPackages removed packages folder with Nuget dependencies

.PARAMETER Path

Path to Nuget project (default: .)

.EXAMPLE

PS> Clear-NugetPackages -Path .

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
            if (Test-Path -Path "./packages")
            {
                Remove-Item -Recurse -Force "./packages"
            }
        }
    }
    end {}
}

function Restore-NugetPackages
{
<#
.SYNOPSIS

Restores Nuget packages

.DESCRIPTION

Restore-NugetPackages restores Nuget packages

.PARAMETER Path

Path to Nuget project (default: .)

.EXAMPLE

PS> Restore-NugetPackages -Path .

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
            if ($slns.Count -eq 0) { throw "VisualStudio solution file was not found" }

            # For custom nuget source perform authentication
            if (Test-Path -Path nuget.config)
            {
                Copy-Item -Path nuget.config -Destination nuget.temp.config
                try 
                {
                    Invoke-External { 
                        .$NugetPath/VSS.NuGet.AuthHelper.exe -Config nuget.temp.config -TargetConfig nuget.temp.config
                    } "Failed to authorize access to nuget repository"

                    foreach ($sln in $slns)
                    {
                        Invoke-External { 
                            .$NugetPath/Nuget restore $sln.FullName -ConfigFile nuget.temp.config
                        } "Failed to restore nuget packages"
                    }
                }
                finally
                {
                    Remove-Item -Path nuget.temp.config
                }
            }
            # For generic nuget source
            else
            {
                foreach ($sln in $slns)
                {
                    Invoke-External { 
                        .$NugetPath/Nuget restore $sln.FullName
                    } "Failed to restore nuget packages"
                }
            }
        }
    }
    end {}
}


function Update-NugetPackage
{
<#
.SYNOPSIS

Updates version of Nuget package or packages

.DESCRIPTION

Update-NugetPackage updates versions of Nuget package(s) specified by name or source

.PARAMETER Path

Path to Nuget project (default: .)

.PARAMETER Package

Package name

.PARAMETER source

Nuget repository

.EXAMPLE

PS> Update-NugetPackage -Path . -Package Microsoft.AzureStorage -Version 5.3.0

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipelineByPropertyName=$true)]
        [string] $Path = '.',
        [Parameter(Mandatory=$false, Position=1, ValueFromPipelineByPropertyName=$true)]
        [string[]] $Package = @(),
        [Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName=$true)]
        [string] $Source
    )
    begin {}
    process 
    {
        if ($Package.Count -eq 0 -and $Source -eq '') { throw "Either Package or Source must be set" }
        if ($Package.Count -ne 0 -and $Source -ne '') { throw "Package and Source cannot not be set at the same time" }

        Invoke-At $Path {
            $slns = Get-Item -Path *.sln
            if ($slns.Count -eq 0) { throw "VisualStudio solution file was not found" }

            if (Test-Path -Path nuget.config)
            {
                Copy-Item -Path nuget.config -Destination nuget.temp.config
                try 
                {
                    Invoke-External { 
                        .$NugetPath/VSS.NuGet.AuthHelper.exe -Config nuget.temp.config -TargetConfig nuget.temp.config
                    } "Failed to authorize access to nuget repository"

                    # Update all dependencies from specified source
                    if ($Source -ne '')
                    {        
                        foreach ($sln in $slns)
                        {        
                            Invoke-External { 
                                .$NugetPath\Nuget update $sln.FullName -configfile nuget.temp.config -prerelease -source $Source -safe
                            } "Failed to update nuget packages"
                        }
                    }
                    # Update specific dependency if it exists
                    else 
                    {
                        $prjs = Get-ChildItem -Filter *.csproj -Recurse
                        foreach ($prj in $prjs)
                        {
                            $cfg = "$($prj.DirectoryName)\packages.config"
                            if (Test-Path -Path $cfg)
                            {
                                $before = Select-String $cfg -Pattern "<package id=" | Select -ExpandProperty line
                                $ids = @()
                                foreach ($value in $before)
                                {
                                    $ids += ([xml]$value).package.id;
                                }

                                foreach ($pkg in $Package)
                                {
                                    $id = $null
                                    foreach ($value in $ids)
                                    {
                                        if ($value.Contains($pkg))
                                        {
                                            $id = $value
                                            break;
                                        }
                                    }
                                    if ($id -ne $null)
                                    {
                                        Invoke-External { 
                                            .$NugetPath\Nuget update $prj.FullName -id "$id" -ConfigFile nuget.temp.config -prerelease -safe
                                        } "Failed to update nuget package"
                                    }
                                }
                            }
                        }
                    }
                }
                finally
                {
                    Remove-Item -Path nuget.temp.config
                }
            }
            else
            {
                # Update all dependencies from specified source
                if ($Source -ne '')
                {        
                    foreach ($sln in $slns)
                    {        
                        Invoke-External { 
                            .$NugetPath\Nuget update $sln.FullName -prerelease -source $Source -safe
                        } "Failed to update nuget packages"
                    }
                }
                # Update specific dependency if it exists
                else 
                {
                    $prjs = Get-ChildItem -Filter *.csproj -Recurse
                    foreach ($prj in $prjs)
                    {
                        $cfg = "$($prj.DirectoryName)\packages.config"
                        if (Test-Path -Path $cfg)
                        {
                            $before = Select-String $cfg -Pattern "<package id=" | Select -ExpandProperty line
                            $ids = @()
                            foreach ($value in $before)
                            {
                                $ids += ([xml]$value).package.id;
                            }

                            foreach ($pkg in $Package)
                            {
                                $id = $null
                                foreach ($value in $ids)
                                {
                                    if ($value.Contains($pkg))
                                    {
                                        $id = $value
                                        break;
                                    }
                                }
                                if ($id -ne $null)
                                {
                                    Invoke-External { 
                                        .$NugetPath\Nuget update $prj.FullName -id "$id" -prerelease -safe
                                    } "Failed to update nuget package"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    end {}
}

