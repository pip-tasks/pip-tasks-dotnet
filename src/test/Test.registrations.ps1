########################################################
##
## Test.registrations.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## Registrations for test tasks 
##
#######################################################

$msttasks = "$PSScriptRoot/MSTest.tasks.ps1"

# Registrations for imperative tasks
Register-ImperativeInclude -CallFile $msttasks -Component

# Registrations for declarative tasks
Register-DeclarativeTask -Task Test -Variable Test -Value mstest -CallFile $msttasks -CallTask MSTest -Component
