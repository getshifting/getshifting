# Introduction

Use this extension to send email from your pipeline without a SMTP server. It uses the [Microsoft Graph API](https://developer.microsoft.com/en-us/graph) to send email.

## Requirements

To use the extension you need an active business Office 365 license that includes the use of Exchange Online, and Exchange online must be configured.

## Create Azure Enterprise Application

## Create the App and get the Client ID

* Go to portal.azure.com and login with an administrative account
* Go to Microsoft Entra ID -> App Registrations -> All Applications
* Click on + New Registration
* Name: e.g. AzureDevOpsGraphEmail
* Supported account types: Accounts in this organizational directory only
* Redirect URI: Web
* Click Register and note the Application (Client) ID. *This is the Client ID*

## Get the Client Secret

* Click Certificates & Secrets -> Client Secrets -> New client secret
* Description: e.g. AzureDevOpsGraphEmail
* Expires: Set this to what you prefer, a year is usually sufficient.
* Click Add
* Note the secret value. *This is the Client Secret*

## Assign Permissions to the App

* Go to API Permissions
* Add a Permission -> Microsoft Graph
* Application Permissions
* Mail.Send (Send mail as any user) -> Add Permissions
* Click Grant admin consent for 'Organization'

## Get the Tenant Domain

* Now go to Microsoft Entra ID -> Custom domain names
* Check the domain which is primary. *This is the Tenant Domain*

## From email

The email address you're sending from must exist, and it can be a shared mailbox. Emails that are sent are added to the Sent Items folder from the configured mailbox.

## Yaml examples

This is an example with a multiline email:

```yaml
- task: GetShifting.GraphEmail.graph-email-build-task.GraphEmail@0
  displayName: "Send an email with subject Test mail from $(BUILD.DEFINITIONNAME)"
  inputs:
    To: "sjoerd@getshifting.com"
    BCC: "$(BUILD.REQUESTEDFOREMAIL)"
    From: "sjoerd@getshifting.com"
    Subject: "Test mail from $(BUILD.DEFINITIONNAME)"
    Body: |
      <h1>This is a testmail</h1>
      <p>You can use various variables within the body of the email, for example:</p>

      <ul>
      <li> Build ID: $(build.buildid) </li>
      <li> Build Directory: $(agent.builddirectory) </li>
      <li> Build Queued By: $(BUILD.QUEUEDBY) </li>
      <li> Agent Name: $(AGENT.NAME) </li>
      <li> Job Name: $(SYSTEM.JOBDISPLAYNAME) </li>
      <li> Task Name: $(SYSTEM.TASKDISPLAYNAME) </li>
      <li> Build Requested for: $(BUILD.REQUESTEDFOR) </li>
      <li> Commit Message: $(BUILD.SOURCEVERSIONMESSAGE) </li>
      </ul>

      Kind regards, <br>
      $(BUILD.REQUESTEDFOR)
    ClientID: "e5e6ce84-d241-4faf-97e0-d71a171f1adf"
    ClientSecret: "$(ClientSecret)"
    ShowClientSecret: false
    TenantDomain: getshifting.com
```

This is an example with a single line email:

```yaml
- task: GetShifting.GraphEmail.graph-email-build-task.GraphEmail@0
  displayName: "Send graph email with subject Testmail from $(BUILD.DEFINITIONNAME)"
  inputs:
    To: "sjoerd@getshifting.com"
    From: "sjoerd@getshifting.com"
    Subject: "Testmail from $(BUILD.DEFINITIONNAME)"
    Body: This is a short testmail
    ClientID: "$(ClientID)"
    ClientSecret: "$(ClientSecret)"
    TenantDomain: getshifting.com
```

## Release Notes

### 20251209.x.x

* Added [getting started support page](https://wiki.getshifting.com/azuredevopsextensionsendemailgraph)

### 20251124.x.x

* Added yaml examples
* Updated documentation with new links and naming

### 20220731.x.x

* Added release notes

### 20220728.x.x

* Added TLS 1.2 support

### 20191211.x.x

* Initial release

### More Resources

* [MS Graph - Register App](https://learn.microsoft.com/en-us/graph/auth-register-app-v2)
