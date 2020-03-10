Clear-Host

[string] $salesforceUsername = $args[0]
[string] $salesforcePassword = $args[1]
[string] $applicationGuid = $args[2]
[string] $applicationVersion = $args[3]
[string] $compatibleRelativityVersion = $args[4]
[string] $rapFilePath = $args[5]


[string] $server = 'solutionsnapshotdevapi.azurewebsites.net'
[string] $uploadApplicationVersionFileAsyncUrl = "https://$($server)/api/external/UploadApplicationVersionFileAsync"
[string] $createApplicationVersionAsyncUrl = "https://$($server)/api/external/CreateApplicationVersionAsync"
[string] $readApplicationAsyncUrl = "https://$($server)/api/external/ReadApplicationAsync"

[string] $solutionSnapshotSalesforceLoginHelperDllPath = "$PSScriptRoot\ExternalDevPipelineRepo\packages\RelativityDev.SolutionSnapshotLoginHelper.1.0.2\lib\net462\SolutionSnapshotSalesforceLoginHelper.dll"

$global:salesforceSessionObject = $null

function Write-Empty-Message() {
  Write-Host ""
}

function Write-Method-Call-Message($message) {
  Write-Empty-Message
  Write-Host -ForegroundColor Cyan $message
}

function Write-Message($message) {
  Write-Empty-Message
  Write-Host -ForegroundColor Green $message
}

function Write-Error-Message($message) {
  Write-Empty-Message
  Write-Host -ForegroundColor Red $message
}

function GetSessionId() {
  try {
	Write-Message $solutionSnapshotSalesforceLoginHelperDllPath
    [Reflection.Assembly]::LoadFile($solutionSnapshotSalesforceLoginHelperDllPath)
    $salesforceSessionHelper = New-Object SolutionSnapshotSalesforceLoginHelper.SalesforceSessionHelper
	  
    Write-Method-Call-Message "Calling method to get SalesforceSessionInfo"
    $salesforcesessioninfo = $salesforceSessionHelper.GetSalesforceSessionInfo($salesforceUsername, $salesforcePassword)
    $global:salesforceSessionObject = new-object psobject
    $global:salesforceSessionObject | add-member noteproperty salesforceuserid $salesforcesessioninfo.salesforceuserid
    $global:salesforceSessionObject | add-member noteproperty sessionid $salesforcesessioninfo.sessionid
    $global:salesforceSessionObject | add-member noteproperty serverurl $salesforcesessioninfo.serverurl
  }
  catch {
    Write-Error-Message "An error occured when retrieving SalesforceSessionInfo."    
    Write-Error-Message "Error Message: ($_)"
  }
}

function CreateApplicationVersionAsync() {
  try {
    Write-Method-Call-Message "Calling CreateApplicationVersionAsync API"
    $request = new-object psobject
    $request | add-member noteproperty SalesforceSessionInfo $global:salesforceSessionObject
    $request | add-member noteproperty ApplicationGuid $applicationGuid
    $request | add-member noteproperty Version $applicationVersion
    $request | add-member noteproperty ReleaseNotes 'New Release from Azure Devops Pipeline'
       
    $relativityVersionArray = @()
    $relativityVersionObject1 = new-object psobject
    $relativityVersionObject1 | add-member noteproperty Version $compatibleRelativityVersion
    $relativityVersionArray += $relativityVersionObject1

    $request | add-member noteproperty RelativityVersions $relativityVersionArray
    $requestJson = $request | ConvertTo-Json

    $response = Invoke-RestMethod -Uri $createApplicationVersionAsyncUrl -Method Post -Body $requestJson -ContentType 'application/json' -Headers @{"x-csrf-header"="-"}
    $responseJson = $response | ConvertTo-Json
    Write-Message "Created New Application Version"
  }
  catch {
	if($_.ToString().Contains('Application Version already exists')){
		Write-Error-Message "Application Version already exists"
	}
	else{
		Write-Error-Message "An error occured when calling CreateApplicationVersionAsync API."
		Write-Error-Message "Error Message: ($_)"
		# Dig into the exception to get the Response details. Note that value__ is not a typo.
		Write-Error-Message "Http Status Code: $($_.Exception.Response.StatusCode.value__)"
		Write-Error-Message "Http Status Description: $($_.Exception.Response.StatusDescription)"
		$responseJson = $_.Exception.Response | ConvertTo-Json
		Write-Error-Message "Response Json: $($responseJson)"
	}
  }  
}

function UploadApplicationVersionFileAsync() {
  Param(
    [parameter(Mandatory=$true,
    ParameterSetName="FilePath")]
    [String[]]
    $FilePath,

    [parameter(Mandatory=$true)]
    [String[]]
    $ApplicationGuid,

    [parameter(Mandatory=$true)]
    [String[]]
    $ApplicationVersion,

    [parameter(Mandatory=$true)]
    [String[]]
    $SalesforceUserId,

    [parameter(Mandatory=$true)]
    [String[]]
    $SessionId,

    [parameter(Mandatory=$true)]
    [String[]]
    $ServerUrl
)

$fileName = Split-Path $FilePath -leaf
$fileBin = [System.IO.File]::ReadAllBytes($FilePath)

# Convert byte-array to string
$enc = [System.Text.Encoding]::GetEncoding($codePage)

$fileEnc = $enc.GetString($fileBin)

# We need a boundary (something random() will do best)
$boundary = [System.Guid]::NewGuid().ToString()

# Linefeed character
$LF = "`r`n"

# Build Body for our form-data manually since PS does not support multipart/form-data out of the box
  $bodyLines = (
      
    "--$boundary",

    "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"",

    "Content-Type: application/octet-stream$LF",

    $fileEnc,

    "--$boundary",

    "Content-Disposition: form-data; name=`"ApplicationGuid`";",

    "Content-Type: text/plain$LF",

    "$ApplicationGuid",

    "--$boundary",

    "Content-Disposition: form-data; name=`"Version`";",

    "Content-Type: text/plain$LF",

    "$ApplicationVersion",

    "--$boundary",

    "Content-Disposition: form-data; name=`"SalesforceUserId`";",

    "Content-Type: text/plain$LF",

    "$SalesforceUserId",

    "--$boundary",

    "Content-Disposition: form-data; name=`"SessionId`";",

    "Content-Type: text/plain$LF",

    "$SessionId",

    "--$boundary",

    "Content-Disposition: form-data; name=`"ServerUrl`";",

    "Content-Type: text/plain$LF",

    "$ServerUrl",
    
    "--$boundary--$LF"
   ) -join $LF

  try {
	  Write-Method-Call-Message "Calling UploadApplicationVersionFileAsync API" 
		
      # Submit form-data with Invoke-RestMethod-Cmdlet
      Invoke-RestMethod -Uri $uploadApplicationVersionFileAsyncUrl -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines -Credential $cred -Headers @{"x-csrf-header"="-"}
	  
	  Write-Message "Uploaded Application Version Rap File"
  }
	  # In case of emergency...
	  catch [System.Net.WebException] {
      Write-Error( "REST-API-Call failed for '$URL': $_" )
      throw $_
  } 
}

GetSessionId
CreateApplicationVersionAsync
UploadApplicationVersionFileAsync -FilePath $rapFilePath -ApplicationGuid $applicationGuid -ApplicationVersion $applicationVersion -SalesforceUserId $salesforceSessionObject.salesforceuserid -SessionId $salesforceSessionObject.sessionid -ServerUrl $salesforceSessionObject.serverurl