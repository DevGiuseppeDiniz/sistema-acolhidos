param(
    [string]$DatabasePath = ".\sistema-acolhidos.accdb",
    [string]$SourcePath = ".\vba_export"
)

$ErrorActionPreference = "Stop"

$dbPath = (Resolve-Path $DatabasePath).Path
$srcRoot = (Resolve-Path $SourcePath).Path

function Object-Name-FromFile([string]$path) {
    return [System.IO.Path]::GetFileNameWithoutExtension($path)
}

$access = New-Object -ComObject Access.Application
try {
    $access.OpenCurrentDatabase($dbPath)

    $groups = @(
        @{ Dir = "modules"; Type = 5; Pattern = "*.bas" },
        @{ Dir = "forms"; Type = 2; Pattern = "*.txt" },
        @{ Dir = "reports"; Type = 3; Pattern = "*.txt" },
        @{ Dir = "macros"; Type = 4; Pattern = "*.txt" }
    )

    foreach ($group in $groups) {
        $dir = Join-Path $srcRoot $group.Dir
        if (-not (Test-Path $dir)) { continue }
        foreach ($file in Get-ChildItem $dir -Filter $group.Pattern) {
            $name = Object-Name-FromFile $file.FullName
            try { $access.DoCmd.DeleteObject($group.Type, $name) } catch {}
            $access.LoadFromText($group.Type, $name, $file.FullName)
            Write-Host "imported $($group.Dir)/$name"
        }
    }
}
finally {
    if ($access.CurrentProject.FullName) { $access.CloseCurrentDatabase() }
    $access.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($access) | Out-Null
}
