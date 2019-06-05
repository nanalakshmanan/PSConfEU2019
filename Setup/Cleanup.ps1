[CmdletBinding()]
param(
)
. "./Settings.ps1"

$AllStacks = @($EnvironmentStack)
function Wait-Stack
{
	param(
		[string]
		$StackName
	)
	while(Test-CFNStack -StackName $StackName){
		Write-Verbose "Waiting for Stack $StackName to be deleted"
		Start-Sleep -Seconds 3
	}
}
$AllStacks | % {
	if (Test-CFNStack -StackName $_){
		Remove-CFNStack -StackName $_ -Force
	}
}

$AllStacks | % {
	Wait-Stack -StackName $_
}
$CommandDocs = @($RestartWindowsUpdateDoc, $RestartServiceCommandDoc, $CopyS3FolderDoc, $GetCredentialDoc, $ApplyDscMof)

$CommandDocs | % {
	Remove-SSMDocument -Name $_ -Force
}

# Remove SSM Parameters
Remove-SSMParameter -Name "DBString" -Force
Remove-SSMParameter -Name "DBPassword" -Force
Remove-SSMParameter -Name "LogPath" -Force
Remove-SSMParameter -Name "WebSiteName" -Force
Remove-SSMParameter -Name "WebSiteDestinationPath" -Force
