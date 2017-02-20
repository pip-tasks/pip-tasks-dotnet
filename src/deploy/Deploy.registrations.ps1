########################################################
##
## Deploy.registrations.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## Registrations for deployment tasks 
##
#######################################################

$sftasks = "$PSScriptRoot/ServiceFabric.tasks.ps1"

# Registrations for imperative tasks
Register-ImperativeInclude -CallFile $sftasks -Component

# Registrations for declarative tasks
Register-DeclarativeTask -Task Deploy -Variable Deploy -Value servicefabric -CallFile $sftasks -CallTask SFDeploy -Component
Register-DeclarativeTask -Task Undeploy -Variable Deploy -Value servicefabric -CallFile $sftasks -CallTask SFUndeploy -Component
Register-DeclarativeTask -Task GetDeployedComponents -Variable Deploy -Value servicefabric -CallFile $sftasks -CallTask SFGetDeployedComponents -Component -Workspace
Register-DeclarativeTask -Task ResetServer -Variable Deploy -Value servicefabric -CallFile $sftasks -CallTask SFResetServer -Component -Workspace
