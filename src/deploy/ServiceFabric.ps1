########################################################
##
## ServiceFabric.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## Service Fabric commands
##
#######################################################

# Todo: Add checks for Service Fabric Powershell

function Get-SFApplications
{
<#
.SYNOPSIS

Gets applications deployed on Service Fabric cluster

.DESCRIPTION

Get-SFApplications gets applications deployed on specified cluster

.PARAMETER Uri

Service Fabric cluster URI (default: localhost:19000)

.EXAMPLE

PS> Get-SFApplications -Uri "10.0.0.100:19000"

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$true)]
        [string] $Uri = "localhost:19000"
    )
    begin {}
    process 
    {
        $null = Connect-ServiceFabricCluster -ConnectionEndpoint $Uri
        $apps = Get-ServiceFabricApplication
        foreach ($app in $apps)
        {
            Write-Output $app.ApplicationTypeName
        }
    }
    end {}
}


function Reset-SFCluster
{
<#
.SYNOPSIS

Reset Service Fabric cluster

.DESCRIPTION

Reset-SFCluster removes all applications deployed on Service Fabric cluster

.PARAMETER Uri

Service Fabric cluster URI (default: localhost:19000)

.EXAMPLE

PS> Reset-SFCluster -Uri "10.0.0.100:19000"

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$true)]
        [string] $Uri = "localhost:19000"
    )
    begin {}
    process 
    {
        $null = Connect-ServiceFabricCluster -ConnectionEndpoint $Uri

        $apps = Get-ServiceFabricApplication
        foreach($app in $apps)
        {
            Remove-ServiceFabricApplication $app.ApplicationName -Force
        }

        $appTypes = Get-ServiceFabricApplicationType
        foreach($appType in $appTypes)
        {
            Unregister-ServiceFabricApplicationType $appType.ApplicationTypeName -ApplicationTypeVersion $appType.ApplicationTypeVersion -Force
        }

    }
    end {}
}


function Publish-SFApplication
{
<#
.SYNOPSIS

Publishes application to Service Fabric cluster

.DESCRIPTION

Publish-SFApplication publishes application to Service Fabric cluster

.PARAMETER Path

The Path to git local repository (default: .)

.PARAMETER Uri

Service Fabric cluster URI (default: localhost:19000)

.PARAMETER Profile

Service Fabric deployment configuration

.EXAMPLE

PS> Publish-SFApplication -Path "." -Uri "10.0.0.100:19000"

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$true)]
        [string] $Path = ".",

        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$true)]
        [string] $Uri = "localhost:19000",

        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$true)]
        [string] $Profile = "Cloud.xml"
    )
    begin {}
    process 
    {
        Invoke-At $Path {
            $prjs = Get-ChildItem -Filter *.sfproj -Recurse
            foreach ($prj in $prjs)
            {            
                $prjPath = $prj.DirectoryName
                Set-Location -Path $prjPath

                Invoke-External { 
                    & "$MSBuildPath/msbuild.exe" $prj.FullName /t:Package "/p:PackageLocation=$prjPath\pkg"
                } "Failed to build Service Fabric application"

                # Publish component to the cluster
                Connect-ServiceFabricCluster -ConnectionEndpoint $Uri
                $Global:ClusterConnection = $ClusterConnection
                . .\Scripts\Deploy-FabricApplication.ps1 -ApplicationPackagePath "$prjPath\pkg" -PublishProfileFile "PublishProfiles\$Profile" -DeployOnly:$false -UnregisterUnusedApplicationVersionsAfterUpgrade $false -OverrideUpgradeBehavior 'None' -OverwriteBehavior 'SameAppTypeAndVersion' -SkipPackageValidation:$false -ErrorAction Stop -UseExistingClusterConnection
            }
        }
    }
    end {}
}


function Unpublish-SFApplication
{
<#
.SYNOPSIS

Removes application from Service Fabric cluster

.DESCRIPTION

Unpublish-SFApplication removes application from Service Fabric cluster

.PARAMETER Uri

Service Fabric cluster URI (default: localhost:19000)

.PARAMETER Application

Service Fabric application type name

.EXAMPLE

PS> Unpublish-SFApplication -Uri "10.0.0.100:19000" -Application MyApp

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$true)]
        [string] $Uri = "localhost:19000",

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$true)]
        [string] $Application
    )
    begin {}
    process 
    {
        Invoke-At $Path {
            $null = Connect-ServiceFabricCluster -ConnectionEndpoint $Uri

            $apps = Get-ServiceFabricApplication
            foreach ($app in $apps)
            {
                if ($app.ApplicationTypeName -eq $Application)
                {
                    Remove-ServiceFabricApplication $app.ApplicationName -Force
                    Unregister-ServiceFabricApplicationType $app.ApplicationTypeName -ApplicationTypeVersion $app.ApplicationTypeVersion -Force
                }
            }
        }
    }
    end {}
}
