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

Nuget package version

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


function Install-NugetPackages
{
<#
.SYNOPSIS

Installs Nuget packages

.DESCRIPTION

Install-NugetPackages Installs Nuget packages

.PARAMETER Path

Path to Nuget project (default: .)

.EXAMPLE

PS> Install-NugetPackages -Path .

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

            # Update version in csproj (PackageReference - VS2017+)
            $projects = Get-ChildItem -Path . -Include *.csproj -Recurse            
            foreach ($project in $projects)
            {
                [xml]$c = Get-Content -Path $project.Fullname

                $updated = $false

                $packageReferences = $c.Project.ItemGroup | Where-Object { $_.PackageReference -ne $null }

                foreach($p in $packageReferences.ChildNodes)
                {
                    if ($Package -ne '' -and -not $p.Include.Contains($Package))
                    {
                        continue
                    }

                    Write-Host "Updated $($p.Include) to version $Version in $($project.Name)"
                    $p.Version = $Version
                    $updated = $true
                }

                if ($updated)
                {
                    ConvertFrom-Xml -InputObject $c | Set-Content -Path $project.FullName
                }
            }

            # Update version in csproj (ItemGroup-Reference)
            $projects = Get-ChildItem -Path . -Include *.csproj -Recurse            
            foreach ($project in $projects)
            {
                [xml]$c = Get-Content -Path $project.Fullname

                $updated = $false

                $pureVersion = $Version
                $preReleaseIndex = $Version.IndexOf('-')

                # extract pure version
                if ($preReleaseIndex -gt 0)
                {
                    $pureVersion = $pureVersion.Remove($preReleaseIndex)
                }

                $references = $c.Project.ItemGroup | Where-Object { $_.Reference -ne $null }

                foreach($r in $references.ChildNodes)
                {
                    if ($Package -ne '' -and -not $r.Include.Contains($Package + ","))
                    {
                        continue
                    }

                    # Update Version in Reference.Include
                    $include = $r.Include
                    $versionStartIndex = $include.IndexOf("Version")
                    if ($versionStartIndex -gt 0)
                    {
                        $versionLastIndex = $include.IndexOf(',', $versionStartIndex)
                        if ($versionLastIndex -gt 0)
                        {
                            $include = $include.Remove($versionStartIndex, $versionLastIndex - $versionStartIndex)
                            $include = $include.Insert($versionStartIndex, "Version=" + $pureVersion + ".0")

                            $r.Include = $include
                            $updated = $true

                            Write-Host "Updated Reference: $($r.Include) in $($project.Name)"
                        }
                    }

                    # Update Version in Hint Path
                    $hint = $r.HintPath
                    if ($Package -ne '' -and -not $hint.Contains($Package + "."))
                    {
                        continue
                    }

                    $hintPackageStartIndex = $hint.IndexOf($Package)
                    if ($hintPackageStartIndex -gt 0)
                    {
                        $hintPackageLastIndex = $hint.IndexOf('\', $hintPackageStartIndex)
                        if ($hintPackageLastIndex -gt 0)
                        {
                            $hint = $hint.Remove($hintPackageStartIndex, $hintPackageLastIndex - $hintPackageStartIndex)
                            $hint = $hint.Insert($hintPackageStartIndex, $Package + "." + $Version)

                            $r.HintPath = $hint
                            $updated = $true

                            Write-Host "Updated Hint Path: $($r.HintPath) in $($project.Name)"
                        }
                    }
                }

                if ($updated)
                {
                    ConvertFrom-Xml -InputObject $c | Set-Content -Path $project.FullName
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
                            Write-Host "prj=$($prj.FullName); id=$($id); extcfg=$extcfg"
                            
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


function Publish-Nuget
{
<#
.SYNOPSIS

Publishes Nuget packages to global Nuget repository

.DESCRIPTION

Publish-Nuget packages Nuget packages and then pushes them to global Nuget repository

.PARAMETER Path

Path to Nuget package (default: .)

.PARAMETER Source

Nuget global repository (default: https://www.nuget.org/api/v2/package)

.PARAMETER ApiKey

Key to access the global repository

.EXAMPLE

PS> -NugetVersion -Path . -Version 1.1.0

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipelineByPropertyName=$true)]
        [string] $Path = '.',
        [Parameter(Mandatory=$false, Position=1, ValueFromPipelineByPropertyName=$true)]
        [string] $Source,
        [Parameter(Mandatory=$true, Position=2, ValueFromPipelineByPropertyName=$true)]
        [string] $ApiKey
    )
    begin {}
    process 
    {
        if ($Source -eq $null -or $Source -eq '') { $Source = 'https://www.nuget.org/api/v2/package' }

        Invoke-At $Path {
            $specs = Get-ChildItem -Path . -Include *.nuspec -Recurse            

            foreach ($spec in $specs)
            {
                [xml]$c = Get-Content -Path $spec.FullName
                $version = $c.package.metadata.version

                Invoke-External { 
                    .$NugetPath\Nuget pack $spec.FullName
                } "Failed to pack nuget package"

                $pkg = "$($spec.DirectoryName)/$($spec.BaseName).$version.nupkg"
                if (-not (Test-Path -Path $pkg))
                {
                    throw "Package $pkg was not found after packing"
                }

                Invoke-External { 
                    .$NugetPath\Nuget push $pkg -Source $Source -ApiKey $ApiKey
                } "Failed to push nuget package"
            }
        }
    }
    end {}
}
