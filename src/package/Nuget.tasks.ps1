########################################################
##
## Nuget.tasks.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## Nuget build tasks
##
#######################################################

# Set correct path when invoked from other scripts
$BuildRoot = $BuildPath

# Synopsis: Gets nuget dependencies
task NugetGetDep {
    Get-NugetPackages -Path .
}

# Synopsis: Clears nuget dependencies
task NugetCleanDep {
    Clear-NugetPackages -Path .
}

# Synopsis: Restore nuget dependencies
task NugetRestoreDep {
    Restore-NugetPackages -Path .
}

# Synopsis: Update nuget dependency
task NugetUpdateDep {
    if ($Dependency -ne $null -and $Dependency -ne '')
    {
        Update-NugetPackage -Package $Dependency
    }
    else 
    {
        if ($Source -eq $null -or $Source -eq '') { $Source = $PackageSource }
        Update-NugetPackagesFromSource -Source $Source    
    }
}
