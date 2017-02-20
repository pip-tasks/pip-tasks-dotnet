########################################################
##
## VisualStudio.tasks.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## VisualStudio build tasks
##
#######################################################

# Set correct path when invoked from other scripts
$BuildRoot = $BuildPath

# Synopsis: Clears Visual Studio project
task VSClean {
    Clear-VSBuild -Path .
}

# Synopsis: Builds Visual Studio project
task VSBuild {
    Invoke-VSBuild -Path . -Config $BuildConfig
}

# Synopsis: Rebuilds Visual Studio project
task VSRebuild {
    Invoke-VSRebuild -Path . -Config $BuildConfig
}
