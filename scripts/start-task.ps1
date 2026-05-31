param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Z]+-\d+$')]
    [string]$IssueId,

    [Parameter(Mandatory = $true)]
    [string]$Title,

    [ValidateSet("feature", "bugfix", "chore", "docs", "hotfix")]
    [string]$Type = "feature"
)

$ErrorActionPreference = "Stop"

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
    return $normalized
}

$slug = Convert-ToSlug $Title
$branch = "$Type/$IssueId-$slug"

git status --short | Out-String | ForEach-Object {
    if ($_.Trim().Length -gt 0) {
        throw "Existem alteracoes locais. Commit, stash ou descarte antes de criar uma nova branch."
    }
}

git checkout main
git pull --ff-only
git checkout -b $branch

Write-Host "Branch criada: $branch"
Write-Host "Use commits no formato: $IssueId <mensagem>"
