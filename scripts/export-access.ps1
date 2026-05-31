param(
    [string]$DatabasePath = ".\sistema-acolhidos.accdb",
    [string]$OutputPath = ".\vba_export"
)

$ErrorActionPreference = "Stop"

$dbPath = (Resolve-Path $DatabasePath).Path
$outRoot = Join-Path (Get-Location) $OutputPath

New-Item -ItemType Directory -Force -Path $outRoot | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $outRoot "modules") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $outRoot "forms") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $outRoot "reports") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $outRoot "macros") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $outRoot "queries_sql") | Out-Null

function Safe-Name([string]$name) {
    return ($name -replace '[\\/:*?"<>|]', '_')
}

$access = New-Object -ComObject Access.Application
try {
    $access.OpenCurrentDatabase($dbPath)
    $db = $access.CurrentDb()

    $groups = @(
        @{ Name = "modules"; Type = 5; Collection = $access.CurrentProject.AllModules; Ext = ".bas" },
        @{ Name = "forms"; Type = 2; Collection = $access.CurrentProject.AllForms; Ext = ".txt" },
        @{ Name = "reports"; Type = 3; Collection = $access.CurrentProject.AllReports; Ext = ".txt" },
        @{ Name = "macros"; Type = 4; Collection = $access.CurrentProject.AllMacros; Ext = ".txt" }
    )

    foreach ($group in $groups) {
        $dir = Join-Path $outRoot $group.Name
        foreach ($obj in $group.Collection) {
            $dest = Join-Path $dir ((Safe-Name $obj.Name) + $group.Ext)
            $access.SaveAsText($group.Type, $obj.Name, $dest)
            Write-Host "exported $($group.Name)/$($obj.Name)"
        }
    }

    $queries = @()
    foreach ($qd in $db.QueryDefs) {
        if ($qd.Name.StartsWith("~") -or $qd.Name.StartsWith("MSys")) { continue }
        $queries += [PSCustomObject]@{
            Name = $qd.Name
            Type = $qd.Type
            SQL = $qd.SQL
        }
        $dest = Join-Path (Join-Path $outRoot "queries_sql") ((Safe-Name $qd.Name) + ".sql")
        [System.IO.File]::WriteAllText($dest, $qd.SQL, [System.Text.Encoding]::UTF8)
        Write-Host "exported queries_sql/$($qd.Name)"
    }

    $queries | Sort-Object Name | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $outRoot "queries.csv")
}
finally {
    if ($access.CurrentProject.FullName) { $access.CloseCurrentDatabase() }
    $access.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($access) | Out-Null
}
