Option Compare Database
Option Explicit

Private Const NOME_POPUP As String = "FPopupFiltrosLista64"
Private Const TV_FORM_ORIGEM As String = "Lista64FiltroFormOrigem"
Private Const TV_CONSULTA_BASE As String = "Lista64FiltroConsultaBase"

Public Function AbrirPopupFiltrosLista64() As Boolean
On Error GoTo TrataErro

    Dim nomeForm As String
    Dim consultaBase As String

    nomeForm = Screen.ActiveForm.Name
    consultaBase = ConsultaBaseLista64(nomeForm)

    If Len(consultaBase) = 0 Then
        Err.Raise vbObjectError + 510, , "A tela atual nao possui consulta base configurada para filtro."
    End If

    DefinirTempVar TV_FORM_ORIGEM, nomeForm
    DefinirTempVar TV_CONSULTA_BASE, consultaBase

    DoCmd.OpenForm NOME_POPUP, acNormal, , , , acDialog
    AbrirPopupFiltrosLista64 = True
    Exit Function

TrataErro:
    MsgBox "Nao foi possivel abrir os filtros da lista." & vbCrLf & _
           Err.Description, vbExclamation, "Filtros da lista"
    AbrirPopupFiltrosLista64 = False
End Function

Public Function AplicarFiltroLista64Popup() As Boolean
On Error GoTo TrataErro

    Dim frmOrigem As Form
    Dim frmFiltro As Form
    Dim consultaBase As String
    Dim entidade As Variant
    Dim sqlLista As String

    Set frmFiltro = Forms(NOME_POPUP)
    Set frmOrigem = Forms(CStr(TempVars(TV_FORM_ORIGEM).value))
    consultaBase = CStr(TempVars(TV_CONSULTA_BASE).value)
    entidade = frmFiltro.Controls("cmbFiltroEntidade").value

    If IsNull(entidade) Or Len(Nz(entidade, "")) = 0 Then
        sqlLista = consultaBase
    Else
        sqlLista = "SELECT Base.NomeAcolhido " & _
                   "FROM [" & consultaBase & "] AS Base " & _
                   "WHERE Base.EntidadeAcolhimento = " & ValorSql(entidade) & " " & _
                   "ORDER BY Base.NomeAcolhido;"
    End If

    AtualizarLista64 frmOrigem, sqlLista
    DoCmd.Close acForm, NOME_POPUP

    AplicarFiltroLista64Popup = True
    Exit Function

TrataErro:
    MsgBox "Nao foi possivel aplicar o filtro selecionado." & vbCrLf & _
           Err.Description, vbExclamation, "Filtros da lista"
    AplicarFiltroLista64Popup = False
End Function

Public Function LimparFiltroLista64Popup() As Boolean
On Error GoTo TrataErro

    Dim frmOrigem As Form
    Dim consultaBase As String

    Set frmOrigem = Forms(CStr(TempVars(TV_FORM_ORIGEM).value))
    consultaBase = CStr(TempVars(TV_CONSULTA_BASE).value)

    AtualizarLista64 frmOrigem, consultaBase
    DoCmd.Close acForm, NOME_POPUP

    LimparFiltroLista64Popup = True
    Exit Function

TrataErro:
    MsgBox "Nao foi possivel limpar os filtros da lista." & vbCrLf & _
           Err.Description, vbExclamation, "Filtros da lista"
    LimparFiltroLista64Popup = False
End Function

Public Function FecharPopupFiltrosLista64() As Boolean
On Error Resume Next
    DoCmd.Close acForm, NOME_POPUP
    FecharPopupFiltrosLista64 = True
End Function

Private Sub AtualizarLista64(ByVal frmOrigem As Form, ByVal rowSourceLista As String)
    With frmOrigem.Controls("Lista64")
        .value = Null
        .RowSource = rowSourceLista
        .Requery
    End With
End Sub

Private Function ConsultaBaseLista64(ByVal nomeForm As String) As String
    Select Case nomeForm
        Case "Formulário Destituições Atrasadas"
            ConsultaBaseLista64 = "Destituições atrasadas"
        Case "Formulário Destituições em Andamento"
            ConsultaBaseLista64 = "Consulta Destituições em Andamento"
        Case "Formulário Processos Visitas Indeferidas 6M"
            ConsultaBaseLista64 = "ConsultaSEMVisitas6meses"
        Case "Formulário de Cadastro GERAL-Des-Acol"
            ConsultaBaseLista64 = "ConsultaGERAL-Des-Acol"
        Case "Formulário Cadastro de DESTITUIDOS"
            ConsultaBaseLista64 = "Consulta Destituidos"
        Case "Formulário Crianças SEM DESTITUIÇÕES"
            ConsultaBaseLista64 = "CadastroSEMDestituicao"
        Case "Formulário de Cadastro de Desacolhidos"
            ConsultaBaseLista64 = "ConsultaSomenteDesacolhidos"
        Case "Cadastro de Acolhido"
            ConsultaBaseLista64 = "ConsultaTodosAcolhidosEntidade"
        Case "Cadastro de Acolhido - INCLUIDOS PARESCON"
            ConsultaBaseLista64 = "Consulta inseridos PARESCON"
        Case "Cadastro de Acolhidos SEM DEC VISITAS"
            ConsultaBaseLista64 = "Consulta VISITAS SEM DECISAO"
        Case "Formulário Processos Visitas INDEFERIDAS"
            ConsultaBaseLista64 = "Consulta VISITAS INDEFERIDAS"
        Case "Formulário Cadastro de DESTITUIDOS COM TRANSITO"
            ConsultaBaseLista64 = "Consulta Destituidos com transito"
    End Select
End Function

Private Function ValorSql(ByVal valor As Variant) As String
    ValorSql = "'" & Replace(CStr(valor), "'", "''") & "'"
End Function

Private Sub DefinirTempVar(ByVal nome As String, ByVal valor As Variant)
On Error Resume Next
    TempVars.Remove nome
On Error GoTo 0
    TempVars.Add nome, valor
End Sub