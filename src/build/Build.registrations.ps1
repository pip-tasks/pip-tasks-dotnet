########################################################
##
## Build.registrations.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## Registrations for build tasks 
##
#######################################################

$vstasks = "$PSScriptRoot/VisualStudio.tasks.ps1"

# Registrations for imperative tasks
Register-ImperativeInclude -CallFile $vstasks -Component

# Registrations for declarative tasks
Register-DeclarativeTask -Task Clean -Variable Build -Value visualstudio -CallFile $vstasks -CallTask VSClean -Component
Register-DeclarativeTask -Task Build -Variable Build -Value visualstudio -CallFile $vstasks -CallTask VSBuild -Component
Register-DeclarativeTask -Task Rebuild -Variable Build -Value visualstudio -CallFile $vstasks -CallTask VSRebuild -Component


$msbtasks = "$PSScriptRoot/MSBuild.tasks.ps1"

# Registrations for imperative tasks
Register-ImperativeInclude -CallFile $msbtasks -Component

# Registrations for declarative tasks
Register-DeclarativeTask -Task Clean -Variable Build -Value msbuild -CallFile $msbtasks -CallTask MSClean -Component
Register-DeclarativeTask -Task Build -Variable Build -Value msbuild -CallFile $msbtasks -CallTask MSBuild -Component
Register-DeclarativeTask -Task Rebuild -Variable Build -Value msbuild -CallFile $msbtasks -CallTask MSRebuild -Component
