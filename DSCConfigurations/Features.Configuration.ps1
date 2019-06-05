Configuration Features
{ 
    Import-DscResource -Module xNetworking, PSDesiredStateConfiguration

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
	
    xFirewall AllowManagementPort {
        Name            = "RDP xPort"
        DisplayName     = "RDP xPort"
        Ensure          = "Present"
        Protocol        = "TCP"
        Enabled         = "True"
        Direction       = "InBound"
        LocalPort       = 3389
    }
}
Features
