param(
    [Parameter(Mandatory = $true)]
    [string]$Summary,

    [string]$Description = "",

    [string]$ProjectShortName = $env:YOUTRACK_PROJECT_SHORT_NAME,

    [string]$BaseUrl = $env:YOUTRACK_BASE_URL,

    [string]$Token = $env:YOUTRACK_TOKEN
)

$ErrorActionPreference = "Stop"

if (-not $BaseUrl) { throw "Defina YOUTRACK_BASE_URL. Ex.: https://dev-giuseppediniz.youtrack.cloud" }
if (-not $Token) { throw "Defina YOUTRACK_TOKEN com um token do YouTrack." }
if (-not $ProjectShortName) { throw "Defina YOUTRACK_PROJECT_SHORT_NAME. Ex.: SIS" }

$base = $BaseUrl.TrimEnd("/")
$uri = "$base/api/issues?fields=id,idReadable,summary,description,project(shortName,name)"

$headers = @{
    Authorization = "Bearer $Token"
    Accept = "application/json"
    "Content-Type" = "application/json;charset=UTF-8"
}

$body = @{
    project = @{
        shortName = $ProjectShortName
    }
    summary = $Summary
    description = $Description
} | ConvertTo-Json -Depth 10

$issue = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body

Write-Host "Issue criada: $($issue.idReadable) - $($issue.summary)"
Write-Host "$base/issue/$($issue.idReadable)"

