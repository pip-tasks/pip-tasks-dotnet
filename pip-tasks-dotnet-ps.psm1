########################################################
##
## pip-tasks-dotnet-ps.psm1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## Startup module
##
#######################################################

$path = $PSScriptRoot
if ($path -eq "") { $path = "." }

. "$path\src\package\Nuget.ps1"
. "$path\src\build\VisualStudio.ps1"
. "$path\src\build\MSBuild.ps1"
. "$path\src\test\MSTest.ps1"
. "$path\src\deploy\ServiceFabric.ps1"

. "$path\src\package\Package.registrations.ps1"
. "$path\src\build\Build.registrations.ps1"
. "$path\src\test\Test.registrations.ps1"
. "$path\src\deploy\Deploy.registrations.ps1"
