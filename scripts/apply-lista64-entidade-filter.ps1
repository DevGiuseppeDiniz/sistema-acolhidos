param(
    [Parameter(Mandatory = $true)]
    [string]$DatabasePath,

    [string]$ExportPath = ".\vba_export"
)

$ErrorActionPreference = "Stop"

$dbFullPath = (Resolve-Path $DatabasePath).Path
$exportFullPath = (Resolve-Path $ExportPath).Path
$modulePath = Join-Path $exportFullPath "modules\Mod_FiltroLista64Entidade.bas"

if (-not (Test-Path -LiteralPath $modulePath)) {
    throw "Modulo VBA nao encontrado: $modulePath"
}

function Upsert-Query {
    param(
        [object]$Database,
        [string]$Name,
        [string]$Sql
    )

    try {
        $query = $Database.QueryDefs.Item($Name)
        $query.SQL = $Sql
    } catch {
        [void]$Database.CreateQueryDef($Name, $Sql)
    }
}

function Set-ControlProperty {
    param(
        [object]$Control,
        [string]$PropertyName,
        [object]$Value
    )

    try {
        $Control.Properties.Item($PropertyName).Value = $Value
    } catch {
        [void]$Control.Properties.Add($PropertyName, $Value)
    }
}

$queriesToUpdate = @{
    "Destituições atrasadas" = @"
SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.DataDesacolhimento, CadastroAcolhidos.NDestituicao, CadastroAcolhidos.DataInicioDest, CadastroAcolhidos.DataDestituição
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.DataDesacolhimento) Is Null) AND ((CadastroAcolhidos.DataInicioDest)<Date()-120) AND ((CadastroAcolhidos.DataDestituição) Is Null));
"@
    "Consulta Destituições em Andamento" = @"
SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.DataDesacolhimento, CadastroAcolhidos.DataInicioDest, CadastroAcolhidos.DataDestituição, CadastroAcolhidos.NDestituicao
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.DataDesacolhimento) Is Null) AND ((CadastroAcolhidos.DataDestituição) Is Null) AND ((CadastroAcolhidos.NDestituicao) Is Not Null And (CadastroAcolhidos.NDestituicao)<>""));
"@
    "Consulta VISITAS INDEFERIDAS" = @"
SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.MaeAcolhido, CadastroAcolhidos.NPedProv, CadastroAcolhidos.NDestituicao, fncPeriodoAcolhimento(Nz([DataAcolhimento],0)) AS [Periodo Acolhimento], CadastroAcolhidos.DECVisitas, CadastroAcolhidos.AUTORIZAVisitas, CadastroAcolhidos.DataDesacolhimento
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.DECVisitas)="SIM") AND ((CadastroAcolhidos.AUTORIZAVisitas)="NÃO") AND ((CadastroAcolhidos.DataDesacolhimento) Is Null));
"@
    "Consulta VISITAS SEM DECISAO" = @"
SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.MaeAcolhido, CadastroAcolhidos.NPedProv, CadastroAcolhidos.NDestituicao, fncPeriodoAcolhimento(Nz([DataAcolhimento],0)) AS [Periodo Acolhimento], CadastroAcolhidos.DECVisitas, CadastroAcolhidos.DataAcolhimento, CadastroAcolhidos.DataDesacolhimento
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.DECVisitas)="NÃO") AND ((CadastroAcolhidos.DataAcolhimento)<Date()-15) AND ((CadastroAcolhidos.DataDesacolhimento) Is Null));
"@
    "ConsultaGERAL-Des-Acol" = @"
SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.MaeAcolhido, CadastroAcolhidos.DataAcolhimento, CadastroAcolhidos.DataDesacolhimento
FROM CadastroAcolhidos;
"@
    "ConsultaSEMVisitas6meses" = @"
SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.DataDesacolhimento, CadastroAcolhidos.AUTORIZAVisitas, CadastroAcolhidos.DataDecidVisitas, CadastroAcolhidos.DataAcolhimento, CadastroAcolhidos.DataDestituição, CadastroAcolhidos.NDestituicao
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.DataDesacolhimento) Is Null) AND ((CadastroAcolhidos.AUTORIZAVisitas)="Não") AND ((CadastroAcolhidos.DataAcolhimento)<Date()-180) AND ((CadastroAcolhidos.NDestituicao) Is Null));
"@
    "ConsultaSomenteDesacolhidos" = @"
SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.MaeAcolhido, CadastroAcolhidos.PaiAcolhido, CadastroAcolhidos.DataAcolhimento, CadastroAcolhidos.MotivoAcolhimento, CadastroAcolhidos.DataDesacolhimento, CadastroAcolhidos.MotivoDesacolhimento, CadastroAcolhidos.NPedProv, CadastroAcolhidos.AtualizacaoFicha
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.DataDesacolhimento)=[DataDesacolhimento]));
"@
    "Consulta Destituicoes sem Julgamento" = @"
SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.NDestituicao, CadastroAcolhidos.DataInicioDest, CadastroAcolhidos.DiasTramitaDest
FROM CadastroAcolhidos
GROUP BY CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.NDestituicao, CadastroAcolhidos.DataInicioDest, CadastroAcolhidos.DiasTramitaDest, CadastroAcolhidos.DataDesacolhimento, CadastroAcolhidos.DataDestituição
HAVING (((CadastroAcolhidos.NDestituicao)<>"") AND ((CadastroAcolhidos.DataDesacolhimento) Is Null) AND ((CadastroAcolhidos.DataDestituição) Is Null));
"@
    "ListaTodos" = @"
SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento
FROM CadastroAcolhidos;
"@
}

$formsToFilter = @(
    @{ Form = "Formulário Destituições Atrasadas"; BaseQuery = "Destituições atrasadas"; FilterQuery = "Q_Lista64_Entidade_DestituicoesAtrasadas" },
    @{ Form = "Formulário Destituições em Andamento"; BaseQuery = "Consulta Destituições em Andamento"; FilterQuery = "Q_Lista64_Entidade_DestituicoesAndamento" },
    @{ Form = "Formulário Processos Visitas Indeferidas 6M"; BaseQuery = "ConsultaSEMVisitas6meses"; FilterQuery = "Q_Lista64_Entidade_VisitasIndeferidas6M" },
    @{ Form = "Formulário de Cadastro GERAL-Des-Acol"; BaseQuery = "ConsultaGERAL-Des-Acol"; FilterQuery = "Q_Lista64_Entidade_GeralDesAcol" },
    @{ Form = "Formulário Cadastro de DESTITUIDOS"; BaseQuery = "Consulta Destituidos"; FilterQuery = "Q_Lista64_Entidade_Destituidos" },
    @{ Form = "Formulário Crianças SEM DESTITUIÇÕES"; BaseQuery = "CadastroSEMDestituicao"; FilterQuery = "Q_Lista64_Entidade_SemDestituicoes" },
    @{ Form = "Formulário de Cadastro de Desacolhidos"; BaseQuery = "ConsultaSomenteDesacolhidos"; FilterQuery = "Q_Lista64_Entidade_Desacolhidos" },
    @{ Form = "Cadastro de Acolhido"; BaseQuery = "ConsultaTodosAcolhidosEntidade"; FilterQuery = "Q_Lista64_Entidade_CadastroAcolhido" },
    @{ Form = "Cadastro de Acolhido - INCLUIDOS PARESCON"; BaseQuery = "Consulta inseridos PARESCON"; FilterQuery = "Q_Lista64_Entidade_IncluidosParescon" },
    @{ Form = "Cadastro de Acolhidos SEM DEC VISITAS"; BaseQuery = "Consulta VISITAS SEM DECISAO"; FilterQuery = "Q_Lista64_Entidade_SemDecVisitas" },
    @{ Form = "Formulário Processos Visitas INDEFERIDAS"; BaseQuery = "Consulta VISITAS INDEFERIDAS"; FilterQuery = "Q_Lista64_Entidade_VisitasIndeferidas" },
    @{ Form = "Formulário Cadastro de DESTITUIDOS COM TRANSITO"; BaseQuery = "Consulta Destituidos com transito"; FilterQuery = "Q_Lista64_Entidade_DestituidosTransito" }
)

$access = New-Object -ComObject Access.Application

try {
    $access.OpenCurrentDatabase($dbFullPath)
    $db = $access.CurrentDb()

    foreach ($entry in $queriesToUpdate.GetEnumerator()) {
        Upsert-Query $db $entry.Key $entry.Value
        Write-Host "Consulta atualizada: $($entry.Key)"
    }

    foreach ($item in $formsToFilter) {
        $sql = @"
SELECT Base.NomeAcolhido
FROM [$($item.BaseQuery)] AS Base
WHERE ([Forms]![$($item.Form)]![EntidadeAcolhimento] Is Null OR Base.EntidadeAcolhimento = [Forms]![$($item.Form)]![EntidadeAcolhimento])
ORDER BY Base.NomeAcolhido;
"@
        Upsert-Query $db $item.FilterQuery $sql
        Write-Host "Consulta filtro criada/atualizada: $($item.FilterQuery)"
    }

    try {
        $access.DoCmd.DeleteObject(5, "Mod_FiltroLista64Entidade")
    } catch {}
    $access.LoadFromText(5, "Mod_FiltroLista64Entidade", $modulePath)
    Write-Host "Modulo importado: Mod_FiltroLista64Entidade"

    foreach ($item in $formsToFilter) {
        $formName = $item.Form
        $access.DoCmd.OpenForm($formName, 1, $null, $null, 1, 1)
        $form = $access.Forms.Item($formName)

        Set-ControlProperty $form.Controls.Item("Lista64") "RowSource" $item.FilterQuery
        Set-ControlProperty $form.Controls.Item("EntidadeAcolhimento") "AfterUpdate" "=AtualizarLista64PorEntidade()"

        $access.DoCmd.Close(2, $formName, 1)
        Write-Host "Formulario atualizado: $formName"
    }

    $moduleExport = Join-Path $exportFullPath "modules\Mod_FiltroLista64Entidade.bas"
    if (Test-Path -LiteralPath $moduleExport) { Remove-Item -LiteralPath $moduleExport -Force }
    $access.SaveAsText(5, "Mod_FiltroLista64Entidade", $moduleExport)

    $formsDir = Join-Path $exportFullPath "forms"
    foreach ($item in $formsToFilter) {
        $formExport = Join-Path $formsDir ($item.Form + ".txt")
        $access.SaveAsText(2, $item.Form, $formExport)
    }

    $queriesCsv = Join-Path $exportFullPath "queries.csv"
    $queriesDir = Join-Path $exportFullPath "queries_sql"
    if (-not (Test-Path -LiteralPath $queriesDir)) {
        [void](New-Item -ItemType Directory -Path $queriesDir)
    }

    $queryRows = @()
    foreach ($queryDef in $db.QueryDefs) {
        if ($queryDef.Name.StartsWith("~")) { continue }
        $queryRows += [pscustomobject]@{
            Name = $queryDef.Name
            Type = $queryDef.Type
            SQL = $queryDef.SQL
        }

        $safeFile = ($queryDef.Name -replace '[\\/:*?"<>|]', '_') + ".sql"
        $sqlPath = Join-Path $queriesDir $safeFile
        Set-Content -LiteralPath $sqlPath -Value $queryDef.SQL -Encoding UTF8
    }
    $queryRows | Export-Csv -LiteralPath $queriesCsv -NoTypeInformation -Encoding UTF8
} finally {
    if ($access.CurrentProject.FullName) {
        $access.CloseCurrentDatabase()
    }
    $access.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($access) | Out-Null
}
