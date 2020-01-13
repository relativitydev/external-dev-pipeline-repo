Clear-Host

[string] $salesforceUsername = $args[0]
[string] $salesforcePassword = $args[1]
[string] $applicationGuid = $args[2]
[string] $applicationVersion = $args[3]
[string] $rapFilePath = $args[4]


[string] $server = 'solutionsnapshotdevelopmentapi.azurewebsites.net'
[string] $uploadApplicationVersionFileAsyncUrl = "https://$($server)/api/external/UploadApplicationVersionFileAsync"
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
    [Reflection.Assembly]::LoadFile("$PSScriptRoot\SolutionSnapshotSalesforceLoginHelper.dll")
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
      # Submit form-data with Invoke-RestMethod-Cmdlet
      Invoke-RestMethod -Uri $uploadApplicationVersionFileAsyncUrl -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines -Credential $cred -Headers @{"x-csrf-header"="-"}
  }
  # In case of emergency...
  catch [System.Net.WebException] {
      Write-Error( "REST-API-Call failed for '$URL': $_" )
      throw $_
  } 
}


GetSessionId
UploadApplicationVersionFileAsync -FilePath $rapFilePath -ApplicationGuid $applicationGuid -ApplicationVersion $applicationVersion -SalesforceUserId $salesforceSessionObject.salesforceuserid -SessionId $salesforceSessionObject.sessionid -ServerUrl $salesforceSessionObject.serverurl