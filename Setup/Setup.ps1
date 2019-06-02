[CmdletBinding()]
param(
)

. "./Settings.ps1"

$AllStacks = @($EnvironmentStack)
function Get-Parameter
{
	param(
		[Parameter(Position=0)]
		[string]
		$Key,

		[Parameter(Position=1)]
		[string]
		$Value
	)
	$Param = New-Object Amazon.CloudFormation.Model.Parameter
	$Param.ParameterKey = $Key
	$Param.ParameterValue = $Value
	
	return $Param
}

function Wait-Stack
{
	param(
		[string]
		$StackName
	)
	$Status = (Get-CFNStack -StackName $StackName).StackStatus
	
	while ($Status -ne 'CREATE_COMPLETE'){
		Write-Verbose "Waiting for stack creation to complete  $StackName"
		Start-Sleep -Seconds 5
		$Status = (Get-CFNStack -StackName $StackName).StackStatus
	}
}

# create the cloud formation stacks
$contents = Get-Content ./CloudFormationTemplates/Environment.yml -Raw
$Role = Get-Parameter 'RoleName' $RoleName
$LambdaFunction = Get-Parameter 'FunctionName' $LambdaFunctionName
$InstanceProfile = Get-Parameter 'InstanceProfileName' $InstanceProfileName
$KeyPair = Get-Parameter 'KeyPairName' $KeyPairName
$AmiId = Get-Parameter 'AmiId' $WindowsAmidId
$Vpc = Get-Parameter 'VpcId' $VpcId

New-CFNStack -StackName $EnvironmentStack -TemplateBody $contents -Parameter @($InstanceProfile, $KeyPair, $AmiId, $Vpc, $Role, $LambdaFunction) -Capability CAPABILITY_NAMED_IAM

# wait for the stack creation to complete
$AllStacks | %{
	Wait-Stack -StackName $_
}

<#
$contents = Get-Content ../Documents/Nana-BounceHostRunbook.json -Raw
New-SSMDocument -Content $contents -DocumentType Automation -Name $BounceHostName

$contents = Get-Content ../Documents/Nana-RestartNodeWithApproval.json -Raw
New-SSMDocument -Name $RestartNodeWithApprovalDoc -DocumentType Automation -TargetType '/AWS::EC2::Instance' -Content $contents
#>

#$CommandDocs = @($RestartWindowsUpdateDoc, $GetCredentialDoc, $ConfigureServicesDoc, $DscComplianceDoc, $RestartServiceCommandDoc)
$CommandDocs = @($RestartWindowsUpdateDoc, $RestartServiceCommandDoc, $CopyS3FolderDoc)

$CommandDocs | % {
	$contents = Get-Content "../Documents/$($_).yml" -Raw
	New-SSMDocument -Content $contents -DocumentFormat YAML -DocumentType Command -Name $_ 
}
<#
$AutomationDocs = @($RestartWindowsUpdateApprovalDoc, $RestartServiceDoc)

$AutomationDocs | % {
	$contents = Get-Content "../Documents/$($_).yml" -Raw
	New-SSMDocument -Content $contents -DocumentFormat YAML -DocumentType Automation -Name $_ 
}

#update agent to run session manager
$Target = New-Object Amazon.SimpleSystemsManagement.Model.Target          
$Target.Key = 'tag:Name'                                                  
$Target.Values = @('HRAppWindows') 

$CommandId = (Send-SSMCommand -DocumentName AWS-UpdateSSMAgent -Target $Target).CommandId

while(1){$Status = (Get-SSMCommandInvocation -CommandId $CommandId).Status;if ($Status -eq 'Success'){break;} sleep 2}              

# Create SSM Parameter Store entries
# Note: Secure string cannot be created using a cloud formation template
Write-SSMParameter -Name "DBString" -Description "DB string for connection" -Type String -Value "server=myserver.dns.domain"

Write-SSMParameter -Name "DBPassword" -Description "DB Password" -Type SecureString -Value "TestPassword"

#>