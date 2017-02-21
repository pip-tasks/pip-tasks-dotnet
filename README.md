# <img src="https://github.com/pip-tasks/pip-tasks-ps/raw/master/artifacts/logo.png" alt="Pip.Devs Logo" style="max-width:30%"> <br/> .NET build tasks for Pip.Tasks

This Powershell module contains tasks for [Pip.Tasks](https://github.com/pip-tasks/pip-tasks-ps) to build .NET components

### Nuget package management tasks

Each project with Nuget dependencies shall have **packages.config** file.
Released artifacts may contain **.nuspec** files in the root folder or under specific projects.
Optionally, Nuget may be configured to connect to private repository using **nuget.config** file in the root component folder.

NuGet tasks:
* **GetVersion** - gets version of Nuget package
* **SetVersion** - sets version of Nuget package
  - **Version** - version parameter
* **GetDep** - gets packages with Nuget dependencies
* **CleanDep** - cleans packages with Nuget dependencies
* **RestoreDep** - downloads Nuget packages references by projects 
* **UpdateDep** - updates selected package or all packages from specified source to the latest compatible version
  - **Source** - NuGet source repository parameter (shall be used instead of Dependency)
  - **Dependency** - dependency name parameter  
  - **Version** - dependency version parameter
* **Publish** - publishes NPM package to global repository
  - **Source** - NuGet source repository parameter
  - **ApiKey** - authorization ApiKey name parameter

NuGet configuration variables:
* **Package** - Turns on NuGet tasks (must be 'nuget')
* **PackageSource** - NuGet source repository (default: https://www.nuget.org/api/v2/package)
* **PackageApiKey** - NuGet authorization ApiKey

### Visual Studio build tasks

Visual Studio projects are compiled using **devenv.exe**

Visual Studio tasks:
* **Clean** - cleans Visual Studio projects
* **Build** - builds Visual Studio projects 
  - **Config** - build configuration: Release or Debug
  - **Platform** - build platform: x82, x64 or AnyCPU
* **Rebuild** - rebuilds Visual Studio projects 
  - **Config** - build configuration: Release or Debug
  - **Platform** - build platform: x82, x64 or AnyCPU

Visual Studio configuration Variables:
* **Build** - Turns on Visual Studio tasks (must be 'visualstudio')
* **BuildConfig** - Default build configuration: Debug or Release
* **BuildPlatform** - Default build platform: x86, x64 or AnyCPU

### MSBuild build tasks

MSBuild tasks:
* **Clean** - cleans MSBuild projects
* **Build** - builds MSBuild projects 
  - **Config** - build configuration: Release or Debug
  - **Platform** - build platform: x82, x64 or AnyCPU
* **Rebuild** - rebuilds MSBuild projects 
  - **Config** - build configuration: Release or Debug
  - **Platform** - build platform: x82, x64 or AnyCPU

MSBuild configuration Variables:
* **Build** - Turns on MSBuild tasks (must be 'msbuild')
* **BuildConfig** - Default build configuration: Debug or Release
* **BuildPlatform** - Default build platform: x86, x64 or AnyCPU

### MSTest test tasks

MSTest tasks:
* **Test** - tests Visual Studio projects using MSTest

MSTest configuration variables:
* **Test** - Turns on MSTest tasks (must be 'mstest')
* **BuildConfig** - Default build configuration: Debug or Release
* **BuildPlatform** - Default build platform: x86, x64 or AnyCPU
* **TestInclude** - Folder or list of folders with MSTest test projects

### Service Fabric deployment tasks

Service Fabric tasks:
* **GetDeployedComponents** - gets all components deployed on Service Fabric cluster
  - **Server** - name of the server configuration (default: local)
* **ResetServer** - cleas up Service Fabric cluster by removing all deployed components
  - **Server** - name of the server configuration (default: local)
* **Deploy** - deploys component to Service Fabric cluster
  - **Server** - name of the server configuration (default: local)
* **Undeploy** - undeploys component from Service Fabric cluster
  - **Server** - name of the server configuration (default: local)

Service Fabric configuration variables:
* **Deploy** - Turns on Service Fabric tasks (must be 'servicefabric')
* **DeployServer** - default name of the server configuration
* **DeployComponent** - override for deployment component name (when it is different than component name)
* **DeployConfigs** - list with server configurations. Each element must have the following fields:
  - **Server** - name of the server configuration that is used to retrieve the configuration
  - **Uri** - Service Fabric cluster Uri
  - **Profile** - Name of deployment profile file (Local.1Node.xml, Cloud.xml or any other)

## Installation

* Checkout **pip-tasks-ps** and **pip-tasks-dotnet-ps** modules
* Add folder with the modules to **PSModulePath**
* Import **pip-tasks-dotnet-ps** module. **pip-tasks-ps** will be imported automatically

## Usage

Let's say you have a .NET component with Service Fabric application.

The file structure may look the following:
```bash
/workspace
  ...
  /component1
    /Source
      /Component1.Application
      /Component1.Actor
    /Test
      /Component1.ActorTest
    component.conf.ps1
    Component1.sln
```

**component.conf.ps1** file:
```powershell
$VersionControl = 'git'

$Package = 'nuget'
$PackageSource = 'bootbarn'

$Build = 'visualstudio'
$Document = 'none'
$Test = 'mstest'

$Deploy = 'servicefabric'
$DeployServer = "local"
$DeployComponent = "BootBarn.$ComponentName"
$DeployConfigs = @(
    @{
        Server = "local";
        Uri = "localhost:19000";
        Profile = "Local.1Node.xml";
    },
    @{
        Server = "devfacade";
        Uri = "10.0.0.100:19000";
        Profile = "Cloud.xml";
    }
)

$Run = 'none'
```

A typical scenario to work with this component may include the following steps:

* Pull changes from Git repository
```powershell
> Invoke-Task -Task Pull -Component component1
```

* Install NuGet packages
```powershell
> Invoke-Task -Task RestoreDep -Component component1
```

* Compile component with Visual Studio
```powershell
> Invoke-Task -Task Rebuild -Component component1
```

* Test component with MSTest
```powershell
> Invoke-Task -Task Test -Component component1
```

* Reset local cluster and deploy there the component
```powershell
> Invoke-Task -Task ResetServer -Server local -workspace
> Invoke-Task -Task Deploy -Server local -Component component1
```

* Undeploy the component from the local cluster
```powershell
> Invoke-Task -Task Undeploy -Server local -Component component1
```

* Change version of external dependency
```powershell
> Invoke-Task -Task UpdateDep -Dependency component2 -Version 1.2.0 -Component component1
```

* Set new version for the component and push changes to Git repository
```powershell
> Invoke-Task -Task SetVersion -Version 1.0.1 -Component component1
> Invoke-Task -Task Push -Message "My changes" -Component component1
```

* Set tag to Git repository and publish public release
```powershell
> Invoke-Task -Task SetTag v1.0.1 -Component component1
> Invoke-Task -Task Publish -Component component1
```

Instead of typing full Powershell command 
```powershell
> Invoke-Task -Task getchanges -Component component1
```
you can use shortcuts like:
```powershell
> piptask getchanges
```

For more information about **Pip.Tasks** build infrastructure read documentation 
from the master project [here...](https://github.com/pip-tasks/pip-tasks-ps)
## Acknowledgements

This module created and maintained by **Sergey Seroukhov**

Many thanks to contibutors, who put their time and talant into making this project better:
* **Nick Jimenez, BootBarn Inc.**