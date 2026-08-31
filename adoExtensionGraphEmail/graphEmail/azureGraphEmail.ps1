# Using SDK
# https://github.com/microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/Commands.md#get-vstsinput
# Get-VstsInput -Name <String> [-Require] [-AsBool] [-AsInt] [<CommonParameters>]
# Get-VstsInput -Name <String> [-Default <Object>] [-AsBool] [-AsInt] [<CommonParameters>]
[CmdletBinding()]
param()

#Trace-VstsEnteringInvocation $MyInvocation
try {
  Import-VstsLocStrings "$PSScriptRoot\Task.json"

  # Get task variables.
  [bool]$debug = Get-VstsTaskVariable -Name System.Debug -AsBool

  # Get the inputs.
  [string]$To = Get-VstsInput -name To -Require
  [string]$Cc = Get-VstsInput -name Cc
  [string]$Bcc = Get-VstsInput -name Bcc
  [string]$From = Get-VstsInput -name From -Require
  [string]$Subject = Get-VstsInput -name Subject -Require
  [string]$Body = Get-VstsInput -Name Body -Require
  [bool]$BodyAsHtml = Get-VstsInput -name BodyAsHTML -AsBool
  [string]$ClientID = Get-VstsInput -name ClientID -Require
  [string]$ClientSecret = Get-VstsInput -name ClientSecret -Require
  [bool]$ShowClientSecret = Get-VstsInput -name ShowClientSecret -AsBool
  [string]$TenantDomain = Get-VstsInput -name TenantDomain -Require
}
catch {
  Write-Host "##vso[task.LogIssue type=error;]$env:TASK_DISPLAYNAME - Something went wrong with getting the input parameters";
  Write-Host "##vso[task.LogIssue type=error;]$env:TASK_DISPLAYNAME - Error message: $($_.Exception.Message)";
  exit 1
}

### Check Input ###
try {
  Write-Host "Check input parameters email"
  Write-Host "To: $To"
  Write-Host "Cc: $Cc"
  Write-Host "Bcc: $Bcc"
  Write-Host "From: $From"
  Write-Host "Subject: $Subject"
  Write-Host "Body: $Body"
  if ($BodyAsHtml -eq "True") { $emailtype = "html" }else { $emailtype = "text" }
  Write-Host "HTML: $BodyAsHtml"
}
catch {
  Write-Host "##vso[task.LogIssue type=error;]$env:TASK_DISPLAYNAME - Something went wrong with the input parameters";
  Write-Host "##vso[task.LogIssue type=error;]$env:TASK_DISPLAYNAME - Error message: $($_.Exception.Message)";
  exit 1
}

### Check Input ###
try {
  Write-Host "Check Azure Enterprise Application details"
  Write-Host "ClientID: $ClientID"
  if ($ShowClientSecret -eq "True") { Write-Host "Client Secret: $ClientSecret" }else { Write-Host "Client Secret: Hidden" }
  Write-Host "Tenant Domain: $TenantDomain"
}
catch {
  Write-Host "##vso[task.LogIssue type=error;]$env:TASK_DISPLAYNAME - Something went wring with the Azure Application parameters";
  Write-Host "##vso[task.LogIssue type=error;]$env:TASK_DISPLAYNAME - Error message: $($_.Exception.Message)";
  exit 1
}

### Start Graph Connection ###
try {
  # Set TLS version to use TLS 1.2
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $bodyGraph = @{grant_type = "client_credentials"; scope = "https://graph.microsoft.com/.default"; client_id = $ClientID; client_secret = $ClientSecret }
  $oauthGraph = Invoke-RestMethod -Method Post -Uri https://login.microsoftonline.com/$tenantdomain/oauth2/v2.0/token -Body $bodygraph
  if ($debug) { Write-Host "OauthGraph: $oauthGraph" }
}
catch {
  Write-Host "##vso[task.LogIssue type=error;]$env:TASK_DISPLAYNAME - Something went wrong with the Graph connection";
  Write-Host "##vso[task.LogIssue type=error;]$env:TASK_DISPLAYNAME - Error message: $($_.Exception.Message)";
  exit 1
}

### Create proper JSON email format
try {
  #$to = $to -split ","
  $tosplit = @($to.Split(','))
  $ToinJSON = $tosplit | % { '{"EmailAddress": {"Address": "' + $_ + '"}},' }
  $ToinJSON = ([string]$ToinJSON).Substring(0, ([string]$ToinJSON).Length - 1)

  if (![string]::IsNullOrEmpty($cc)) {
    if ($debug) { Write-Host "cc not empty, start json format" }
    #$cc = $cc -split ","
    $ccsplit = @($cc.Split(','))
    $CCinJSON = $ccsplit | % { '{"EmailAddress": {"Address": "' + $_ + '"}},' }
    $CCinJSON = ([string]$CCinJSON).Substring(0, ([string]$CCinJSON).Length - 1)
  }
  else {
    $CCinJSON = ""
  }

  if (![string]::IsNullOrEmpty($bcc)) {
    if ($debug) { Write-Host "bcc not empty, start json format" }
    #$bcc = $bcc -split ","
    $bccsplit = @($bcc.Split(','))
    $BCCinJSON = $bccsplit | % { '{"EmailAddress": {"Address": "' + $_ + '"}},' }
    $BCCinJSON = ([string]$BCCinJSON).Substring(0, ([string]$BCCinJSON).Length - 1)
  }
  else {
    $BCCinJSON = ""
  }
  if ($debug) { Write-Host "To: $to" }
  if ($debug) { Write-Host "ToSplit: $tosplit" }
  if ($debug) { Write-Host "ToJson: $ToinJSON" }
  if ($debug) { Write-Host "CC: $cc" }
  if ($debug) { Write-Host "CCSplit: $ccsplit" }
  if ($debug) { Write-Host "CCJson: $CCinJSON" }
  if ($debug) { Write-Host "BCC: $bcc" }
  if ($debug) { Write-Host "BCCSplit: $bccsplit" }
  if ($debug) { Write-Host "BCCJson: $BCCinJSON" }
}
catch {
  Write-Host "##vso[task.LogIssue type=error;]$env:TASK_DISPLAYNAME - Something went wrong with email addresses to json format";
  Write-Host "##vso[task.LogIssue type=error;]$env:TASK_DISPLAYNAME - Error message: $($_.Exception.Message)";
  exit 1
}


### Create email in JSON format ###
try {
  $reqBody = '{
        "message": {
        "subject": "",
        "body": {
            "contentType": "",
            "content": ""
        },
        "toRecipients": [
            ToPlaceHolder
        ],
        "ccRecipients": [
            CCPlaceHolder
        ],
        "bccRecipients":[
            BCCPlaceHolder
        ],
        "replyTo":[

        ]
        }
    }'
  $reqBody = $reqBody -replace "ToPlaceholder", $ToinJSON
  $reqBody = $reqBody -replace "BCCPlaceholder", $BCCinJSON
  $reqBody = $reqBody -replace "CCPlaceholder", $CCinJSON
  if ($debug) { Write-Host "Final Check reqBody Before JSON: $reqBody" }
  $reqBody = $reqBody | ConvertFrom-Json
  $reqBody.message.subject = $Subject
  $reqBody.message.body.contentType = $emailtype
  $reqBody.message.body.content = $Body
  if ($debug) { Write-Host "Final Check reqBody After JSON: $reqBody" }
}
catch {
  Write-Host "##vso[task.LogIssue type=error;]$env:TASK_DISPLAYNAME - Something went wrong with email creation";
  Write-Host "##vso[task.LogIssue type=error;]$env:TASK_DISPLAYNAME - Error message: $($_.Exception.Message)";
  exit 1
}

### Send email ###
try {
  Invoke-RestMethod -Method Post -Uri "https://graph.microsoft.com/v1.0/users/$($From)/sendMail" -Headers @{'Authorization' = "$($oauthgraph.token_type) $($oauthgraph.access_token)"; 'Content-type' = "application/json" } -Body ($reqBody | ConvertTo-Json -Depth 4 | Out-String)
}
catch {
  Write-Host "##vso[task.LogIssue type=error;]$env:TASK_DISPLAYNAME - Something went wrong with sending email";
  Write-Host "##vso[task.LogIssue type=error;]$env:TASK_DISPLAYNAME - Error message: $($_.Exception.Message)";
  exit 1
}
