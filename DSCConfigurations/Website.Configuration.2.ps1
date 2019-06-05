Configuration BakeryWebsitePartial
{ 
    Import-DscResource -Module xWebAdministration, PSDesiredStateConfiguration
    
    $LogPath = "{tagssm:LogPath}"
    $DestinationPath = "{tagssm:WebSiteDestinationPath}"
    $WebSiteName = "{tagssm:WebSiteName}"

    # Stop the default website
    xWebsite DefaultSite 
    {
        Ensure          = 'Present'
        Name            = 'Default Web Site'
        State           = 'Stopped'
        PhysicalPath    = 'C:\inetpub\wwwroot'
    }

    # Copy the website content
    File WebContent
    {
        Ensure          = 'Present'
        SourcePath      = 'C:\Content\BakeryWebsite'
        DestinationPath = $DestinationPath
        Recurse         = $true
        Type            = 'Directory'
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
BakeryWebsitePartial
