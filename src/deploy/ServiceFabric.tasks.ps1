########################################################
##
## ServiceFabric.tasks.ps1
## Pip.Tasks.DotNet - .NET build tasks for Pip.Tasks
## Service Fabric build tasks
##
#######################################################

# Set correct path when invoked from other scripts
$BuildRoot = $BuildPath

# Synopsis: Gets components deployed on Service Fabric cluster
task SFGetDeployedComponents {
    if ($Server -eq $null) { $Server = $DeployServer  }
    assert ($Server -ne $null) "Server is not set"

    # Set deployment configuration
    if ($DeployConfigs -ne $null)
    {
        $p = Find-Properties -Properties $DeployConfigs -KeyName Server -Key $Server -DefaultKey local
        Set-Properties -Properties $p -Prefix Deploy
    }

    assert ($DeployUri -eq $null) "DeployUri is not set"

    Get-SFApplications -Uri $DeployUri
}

# Synopsis: Clears all deployed components on Service Fabric cluster
task SFResetServer {
    if ($Server -eq $null) { $Server = $DeployServer  }
    assert ($Server -ne $null) "Server is not set"

    # Set deployment configuration
    if ($DeployConfigs -ne $null)
    {
        $p = Find-Properties -Properties $DeployConfigs -KeyName Server -Key $Server -DefaultKey local
        Set-Properties -Properties $p -Prefix Deploy
    }

    assert ($DeployUri -ne $null) "DeployUri is not set"

    Reset-SFCluster -Uri $DeployUri
}

# Synopsis: Deploys component to Service Fabric cluster
task SFDeploy {
    if ($Server -eq $null) { $Server = $DeployServer  }
    assert ($Server -ne $null) "Server is not set"

    # Set deployment configuration
    if ($DeployConfigs -ne $null)
    {
        $p = Find-Properties -Properties $DeployConfigs -KeyName Server -Key $Server -DefaultKey local
        Set-Properties -Properties $p -Prefix Deploy
    }

    assert ($DeployUri -ne $null) "DeployUri is not set"
    assert ($DeployProfile -ne $null) "DeployProfile is not set"

    Publish-SFApplication -Path . -Uri $DeployUri -Profile $DeployProfile
}

# Synopsis: Undeploys component from Service Fabric cluster
task SFUndeploy {
    if ($Server -eq $null) { $Server = $DeployServer  }
    assert ($Server -ne $null) "Server is not set"

    # Set deployment configuration
    if ($DeployConfigs -ne $null)
    {
        $p = Find-Properties -Properties $DeployConfigs -KeyName Server -Key $Server -DefaultKey local
        Set-Properties -Properties $p -Prefix Deploy
    }

    assert ($DeployUri -ne $null) "DeployUri is not set"
    assert ($DeployComponent -ne $null) "DeployComponent is not set"

    $apps = Get-SFApplications -Uri $DeployUri
    foreach ($app in $apps)
    {
        if ($app -contains $DeployComponent)
        {
            Unpublish-SFApplication -Uri $DeployUri -Application $app
        }
    }
}
