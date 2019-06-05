Configuration BakeryWebsite
{ 
    Import-DscResource -Module xWebAdministration, xNetworking, PSDesiredStateConfiguration
    
    $LogPath = "{tagssm:LogPath}"
    $DestinationPath = "{tagssm:WebSiteDestinationPath}"
    $WebSiteName = "{tagssm:WebSiteName}"

    # Install the IIS role
    WindowsFeature IIS
    {
        Ensure          = 'Present'
        Name            = 'Web-Server'
    }

    # Install the ASP .NET 4.5 role
    WindowsFeature AspNet45
    {
        Ensure          = 'Present'
        Name            = 'Web-Asp-Net45'
    }

    # Stop the default website
    xWebsite DefaultSite 
    {
        Ensure          = 'Present'
        Name            = 'Default Web Site'
        State           = 'Stopped'
        PhysicalPath    = 'C:\inetpub\wwwroot'
        DependsOn       = '[WindowsFeature]IIS'
    }

    # Copy the website content
    File WebContent
    {
        Ensure          = 'Present'
        SourcePath      = 'C:\Content\BakeryWebsite'
        DestinationPath = $DestinationPath
        Recurse         = $true
        Type            = 'Directory'
        DependsOn       = '[WindowsFeature]AspNet45'
    }       

    # Create the new Website
    xWebsite BakeryWebSite 
    {
        Ensure          = 'Present'
        Name            = $WebSiteName
        State           = 'Started'
        PhysicalPath    = $DestinationPath
        BindingInfo     = @(
        MSFT_xWebBindingInformation
            {
                Protocol              = "HTTP"
                Port                  = 80
            })
        DependsOn       = '[File]WebContent'
    }
	
    xFirewall AllowManagementPort {
        Name            = "RDP xPort"
        DisplayName     = "RDP xPort"
        Ensure          = "Present"
        Protocol        = "TCP"
        Enabled         = "True"
        Direction       = "InBound"
        LocalPort       = 3389
    }
    
    xIISLogging Logging
    {
        LogPath              = $LogPath 
        Logflags             = @('Date','Time','ClientIP','UserName','ServerIP')
        LoglocalTimeRollover = $True
        LogTruncateSize      = '2097152'
        LogFormat            = 'W3C'
        DependsOn            = '[xWebsite]BakeryWebSite'
    }
}
BakeryWebsite
