param(
    [string]$DatabasePath = ".\sistema-acolhidos.accdb",
    [string]$OutputPath = ".\access_analysis"
)

$ErrorActionPreference = "Stop"

$dbPath = (Resolve-Path $DatabasePath).Path
$outRoot = Join-Path (Get-Location) $OutputPath
New-Item -ItemType Directory -Force -Path $outRoot | Out-Null

$access = New-Object -ComObject Access.Application
try {
    $access.OpenCurrentDatabase($dbPath)
    $db = $access.CurrentDb()

    $tables = @()
    $fields = @()
    $indexes = @()
    $relations = @()
    $queries = @()

    foreach ($td in $db.TableDefs) {
        if ($td.Name.StartsWith("MSys")) { continue }
        if (($td.Attributes -band 2) -ne 0) { continue }

        $tables += [PSCustomObject]@{
            Name = $td.Name
            Attributes = $td.Attributes
            SourceTableName = $td.SourceTableName
            Connect = if ($td.Connect) { "[linked]" } else { "" }
        }

        foreach ($f in $td.Fields) {
            $allowZero = $null; try { $allowZero = $f.AllowZeroLength } catch {}
            $default = $null; try { $default = $f.DefaultValue } catch {}
            $validationRule = $null; try { $validationRule = $f.ValidationRule } catch {}
            $validationText = $null; try { $validationText = $f.ValidationText } catch {}
            $fields += [PSCustomObject]@{
                Table = $td.Name
                Field = $f.Name
                Type = $f.Type
                Size = $f.Size
                Required = $f.Required
                AllowZeroLength = $allowZero
                DefaultValue = $default
                ValidationRule = $validationRule
                ValidationText = $validationText
            }
        }

        foreach ($idx in $td.Indexes) {
            $idxFields = @()
            foreach ($idxField in $idx.Fields) { $idxFields += $idxField.Name }
            $indexes += [PSCustomObject]@{
                Table = $td.Name
                Index = $idx.Name
                Fields = ($idxFields -join ", ")
                Primary = $idx.Primary
                Unique = $idx.Unique
                Required = $idx.Required
                IgnoreNulls = $idx.IgnoreNulls
            }
        }
    }

    foreach ($rel in $db.Relations) {
        if ($rel.Name.StartsWith("MSys")) { continue }
        $relFields = @()
        foreach ($f in $rel.Fields) { $relFields += ($f.Name + " -> " + $f.ForeignName) }
        $relations += [PSCustomObject]@{
            Name = $rel.Name
            Table = $rel.Table
            ForeignTable = $rel.ForeignTable
            Fields = ($relFields -join "; ")
            Attributes = $rel.Attributes
        }
    }

    foreach ($qd in $db.QueryDefs) {
        if ($qd.Name.StartsWith("~") -or $qd.Name.StartsWith("MSys")) { continue }
        $queries += [PSCustomObject]@{
            Name = $qd.Name
            Type = $qd.Type
            SQL = $qd.SQL
        }
    }

    $tables | Sort-Object Name | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $outRoot "tables.csv")
    $fields | Sort-Object Table, Field | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $outRoot "fields.csv")
    $indexes | Sort-Object Table, Index | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $outRoot "indexes.csv")
    $relations | Sort-Object Table, ForeignTable | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $outRoot "relations.csv")
    $queries | Sort-Object Name | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $outRoot "queries.csv")

    [PSCustomObject]@{
        Database = $dbPath
        Tables = $tables.Count
        Fields = $fields.Count
        Indexes = $indexes.Count
        Relations = $relations.Count
        Queries = $queries.Count
        GeneratedAt = (Get-Date).ToString("s")
    } | ConvertTo-Json | Set-Content -Encoding UTF8 (Join-Path $outRoot "summary.json")
}
finally {
    if ($access.CurrentProject.FullName) { $access.CloseCurrentDatabase() }
    $access.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($access) | Out-Null
}
