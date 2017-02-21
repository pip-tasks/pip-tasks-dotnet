########################################################
##
## Package.registrations.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## Registrations for package management tasks 
##
#######################################################

$ngtasks = "$PSScriptRoot/Nuget.tasks.ps1"

# Registrations for imperative tasks
Register-ImperativeInclude -CallFile $ngtasks -Component

# Registrations for declarative tasks
Register-DeclarativeTask -Task GetVersion -Variable Package -Value nuget -CallFile $ngtasks -CallTask NugetGetVersion -Component
Register-DeclarativeTask -Task SetVersion -Variable Package -Value nuget -CallFile $ngtasks -CallTask NugetSetVersion -Component
Register-DeclarativeTask -Task GetDep -Variable Package -Value nuget -CallFile $ngtasks -CallTask NugetGetDep -Component
Register-DeclarativeTask -Task CleanDep -Variable Package -Value nuget -CallFile $ngtasks -CallTask NugetCleanDep -Component
Register-DeclarativeTask -Task RestoreDep -Variable Package -Value nuget -CallFile $ngtasks -CallTask NugetRestoreDep -Component
Register-DeclarativeTask -Task UpdateDep -Variable Package -Value nuget -CallFile $ngtasks -CallTask NugetUpdateDep -Component
