param(
    [string]$YouTrackBaseUrl = $env:YOUTRACK_BASE_URL,
    [string]$YouTrackToken = $env:YOUTRACK_TOKEN,
    [string]$YouTrackProject = $env:YOUTRACK_PROJECT_SHORT_NAME,
    [string]$GitHubRepository = $env:GITHUB_REPOSITORY,
    [string]$GitHubToken = $env:GITHUB_TOKEN_FOR_BRANCHES,
    [string]$BaseBranch = $env:BASE_BRANCH,
    [string]$ReadyState = $env:YOUTRACK_READY_STATE,
    [string]$BranchType = $env:BRANCH_TYPE,
    [string]$DryRun = $env:DRY_RUN,
    [string]$YouTrackQuery = $env:YOUTRACK_QUERY,
    [string]$Workspace = $env:GITHUB_WORKSPACE,
    [string]$GitHubRunId = $env:GITHUB_RUN_ID,
    [string]$GitHubServerUrl = $env:GITHUB_SERVER_URL
)

$ErrorActionPreference = "Stop"

if (-not $YouTrackBaseUrl) { throw "YOUTRACK_BASE_URL nao definido." }
if (-not $YouTrackToken) { throw "YOUTRACK_TOKEN nao definido." }
if (-not $YouTrackProject) { throw "YOUTRACK_PROJECT_SHORT_NAME nao definido." }
if (-not $GitHubRepository) { throw "GITHUB_REPOSITORY nao definido." }
if (-not $GitHubToken) { throw "GITHUB_TOKEN_FOR_BRANCHES nao definido." }
if (-not $BaseBranch) { $BaseBranch = "main" }
if (-not $ReadyState) { $ReadyState = "Ready for Dev" }
if (-not $BranchType) { $BranchType = "feature" }
if (-not $DryRun) { $DryRun = "false" }
if (-not $Workspace) { $Workspace = (Get-Location).Path }
if (-not $GitHubServerUrl) { $GitHubServerUrl = "https://github.com" }
$isDryRun = $DryRun.ToLowerInvariant() -in @("1", "true", "yes", "sim")
$payloadRoot = Join-Path $Workspace "_youtrack_payload"
New-Item -ItemType Directory -Force -Path $payloadRoot | Out-Null

function Convert-ToSlug([string]$value) {
    $normalized = $value.ToLowerInvariant()
    $normalized = $normalized -replace '[áàãâä]', 'a'
    $normalized = $normalized -replace '[éèêë]', 'e'
    $normalized = $normalized -replace '[íìîï]', 'i'
    $normalized = $normalized -replace '[óòõôö]', 'o'
    $normalized = $normalized -replace '[úùûü]', 'u'
    $normalized = $normalized -replace '[ç]', 'c'
    $normalized = $normalized -replace '[^a-z0-9]+', '-'
    $normalized = $normalized.Trim('-')
    if ($normalized.Length -gt 55) {
        $normalized = $normalized.Substring(0, 55).Trim('-')
    }
    if (-not $normalized) { $normalized = "task" }
    return $normalized
}

function Invoke-YouTrackApi(
    [string]$Method,
    [string]$Path,
    $Body = $null
) {
    $headers = @{
        Authorization = "Bearer $YouTrackToken"
        Accept = "application/json"
        "Content-Type" = "application/json;charset=UTF-8"
    }
    $uri = $YouTrackBaseUrl.TrimEnd("/") + $Path
    if ($Body -ne $null) {
        $json = $Body | ConvertTo-Json -Depth 20
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -Body $json
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

function Download-YouTrackFile([string]$RelativeUrl, [string]$DestinationPath) {
    $headers = @{
        Authorization = "Bearer $YouTrackToken"
        Accept = "application/octet-stream"
    }
    $uri = $YouTrackBaseUrl.TrimEnd("/") + $RelativeUrl
    Invoke-WebRequest -Uri $uri -Headers $headers -OutFile $DestinationPath
}

function Invoke-GitHubApi(
    [string]$Method,
    [string]$Path,
    $Body = $null
) {
    $headers = @{
        Authorization = "Bearer $GitHubToken"
        Accept = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
        "User-Agent" = "sistema-acolhidos-youtrack-branch-bot"
    }
    $uri = "https://api.github.com" + $Path
    if ($Body -ne $null) {
        $json = $Body | ConvertTo-Json -Depth 20
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -Body $json -ContentType "application/json"
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

function Get-IssueFieldValue($issue, [string]$fieldName) {
    foreach ($field in $issue.customFields) {
        if ($field.name -eq $fieldName) {
            if ($field.value -is [array]) {
                return ($field.value | ForEach-Object { $_.name }) -join ", "
            }
            if ($field.value.name) { return $field.value.name }
            if ($field.value.localizedName) { return $field.value.localizedName }
            return [string]$field.value
        }
    }
    return ""
}

function Test-BranchExists([string]$branchName) {
    try {
        Invoke-GitHubApi -Method "Get" -Path "/repos/$GitHubRepository/git/ref/heads/$branchName" | Out-Null
        return $true
    }
    catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 404) { return $false }
        throw
    }
}

Write-Host "Repositorio GitHub: $GitHubRepository"
Write-Host "Projeto YouTrack: $YouTrackProject"
Write-Host "Estado pesquisado: $ReadyState"
Write-Host "Branch base: $BaseBranch"
Write-Host "Dry run: $isDryRun"

if (-not $YouTrackQuery) {
    $YouTrackQuery = "project: {sistema-acolhidos} State: {$ReadyState}"
}

Write-Host "Query YouTrack: $YouTrackQuery"

$query = $YouTrackQuery
$encodedQuery = [System.Uri]::EscapeDataString($query)
$fields = "id,idReadable,summary,customFields(name,value(name,localizedName)),attachments(id,name,size,extension,mimeType,url)"
$issues = Invoke-YouTrackApi -Method "Get" -Path "/api/issues?query=$encodedQuery&fields=$fields&`$top=25"

if (-not $issues -or $issues.Count -eq 0) {
    Write-Host "Nenhuma issue encontrada para a busca: $query"
    exit 0
}

Write-Host "Issues encontradas: $($issues.Count)"

$baseRef = Invoke-GitHubApi -Method "Get" -Path "/repos/$GitHubRepository/git/ref/heads/$BaseBranch"
$baseSha = $baseRef.object.sha

foreach ($issue in $issues) {
    $issueId = $issue.idReadable
    $branchName = "$BranchType/$issueId-$(Convert-ToSlug $issue.summary)"
    $issuePayloadDir = Join-Path $payloadRoot $issueId
    Write-Host "Processando $issueId => $branchName"

    $baseAttachments = @()
    foreach ($attachment in $issue.attachments) {
        $extension = ([string]$attachment.extension).ToLowerInvariant()
        if ($extension -in @("accdb", "accde", "zip", "7z")) {
            $baseAttachments += $attachment
        }
    }

    if ($baseAttachments.Count -eq 0) {
        Write-Host "Aviso: $issueId nao possui anexo .accdb/.accde/.zip/.7z."
    }
    else {
        New-Item -ItemType Directory -Force -Path $issuePayloadDir | Out-Null
        foreach ($attachment in $baseAttachments) {
            $safeName = $attachment.name -replace '[\\/:*?"<>|]', '_'
            $dest = Join-Path $issuePayloadDir $safeName
            if ($isDryRun) {
                Write-Host "Dry run: baixaria anexo $($attachment.name) para $dest"
            }
            else {
                Download-YouTrackFile -RelativeUrl $attachment.url -DestinationPath $dest
                Write-Host "Anexo baixado: $dest"
            }
        }
    }

    if (Test-BranchExists $branchName) {
        Write-Host "Branch ja existe: $branchName"
        continue
    }

    if ($isDryRun) {
        Write-Host "Dry run: criaria a branch $branchName a partir de $BaseBranch ($baseSha)"
        continue
    }

    $body = @{
        ref = "refs/heads/$branchName"
        sha = $baseSha
    }

    Invoke-GitHubApi -Method "Post" -Path "/repos/$GitHubRepository/git/refs" -Body $body | Out-Null

    $branchUrl = "https://github.com/$GitHubRepository/tree/$branchName"
    $runUrl = if ($GitHubRunId) { "$GitHubServerUrl/$GitHubRepository/actions/runs/$GitHubRunId" } else { "" }
    $text = "Branch criada automaticamente para desenvolvimento: [$branchName]($branchUrl)"
    if ($runUrl) {
        $text += "`n`nBase anexada, quando houver, foi baixada como artifact do workflow: $runUrl"
    }
    $commentBody = @{
        text = $text
    }
    Invoke-YouTrackApi -Method "Post" -Path "/api/issues/$issueId/comments?fields=id,text" -Body $commentBody | Out-Null

    Write-Host "Branch criada para ${issueId}: $branchName"
}
