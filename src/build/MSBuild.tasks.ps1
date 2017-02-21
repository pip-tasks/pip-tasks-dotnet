########################################################
##
## MSBuild.tasks.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## MSBuild build tasks
##
#######################################################

# Set correct path when invoked from other scripts
$BuildRoot = $BuildPath

# Synopsis: Clears MSBuild project
task MSClean {
    Clear-MSBuild -Path .
}

# Synopsis: Builds MSBuild project
task MSBuild {
    if ($Config -eq $null -or $Config -eq '') { $Config = $BuildConfig }
    if ($Platform -eq $null -or $Platform -eq '') { $Platform = $BuildPlatform }

    Invoke-MSBuild -Path . -Config $Config -Platform $Platform
}

# Synopsis: Rebuilds MSBuild project
task MSRebuild {
    if ($Config -eq $null -or $Config -eq '') { $Config = $BuildConfig }
    if ($Platform -eq $null -or $Platform -eq '') { $Platform = $BuildPlatform }

    Invoke-MSRebuild -Path . -Config $Config -Platform $Platform
}
