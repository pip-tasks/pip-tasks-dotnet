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
    Invoke-MSBuild -Path . -Config $BuildConfig -Platform $BuildPlatform
}

# Synopsis: Rebuilds MSBuild project
task MSRebuild {
    Invoke-MSRebuild -Path . -Config $BuildConfig -Platform $BuildPlatform
}
