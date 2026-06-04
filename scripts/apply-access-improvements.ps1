param(
    [Parameter(Mandatory = $true)]
    [string]$DatabasePath
)

$ErrorActionPreference = "Stop"

$dbPath = (Resolve-Path $DatabasePath).Path
$modulePath = (Resolve-Path ".\vba_export\modules\Mod_FichasAcompanhamento.bas").Path

function Set-ControlProperty($obj, [string]$prop, $value) {
    try { $obj.Properties.Item($prop).Value = $value } catch {}
}

function Upsert-Query($db, [string]$name, [string]$sql) {
    try { $db.QueryDefs.Delete($name) } catch {}
    $db.CreateQueryDef($name, $sql) | Out-Null
}

$formsWithFichas = @(
    "Cadastro de Acolhido",
    "Cadastro de Acolhido - INCLUIDOS PARESCON",
    "Cadastro de Acolhidos SEM DEC VISITAS",
    "Formulário Cadastro de DESTITUIDOS",
    "Formulário Cadastro de DESTITUIDOS COM TRANSITO",
    "Formulário Crianças SEM DESTITUIÇÕES",
    "Formulário de Cadastro de Desacolhidos",
    "Formulário de Cadastro GERAL-Des-Acol",
    "Formulário Destituições Atrasadas",
    "Formulário Processos Visitas INDEFERIDAS",
    "Formulário Processos Visitas Indeferidas 6M"
)

$access = New-Object -ComObject Access.Application
try {
    $access.OpenCurrentDatabase($dbPath)
    $db = $access.CurrentDb()

    Upsert-Query $db "Q_TotalProcessosEmAndamento" @'
SELECT Count(*) AS TotalProcessos
FROM (
    SELECT DISTINCT NPedProv AS Processo
    FROM CadastroAcolhidos
    WHERE DataDesacolhimento Is Null
      AND NPedProv Is Not Null
      AND NPedProv <> ''
    UNION
    SELECT DISTINCT NDestituicao AS Processo
    FROM CadastroAcolhidos
    WHERE DataDesacolhimento Is Null
      AND NDestituicao Is Not Null
      AND NDestituicao <> ''
) AS Processos;
'@

    Upsert-Query $db "Q_TotalDestituicoesSemSentenca" @'
SELECT Count(*) AS TotalDestituicoes
FROM (
    SELECT DISTINCT NDestituicao
    FROM CadastroAcolhidos
    WHERE DataDesacolhimento Is Null
      AND DataDestituição Is Null
      AND NDestituicao Is Not Null
      AND NDestituicao <> ''
) AS Destituicoes;
'@

    Upsert-Query $db "Q_TotalMedidasSemDestituicao" @'
SELECT Count(*) AS TotalMedidas
FROM (
    SELECT DISTINCT NPedProv
    FROM CadastroAcolhidos
    WHERE DataDesacolhimento Is Null
      AND NPedProv Is Not Null
      AND NPedProv <> ''
      AND (NDestituicao Is Null OR NDestituicao = '')
) AS Medidas;
'@

    Upsert-Query $db "Q_TotalProcessosGeral" @'
SELECT Count(*) AS TotalProcessos
FROM (
    SELECT DISTINCT NPedProv AS Processo
    FROM CadastroAcolhidos
    WHERE NPedProv Is Not Null
      AND NPedProv <> ''
    UNION
    SELECT DISTINCT NDestituicao AS Processo
    FROM CadastroAcolhidos
    WHERE NDestituicao Is Not Null
      AND NDestituicao <> ''
) AS Processos;
'@

    try { $access.DoCmd.DeleteObject(5, "Mod_FichasAcompanhamento") } catch {}
    $access.LoadFromText(5, "Mod_FichasAcompanhamento", $modulePath)

    foreach ($formName in $formsWithFichas) {
        try {
            $access.DoCmd.OpenForm($formName, 1, "", "", 0, 1)
            $form = $access.Forms.Item($formName)
            $button = $form.Controls.Item("BotãoGeraFichas")
            Set-ControlProperty $button "OnClick" "=GerarFichasAcompanhamentoListaAtual()"
            Set-ControlProperty $button "Caption" "Gerar Fichas de Acompanhamento"
            $access.DoCmd.Close(2, $formName, 1)
            Write-Host "Botao fichas atualizado: $formName"
        }
        catch {
            Write-Host "Aviso: nao foi possivel atualizar botao em ${formName}: $($_.Exception.Message)"
            try { $access.DoCmd.Close(2, $formName, 2) } catch {}
        }
    }

    $access.DoCmd.OpenForm("FPrincipalAcolhidos", 1, "", "", 0, 1)
    $f = $access.Forms.Item("FPrincipalAcolhidos")

    Set-ControlProperty $f.Controls.Item("Rótulo36") "Caption" " Processos em andamento ..............................................:"
    Set-ControlProperty $f.Controls.Item("Lista34") "RowSourceType" "Table/Query"
    Set-ControlProperty $f.Controls.Item("Lista34") "RowSource" "Q_TotalProcessosEmAndamento"
    Set-ControlProperty $f.Controls.Item("Lista34") "ColumnCount" 1
    Set-ControlProperty $f.Controls.Item("Lista34") "Visible" $true

    $f.Controls.Item("Rótulo18").Visible = $false
    $f.Controls.Item("Lista17").Visible = $false
    $f.Controls.Item("Rótulo38").Visible = $false
    $f.Controls.Item("Lista37").Visible = $false

    Set-ControlProperty $f.Controls.Item("Rótulo4") "Caption" " Destituições em andamento SEM sentença...............:"
    $f.Controls.Item("Rótulo4").Top = 8679
    $f.Controls.Item("Lista3").Top = 8694
    Set-ControlProperty $f.Controls.Item("Lista3") "RowSourceType" "Table/Query"
    Set-ControlProperty $f.Controls.Item("Lista3") "RowSource" "Q_TotalDestituicoesSemSentenca"
    Set-ControlProperty $f.Controls.Item("Lista3") "ColumnCount" 1
    Set-ControlProperty $f.Controls.Item("Lista3") "Visible" $true

    $f.Controls.Item("Rótulo27").Top = 9259
    $f.Controls.Item("Lista26").Top = 9278
    Set-ControlProperty $f.Controls.Item("Lista26") "RowSourceType" "Table/Query"
    Set-ControlProperty $f.Controls.Item("Lista26") "RowSource" "Q_TotalMedidasSemDestituicao"
    Set-ControlProperty $f.Controls.Item("Lista26") "ColumnCount" 1
    Set-ControlProperty $f.Controls.Item("Lista26") "Visible" $true

    $f.Controls.Item("Rótulo23").Top = 9829
    $f.Controls.Item("Lista22").Top = 9844
    Set-ControlProperty $f.Controls.Item("Lista22") "RowSourceType" "Table/Query"
    Set-ControlProperty $f.Controls.Item("Lista22") "RowSource" "Q_TotalProcessosGeral"
    Set-ControlProperty $f.Controls.Item("Lista22") "ColumnCount" 1
    Set-ControlProperty $f.Controls.Item("Lista22") "Visible" $true

    $access.DoCmd.Close(2, "FPrincipalAcolhidos", 1)

    $modulesDir = (Resolve-Path ".\vba_export\modules").Path
    $formsDir = (Resolve-Path ".\vba_export\forms").Path
    $queriesDir = Join-Path (Get-Location) "vba_export\queries_sql"
    New-Item -ItemType Directory -Force -Path $queriesDir | Out-Null

    $access.SaveAsText(5, "Mod_FichasAcompanhamento", (Join-Path $modulesDir "Mod_FichasAcompanhamento.bas"))
    $access.SaveAsText(2, "FPrincipalAcolhidos", (Join-Path $formsDir "FPrincipalAcolhidos.txt"))

    foreach ($q in @("Q_TotalProcessosEmAndamento", "Q_TotalDestituicoesSemSentenca", "Q_TotalMedidasSemDestituicao", "Q_TotalProcessosGeral")) {
        $qd = $db.QueryDefs.Item($q)
        [System.IO.File]::WriteAllText((Join-Path $queriesDir ($q + ".sql")), $qd.SQL, [System.Text.Encoding]::UTF8)
    }

    Write-Host "Base atualizada: $dbPath"
}
finally {
    if ($access.CurrentProject.FullName) { $access.CloseCurrentDatabase() }
    $access.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($access) | Out-Null
}
