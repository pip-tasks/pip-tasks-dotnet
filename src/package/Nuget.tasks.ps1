########################################################
##
## Nuget.tasks.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## Nuget build tasks
##
#######################################################

# Set correct path when invoked from other scripts
$BuildRoot = $BuildPath

# Synopsis: Gets nuget package version
task NugetGetVersion {
    Get-NugetVersion -Path .
}

# Synopsis: Sets nuget package version
task NugetSetVersion {
    assert ($Version -ne $null) "Version is not set"

    Set-NugetVersion -Path . -Version $Version
}

# Synopsis: Gets nuget dependencies
task NugetGetDep {
    Get-NugetPackages -Path .
}

# Synopsis: Clears nuget dependencies
task NugetCleanDep {
    Clear-NugetPackages -Path .
}

# Synopsis: Install nuget dependencies
task NugetInstallDep {
    Install-NugetPackages -Path .
}

# Synopsis: Update nuget dependency
task NugetUpdateDep {
    if ($Dependency -eq $null -or $Dependency -eq '')
    {
        if ($Source -eq $null -or $Source -eq '') { $Source = $PackageSource }
        Update-NugetPackagesFromSource -Source $Source    
    }
    else 
    {
        if ($Version -eq $null -and -not $Dependency.Contains('@'))
        {
            Update-NugetLatestPackage -Package $Dependency
        }
        else 
        {
            Update-NugetPackage -Package $Dependency -Version $Version
        }
    }
}

# Synopsis: Publish nuget packages to global repository
task NugetPublish {
    if ($Source -eq $null -or $Source -eq '') { $Source = $PackageSource }
    if ($ApiKey -eq $null -or $ApiKey -eq '') { $ApiKey = $PackageApiKey }
    assert ($ApiKey -ne $null) "ApiKey is not set"

    Publish-Nuget -Path . -Source $Source -ApiKey $ApiKey
}
