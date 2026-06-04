param(
    [Parameter(Mandatory = $true)]
    [string]$DatabasePath,

    [string]$ExportPath = ".\vba_export"
)

$ErrorActionPreference = "Stop"

$dbFullPath = (Resolve-Path $DatabasePath).Path
$exportFullPath = (Resolve-Path $ExportPath).Path
$modulePath = Join-Path $exportFullPath "modules\Mod_FiltrosLista64Popup.bas"

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
        Write-Warning "Propriedade de controle ignorada: $PropertyName"
    }
}

function Set-ObjectProperty {
    param(
        [object]$Object,
        [string]$PropertyName,
        [object]$Value
    )

    try {
        $Object.Properties.Item($PropertyName).Value = $Value
    } catch {
        Write-Warning "Propriedade de objeto ignorada: $PropertyName"
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
    @{ Form = "Formulário Destituições Atrasadas"; BaseQuery = "Destituições atrasadas" },
    @{ Form = "Formulário Destituições em Andamento"; BaseQuery = "Consulta Destituições em Andamento" },
    @{ Form = "Formulário Processos Visitas Indeferidas 6M"; BaseQuery = "ConsultaSEMVisitas6meses" },
    @{ Form = "Formulário de Cadastro GERAL-Des-Acol"; BaseQuery = "ConsultaGERAL-Des-Acol" },
    @{ Form = "Formulário Cadastro de DESTITUIDOS"; BaseQuery = "Consulta Destituidos" },
    @{ Form = "Formulário Crianças SEM DESTITUIÇÕES"; BaseQuery = "CadastroSEMDestituicao" },
    @{ Form = "Formulário de Cadastro de Desacolhidos"; BaseQuery = "ConsultaSomenteDesacolhidos" },
    @{ Form = "Cadastro de Acolhido"; BaseQuery = "ConsultaTodosAcolhidosEntidade" },
    @{ Form = "Cadastro de Acolhido - INCLUIDOS PARESCON"; BaseQuery = "Consulta inseridos PARESCON" },
    @{ Form = "Cadastro de Acolhidos SEM DEC VISITAS"; BaseQuery = "Consulta VISITAS SEM DECISAO" },
    @{ Form = "Formulário Processos Visitas INDEFERIDAS"; BaseQuery = "Consulta VISITAS INDEFERIDAS" },
    @{ Form = "Formulário Cadastro de DESTITUIDOS COM TRANSITO"; BaseQuery = "Consulta Destituidos com transito" }
)

$oldFilterQueries = @(
    "Q_Lista64_Entidade_DestituicoesAtrasadas",
    "Q_Lista64_Entidade_DestituicoesAndamento",
    "Q_Lista64_Entidade_VisitasIndeferidas6M",
    "Q_Lista64_Entidade_GeralDesAcol",
    "Q_Lista64_Entidade_Destituidos",
    "Q_Lista64_Entidade_SemDestituicoes",
    "Q_Lista64_Entidade_Desacolhidos",
    "Q_Lista64_Entidade_CadastroAcolhido",
    "Q_Lista64_Entidade_IncluidosParescon",
    "Q_Lista64_Entidade_SemDecVisitas",
    "Q_Lista64_Entidade_VisitasIndeferidas",
    "Q_Lista64_Entidade_DestituidosTransito"
)

$access = New-Object -ComObject Access.Application

try {
    $access.OpenCurrentDatabase($dbFullPath)
    $db = $access.CurrentDb()

    foreach ($entry in $queriesToUpdate.GetEnumerator()) {
        Upsert-Query $db $entry.Key $entry.Value
        Write-Host "Consulta base atualizada: $($entry.Key)"
    }

    foreach ($queryName in $oldFilterQueries) {
        try {
            $db.QueryDefs.Delete($queryName)
            Write-Host "Consulta antiga removida: $queryName"
        } catch {}
    }

    try { $access.DoCmd.DeleteObject(5, "Mod_FiltroLista64Entidade") } catch {}
    try { $access.DoCmd.DeleteObject(5, "Mod_FiltrosLista64Popup") } catch {}
    $access.LoadFromText(5, "Mod_FiltrosLista64Popup", $modulePath)
    Write-Host "Modulo importado: Mod_FiltrosLista64Popup"

    try { $access.DoCmd.DeleteObject(2, "FPopupFiltrosLista64") } catch {}
    $popup = $access.CreateForm()
    $popupName = $popup.Name

    $popup.Caption = "Filtros da lista"
    $popup.PopUp = $true
    $popup.Modal = $true
    $popup.AutoCenter = $true
    $popup.NavigationButtons = $false
    $popup.RecordSelectors = $false
    $popup.DividingLines = $false
    $popup.ScrollBars = 0
    $popup.Width = 7200
    $popup.Section(0).Height = 2520

    $title = $access.CreateControl($popupName, 100, 0, $null, $null, 360, 240, 5160, 360)
    $title.Name = "lblTitulo"
    $title.Caption = "Filtrar acolhidos da lista"
    $title.FontSize = 14
    $title.FontBold = $true

    $labelEntidade = $access.CreateControl($popupName, 100, 0, $null, $null, 360, 900, 1680, 300)
    $labelEntidade.Name = "lblEntidade"
    $labelEntidade.Caption = "Entidade:"

    $combo = $access.CreateControl($popupName, 111, 0, $null, $null, 2040, 840, 4320, 360)
    $combo.Name = "cmbFiltroEntidade"
    $combo.RowSourceType = "Table/Query"
    $combo.RowSource = "SELECT [Entidades de Acolhimento].[CódigoEntidade], [Entidades de Acolhimento].[NomeEntidade] FROM [Entidades de Acolhimento] ORDER BY [NomeEntidade];"
    $combo.ColumnCount = 2
    $combo.BoundColumn = 1
    $combo.ColumnWidths = "0;4320"
    $combo.LimitToList = $true

    $btnAplicar = $access.CreateControl($popupName, 104, 0, $null, $null, 2040, 1680, 1320, 420)
    $btnAplicar.Name = "cmdAplicar"
    $btnAplicar.Caption = "Aplicar"
    Set-ControlProperty $btnAplicar "OnClick" "=AplicarFiltroLista64Popup()"

    $btnLimpar = $access.CreateControl($popupName, 104, 0, $null, $null, 3480, 1680, 1320, 420)
    $btnLimpar.Name = "cmdLimpar"
    $btnLimpar.Caption = "Limpar"
    Set-ControlProperty $btnLimpar "OnClick" "=LimparFiltroLista64Popup()"

    $btnCancelar = $access.CreateControl($popupName, 104, 0, $null, $null, 4920, 1680, 1320, 420)
    $btnCancelar.Name = "cmdCancelar"
    $btnCancelar.Caption = "Cancelar"
    Set-ControlProperty $btnCancelar "OnClick" "=FecharPopupFiltrosLista64()"

    $access.DoCmd.Save(2, $popupName)
    $access.DoCmd.Close(2, $popupName, 1)
    $access.DoCmd.Rename("FPopupFiltrosLista64", 2, $popupName)
    Write-Host "Popup criado: FPopupFiltrosLista64"

    foreach ($item in $formsToFilter) {
        $formName = $item.Form
        $access.DoCmd.OpenForm($formName, 1, $null, $null, 1, 1)
        $form = $access.Forms.Item($formName)
        $lista = $form.Controls.Item("Lista64")
        $entidade = $form.Controls.Item("EntidadeAcolhimento")

        Set-ControlProperty $lista "RowSource" $item.BaseQuery
        Set-ControlProperty $entidade "AfterUpdate" ""

        try {
            $button = $form.Controls.Item("cmdFiltrarLista64")
        } catch {
            $buttonTop = [Math]::Max(120, [int]$lista.Top - 480)
            $buttonLeft = [int]$lista.Left
            $button = $access.CreateControl($formName, 104, 0, $null, $null, $buttonLeft, $buttonTop, 1680, 360)
            $button.Name = "cmdFiltrarLista64"
        }

        $button.Caption = "Filtrar lista"
        Set-ControlProperty $button "OnClick" "=AbrirPopupFiltrosLista64()"
        Set-ControlProperty $button "ControlTipText" "Filtrar os acolhidos exibidos na lista"
        $button.Visible = $true

        $access.DoCmd.Close(2, $formName, 1)
        Write-Host "Formulario atualizado: $formName"
    }

    $modulesDir = Join-Path $exportFullPath "modules"
    $formsDir = Join-Path $exportFullPath "forms"

    $access.SaveAsText(5, "Mod_FiltrosLista64Popup", (Join-Path $modulesDir "Mod_FiltrosLista64Popup.bas"))
    $access.SaveAsText(2, "FPopupFiltrosLista64", (Join-Path $formsDir "FPopupFiltrosLista64.txt"))

    foreach ($item in $formsToFilter) {
        $access.SaveAsText(2, $item.Form, (Join-Path $formsDir ($item.Form + ".txt")))
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
