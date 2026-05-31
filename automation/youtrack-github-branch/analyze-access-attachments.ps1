param(
    [string]$PayloadPath = "_youtrack_payload",
    [string]$ReferenceExportPath = "vba_export",
    [string]$OutputPath = "_youtrack_analysis"
)

$ErrorActionPreference = "Stop"

$payloadRoot = Join-Path (Get-Location) $PayloadPath
$referenceRoot = Join-Path (Get-Location) $ReferenceExportPath
$outputRoot = Join-Path (Get-Location) $OutputPath

New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null

$summaryLines = @()
$summaryLines += "# Analise De Bases Anexadas"
$summaryLines += ""
$summaryLines += "Gerado em: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$summaryLines += ""

if (-not (Test-Path $payloadRoot)) {
    $summaryLines += "Nenhum payload do YouTrack foi encontrado."
    $summaryLines | Set-Content -Encoding UTF8 (Join-Path $outputRoot "summary.md")
    exit 0
}

function Safe-Name([string]$name) {
    return ($name -replace '[\\/:*?"<>|]', '_')
}

function Export-AccessDatabase([string]$DatabasePath, [string]$DestinationPath) {
    New-Item -ItemType Directory -Force -Path $DestinationPath | Out-Null
    foreach ($dir in @("modules", "forms", "reports", "macros", "queries_sql")) {
        New-Item -ItemType Directory -Force -Path (Join-Path $DestinationPath $dir) | Out-Null
    }

    $access = New-Object -ComObject Access.Application
    try {
        $access.OpenCurrentDatabase($DatabasePath)
        $db = $access.CurrentDb()

        $groups = @(
            @{ Name = "modules"; Type = 5; Collection = $access.CurrentProject.AllModules; Ext = ".bas" },
            @{ Name = "forms"; Type = 2; Collection = $access.CurrentProject.AllForms; Ext = ".txt" },
            @{ Name = "reports"; Type = 3; Collection = $access.CurrentProject.AllReports; Ext = ".txt" },
            @{ Name = "macros"; Type = 4; Collection = $access.CurrentProject.AllMacros; Ext = ".txt" }
        )

        foreach ($group in $groups) {
            $dir = Join-Path $DestinationPath $group.Name
            foreach ($obj in $group.Collection) {
                $dest = Join-Path $dir ((Safe-Name $obj.Name) + $group.Ext)
                $access.SaveAsText($group.Type, $obj.Name, $dest)
            }
        }

        foreach ($qd in $db.QueryDefs) {
            if ($qd.Name.StartsWith("~") -or $qd.Name.StartsWith("MSys")) { continue }
            $dest = Join-Path (Join-Path $DestinationPath "queries_sql") ((Safe-Name $qd.Name) + ".sql")
            [System.IO.File]::WriteAllText($dest, $qd.SQL, [System.Text.Encoding]::UTF8)
        }
    }
    finally {
        if ($access.CurrentProject.FullName) { $access.CloseCurrentDatabase() }
        $access.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($access) | Out-Null
    }
}

function Compare-ExportTrees([string]$ReferencePath, [string]$CandidatePath, [string]$DiffPath) {
    New-Item -ItemType Directory -Force -Path $DiffPath | Out-Null

    $referenceFiles = @{}
    if (Test-Path $ReferencePath) {
        Get-ChildItem $ReferencePath -Recurse -File | ForEach-Object {
            $relative = $_.FullName.Substring((Resolve-Path $ReferencePath).Path.Length).TrimStart('\')
            $referenceFiles[$relative] = $_.FullName
        }
    }

    $candidateFiles = @{}
    Get-ChildItem $CandidatePath -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring((Resolve-Path $CandidatePath).Path.Length).TrimStart('\')
        $candidateFiles[$relative] = $_.FullName
    }

    $added = @()
    $removed = @()
    $changed = @()

    foreach ($relative in $candidateFiles.Keys) {
        if (-not $referenceFiles.ContainsKey($relative)) {
            $added += $relative
            continue
        }

        $refHash = (Get-FileHash $referenceFiles[$relative] -Algorithm SHA256).Hash
        $candHash = (Get-FileHash $candidateFiles[$relative] -Algorithm SHA256).Hash
        if ($refHash -ne $candHash) {
            $changed += $relative
            $diffFile = Join-Path $DiffPath ((Safe-Name $relative) + ".diff.txt")
            git diff --no-index -- $referenceFiles[$relative] $candidateFiles[$relative] *> $diffFile
        }
    }

    foreach ($relative in $referenceFiles.Keys) {
        if (-not $candidateFiles.ContainsKey($relative)) {
            $removed += $relative
        }
    }

    [PSCustomObject]@{
        Added = $added
        Removed = $removed
        Changed = $changed
    }
}

$workRoot = Join-Path $outputRoot "work"
New-Item -ItemType Directory -Force -Path $workRoot | Out-Null

$archives = Get-ChildItem $payloadRoot -Recurse -File | Where-Object { $_.Extension.ToLowerInvariant() -eq ".zip" }
foreach ($archive in $archives) {
    $dest = Join-Path $workRoot ("unzipped_" + (Safe-Name $archive.BaseName))
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Expand-Archive -LiteralPath $archive.FullName -DestinationPath $dest -Force
}

$candidateFiles = @()
$candidateFiles += Get-ChildItem $payloadRoot -Recurse -File -Include *.accdb,*.accde
$candidateFiles += Get-ChildItem $workRoot -Recurse -File -Include *.accdb,*.accde -ErrorAction SilentlyContinue
$candidateFiles = $candidateFiles | Sort-Object FullName -Unique

if (-not $candidateFiles -or $candidateFiles.Count -eq 0) {
    $summaryLines += "Nenhuma base .accdb/.accde encontrada nos anexos."
    $summaryLines | Set-Content -Encoding UTF8 (Join-Path $outputRoot "summary.md")
    exit 0
}

foreach ($candidate in $candidateFiles) {
    $candidateName = Safe-Name $candidate.BaseName
    $exportPath = Join-Path $outputRoot ("exports\" + $candidateName)
    $diffPath = Join-Path $outputRoot ("diffs\" + $candidateName)

    $summaryLines += "## $($candidate.Name)"
    $summaryLines += ""
    $summaryLines += "Caminho: $($candidate.FullName)"
    $summaryLines += ""

    try {
        Export-AccessDatabase -DatabasePath $candidate.FullName -DestinationPath $exportPath
        $result = Compare-ExportTrees -ReferencePath $referenceRoot -CandidatePath $exportPath -DiffPath $diffPath

        $summaryLines += ("- Adicionados: $($result.Added.Count)")
        $summaryLines += ("- Alterados: $($result.Changed.Count)")
        $summaryLines += ("- Removidos: $($result.Removed.Count)")
        $summaryLines += ""

        if ($result.Added.Count -gt 0) {
            $summaryLines += "### Arquivos adicionados"
            $result.Added | ForEach-Object { $summaryLines += ("- $_") }
            $summaryLines += ""
        }
        if ($result.Changed.Count -gt 0) {
            $summaryLines += "### Arquivos alterados"
            $result.Changed | ForEach-Object { $summaryLines += ("- $_") }
            $summaryLines += ""
        }
        if ($result.Removed.Count -gt 0) {
            $summaryLines += "### Arquivos removidos"
            $result.Removed | ForEach-Object { $summaryLines += ("- $_") }
            $summaryLines += ""
        }
    }
    catch {
        $summaryLines += "Falha ao analisar esta base: $($_.Exception.Message)"
        $summaryLines += ""
    }
}

$summaryLines | Set-Content -Encoding UTF8 (Join-Path $outputRoot "summary.md")
