param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Z]+-\d+$')]
    [string]$IssueId,

    [Parameter(Mandatory = $true)]
    [string]$Version,

    [Parameter(Mandatory = $true)]
    [string]$DatabasePath,

    [string]$GitHubRepository = $env:GITHUB_REPOSITORY,
    [string]$GitHubToken = $env:GITHUB_TOKEN_FOR_RELEASES,
    [string]$YouTrackBaseUrl = $env:YOUTRACK_BASE_URL,
    [string]$YouTrackToken = $env:YOUTRACK_TOKEN
)

$ErrorActionPreference = "Stop"

if (-not $GitHubRepository) { throw "Defina GITHUB_REPOSITORY. Ex.: DevGiuseppeDiniz/sistema-acolhidos" }
if (-not $GitHubToken) { throw "Defina GITHUB_TOKEN_FOR_RELEASES com permissao Contents: Read and write." }
if (-not $YouTrackBaseUrl) { throw "Defina YOUTRACK_BASE_URL." }
if (-not $YouTrackToken) { throw "Defina YOUTRACK_TOKEN." }

$db = Resolve-Path $DatabasePath
$tag = "v$Version"
$fileName = "sistema-acolhidos-$Version.accdb"
$releaseName = "Sistema Acolhidos $Version"

function Invoke-GitHubApi([string]$Method, [string]$Path, $Body = $null) {
    $headers = @{
        Authorization = "Bearer $GitHubToken"
        Accept = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
        "User-Agent" = "sistema-acolhidos-release-bot"
    }
    $uri = "https://api.github.com" + $Path
    if ($Body -ne $null) {
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -Body ($Body | ConvertTo-Json -Depth 20) -ContentType "application/json"
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

function Invoke-YouTrackApi([string]$Method, [string]$Path, $Body = $null) {
    $headers = @{
        Authorization = "Bearer $YouTrackToken"
        Accept = "application/json"
        "Content-Type" = "application/json;charset=UTF-8"
    }
    $uri = $YouTrackBaseUrl.TrimEnd("/") + $Path
    if ($Body -ne $null) {
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -Body ($Body | ConvertTo-Json -Depth 20)
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

$releaseBody = @{
    tag_name = $tag
    target_commitish = "main"
    name = $releaseName
    body = "Entrega referente a $IssueId.`n`nArquivo Access final anexado nesta release."
    draft = $false
    prerelease = $false
}

$release = Invoke-GitHubApi -Method "Post" -Path "/repos/$GitHubRepository/releases" -Body $releaseBody
$uploadUrl = $release.upload_url -replace '\{\?name,label\}', "?name=$([System.Uri]::EscapeDataString($fileName))"

$headers = @{
    Authorization = "Bearer $GitHubToken"
    Accept = "application/vnd.github+json"
    "Content-Type" = "application/octet-stream"
    "X-GitHub-Api-Version" = "2022-11-28"
}
Invoke-RestMethod -Method Post -Uri $uploadUrl -Headers $headers -InFile $db.Path | Out-Null

$releaseUrl = $release.html_url
$comment = @{
    text = "Nova versao disponivel para teste/uso: [$releaseName]($releaseUrl)`n`nArquivo: $fileName"
}
Invoke-YouTrackApi -Method "Post" -Path "/api/issues/$IssueId/comments?fields=id,text" -Body $comment | Out-Null

Write-Host "Release criada: $releaseUrl"
Write-Host "YouTrack atualizado: $IssueId"
