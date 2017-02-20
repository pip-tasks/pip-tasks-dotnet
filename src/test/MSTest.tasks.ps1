########################################################
##
## MSTest.tasks.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## MSTest test tasks
##
#######################################################

# Set correct path when invoked from other scripts
$BuildRoot = $BuildPath

# Synopsis: Tests Visual Studio project with MSTest
task MSTest {
    # MSTest does't understand Any CPU
    if ($BuildPlatform -eq 'Any CPU') { $BuildPlatform = 'x64' }

    Invoke-MSTest -Path . -Config $BuildConfig -Platform $BuildPlatform -Suffix $BuildTest
}
