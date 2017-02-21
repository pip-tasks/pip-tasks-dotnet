########################################################
##
## Nuget.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## Nuget commands
##
#######################################################

$NugetPath = "$PSScriptRoot/../../lib/nuget"


function Get-NugetVersion
{
<#
.SYNOPSIS

Gets version of Nuget package

.DESCRIPTION

Get-NugetVersion gets version of Nuget project

.PARAMETER Path

Path to Nuget package (default: .)

.EXAMPLE

PS> Get-NugetVersion -Path .

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
            $specs = Get-ChildItem -Path . -Include *.nuspec -Recurse            
            $versions = @{}

            foreach ($spec in $specs)
            {
                [xml]$c = Get-Content -Path $spec.FullName
                $version = $c.package.metadata.version
                $versions[$version] = $version
            }

            $versions.Keys | Sort-Object | Write-Output
        }
    }
    end {}
}


function Set-NugetVersion
{
<#
.SYNOPSIS

Sets version of Nuget package

.DESCRIPTION

Set-NugetVersion sets version of Nuget project

.PARAMETER Path

Path to Nuget package (default: .)

.PARAMETER Version

.EXAMPLE

PS> Set-NugetVersion -Path . -Version 1.1.0

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipelineByPropertyName=$true)]
        [string] $Path = '.',
        [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
        [string] $Version
    )
    begin {}
    process 
    {
        Invoke-At $Path {
            $specs = Get-ChildItem -Path . -Include *.nuspec -Recurse            

            foreach ($spec in $specs)
            {
                [xml]$c = Get-Content -Path $spec.FullName
                $c.package.metadata.version = $version

                ConvertFrom-Xml -InputObject $c | Set-Content -Path $spec.FullName
            }
        }
    }
    end {}
}


function Get-NugetPackages
{
<#
.SYNOPSIS

Gets all Nuget packages

.DESCRIPTION

Get-NugetPackages gets all Nuget packages and their versions

.PARAMETER Path

Path to Nuget project (default: .)

.EXAMPLE

PS> Get-NugetPackages -Path .

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
            $deps = @{}

            $prjs = Get-ChildItem -Filter *.csproj -Recurse
            foreach ($prj in $prjs)
            {
                $cfg = "$($prj.DirectoryName)/packages.config"
                if (Test-Path -Path $cfg)
                {
                    [xml]$ps = Get-Content -Path $cfg

                    foreach ($p in $ps.packages.package)
                    {
                        $dep = $p.id + '@' + $p.version
                        $deps[$dep] = $dep
                    }
                }
            }

            $deps.Keys | Sort-Object | Write-Output
        }
    }
    end {}
}


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

Updates version of Nuget package

.DESCRIPTION

Update-NugetPackage updates version of Nuget package specified by name

.PARAMETER Path

Path to Nuget package (default: .)

.PARAMETER Package

Package name

.PARAMETER Version

Package version

.EXAMPLE

PS> Update-NugetPackage -Path . -Package PipServices.Commons -Version 1.0.50

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipelineByPropertyName=$true)]
        [string] $Path = '.',
        [Parameter(Mandatory=$false, Position=1, ValueFromPipelineByPropertyName=$true)]
        [string] $Package,
        [Parameter(Mandatory=$true, Position=2, ValueFromPipelineByPropertyName=$true)]
        [string] $Version
    )
    begin {}
    process 
    {
        if ($Package -eq $null -or $Package -eq '') { return }
        if ($Package.Contains('@'))
        {
            $pos = $Package.IndexOf('@')
            $Package = $Package.Substring(0, $pos)
            $Version = $Package.Substring($pos + 1)
        }

        Invoke-At $Path {
            # Update version in nuget packages
            $pkgs = Get-ChildItem -Path . -Include packages.config -Recurse            
            foreach ($pkg in $pkgs)
            {
                [xml]$c = Get-Content -Path $pkg.Fullname

                $updated = $false
                foreach ($p in $c.packages.package)
                {
                    if ($Package -ne '' -and -not $p.id.Contains($Package))
                    {
                        continue
                    }

                    Write-Host "Updated $($p.id) to version $Version in $($pkg.Name)"
                    $p.version = $Version
                    $updated = $true
                }

                if ($updated)
                {
                    ConvertFrom-Xml -InputObject $c | Set-Content -Path $pkg.FullName
                }
            }

            # Update version in nuget specs
            $specs = Get-ChildItem -Path . -Include *.nuspec -Recurse            
            foreach ($spec in $specs)
            {
                [xml]$c = Get-Content -Path $spec.Fullname

                $updated = $false

                foreach ($g in $c.package.metadata.dependencies.group)
                {
                    foreach ($d in $g.dependency)
                    {
                        if ($Package -ne '' -and -not $d.id.Contains($Package))
                        {
                            continue
                        }

                        Write-Host "Updated $($d.id) to version $Version in $($spec.Name)"
                        $d.version = $Version
                        $updated = $true
                    }
                }

                foreach ($d in $c.package.metadata.dependencies.dependency)
                {
                    if ($Package -ne '' -and -not $d.id.Contains($Package))
                    {
                        continue
                    }

                    Write-Host "Updated $($d.id) to version $Version in $($spec.Name)"
                    $d.version = $Version
                    $updated = $true
                }

                if ($updated)
                {
                    ConvertFrom-Xml -InputObject $c | Set-Content -Path $spec.FullName
                }
            }
        }
    }
    end {}
}


function Update-NugetLatestPackage
{
<#
.SYNOPSIS

Updates Nuget package to the latest version

.DESCRIPTION

Update-NugetLatestPackage updates Nuget package to the latest version

.PARAMETER Path

Path to Nuget project (default: .)

.PARAMETER Package

Package name

.EXAMPLE

PS> Update-NugetLatestPackage -Path . -Package Microsoft.AzureStorage

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipelineByPropertyName=$true)]
        [string] $Path = '.',
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Package
    )
    begin {}
    process 
    {        
        Invoke-At $Path {
            $slns = Get-Item -Path *.sln
            if ($slns.Count -eq 0) { throw "VisualStudio solution file was not found" }

            $extcfg = Test-Path -Path nuget.config

            if ($extcfg)
            {
                Copy-Item -Path nuget.config -Destination nuget.temp.config
            }

            try 
            {
                if ($extcfg)
                {
                    Invoke-External { 
                        .$NugetPath/VSS.NuGet.AuthHelper.exe -Config nuget.temp.config -TargetConfig nuget.temp.config
                    } "Failed to authorize access to nuget repository"
                }

                $prjs = Get-ChildItem -Filter *.csproj -Recurse
                foreach ($prj in $prjs)
                {
                    $cfg = "$($prj.DirectoryName)\packages.config"
                    if (Test-Path -Path $cfg)
                    {
                        [xml]$ps = Get-Content -Path $cfg
                        $ids = @()
                        foreach ($p in $ps.packages.package)
                        {
                            if ($p.id.Contains($Package))
                            {
                                $ids += $p.id
                            }
                        }

                        foreach ($id in $ids)
                        {
                            if ($extcfg)
                            {
                                Invoke-External { 
                                    .$NugetPath\Nuget update $prj.FullName -id "$id" -ConfigFile nuget.temp.config -prerelease -safe
                                } "Failed to update nuget package"
                            }
                            else
                            {
                                Invoke-External { 
                                    .$NugetPath\Nuget update $prj.FullName -id "$id" -prerelease -safe
                                } "Failed to update nuget package"
                            }
                        }
                    }
                }
            }
            finally
            {
                if ($extcfg)
                {
                    Remove-Item -Path nuget.temp.config
                }
            }
        }
    }
    end {}
}


function Update-NugetPackagesFromSource
{
<#
.SYNOPSIS

Updates versions of Nuget packages from specified source

.DESCRIPTION

Update-NugetPackagesFromSource updates versions of Nuget packages from specified source

.PARAMETER Path

Path to Nuget project (default: .)

.PARAMETER Source

Nuget repository

.EXAMPLE

PS> Update-NugetPackagesFromSource -Path . -Source mynugetrepo

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipelineByPropertyName=$true)]
        [string] $Path = '.',
        [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
        [string] $Source
    )
    begin {}
    process 
    {        
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

                    foreach ($sln in $slns)
                    {        
                        Invoke-External { 
                            .$NugetPath\Nuget update $sln.FullName -configfile nuget.temp.config -prerelease -source $Source -safe
                        } "Failed to update nuget packages"
                    }
                }
                finally
                {
                    Remove-Item -Path nuget.temp.config
                }
            }
            else
            {
                foreach ($sln in $slns)
                {        
                    Invoke-External { 
                        .$NugetPath\Nuget update $sln.FullName -prerelease -source $Source -safe
                    } "Failed to update nuget packages"
                }
            }
        }
    }
    end {}
}


