# <img src="https://github.com/pip-tasks/pip-tasks-ps/raw/master/artifacts/logo.png" alt="Pip.Devs Logo" style="max-width:30%"> <br/> .NET build tasks for Pip.Tasks

This Powershell module brings build tasks for .NET projects into the Pip.Tasks build system

**Nuget** tasks turned on by property **$Package = 'nuget'**
* **CleanDep** - cleans packages with Nuget dependencies
* **RestoreDep** - downloads Nuget packages references by projects 
* **UpdateDep** - updates selected package or all packages from specified source to the latest compatible version

**Visual Studio** tasks turned on by property **$Build = 'visualstudio'**
* **Clean** - cleans Visual Studio projects
* **Build** - builds Visual Studio projects 
* **Rebuild** - rebuilds Visual Studio projects 

**MSBuild** tasks turned on by property **$Build = 'msbuild'**
* **Clean** - cleans Visual Studio projects with MSBuild
* **Build** - builds Visual Studio projects  with MSBuild
* **Rebuild** - rebuilds Visual Studio projects with MSBuild

**MSTest** tasks turned on by property **$Build = 'mstest'**
* **Test** - tests Visual Studio projects using MSTest

**Service Fabric** tasks turned on by property **$Deploy = 'servicefabric'**. 
**$DeployUri = 'host:port'** defines Service Fabric cluster to work with
* **GetDeployedComponents** - gets all components deployed on Service Fabric cluster
* **ResetServer** - cleas up Service Fabric cluster by removing all deployed components
* **Deploy** - deploys component to Service Fabric cluster
* **Undeploy** - undeploys component from Service Fabric cluster

## Installation

* Checkout **pip-tasks-ps** and **pip-tasks-dotnet-ps** modules
* Add folder with the modules to **PSModulePath**
* Import **pip-tasks-dotnet-ps** module. **pip-tasks-ps** will be imported automatically

## Usage

TBD...

## Acknowledgements

This module created and maintained by:
* **Sergey Seroukhov**
* **Volodymyr Tkachenko**

Many thanks to contibutors, who put their time and talant into making this project better:
* **Nick Jimenez, BootBarn Inc.**