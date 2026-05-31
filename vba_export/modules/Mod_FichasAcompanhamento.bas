Option Compare Database
Option Explicit

Public Sub GerarFichasAcompanhamentoDaLista(frmOrigem As Form)
    On Error GoTo TrataErro

    Const NOME_RELATORIO As String = "Fichas de Acompanhamento"
    Const NOME_LISTA As String = "Lista64"

    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim strFiltro As String
    Dim strNome As String
    Dim strPastaDestino As String
    Dim strArquivo As String

    strSQL = Nz(frmOrigem.Controls(NOME_LISTA).RowSource, "")
    If Len(Trim$(strSQL)) = 0 Then
        MsgBox "A lista de acolhidos nao possui origem de dados.", vbExclamation, "Gerar Fichas"
        Exit Sub
    End If

    Set rs = CurrentDb.OpenRecordset(strSQL, dbOpenSnapshot)

    Do While Not rs.EOF
        strNome = Nz(rs.Fields("NomeAcolhido").value, "")
        If Len(strNome) > 0 Then
            strFiltro = strFiltro & "'" & Replace(strNome, "'", "''") & "',"
        End If
        rs.MoveNext
    Loop

    rs.Close
    Set rs = Nothing

    If Len(strFiltro) = 0 Then
        MsgBox "Nenhum acolhido encontrado na lista.", vbInformation, "Gerar Fichas"
        Exit Sub
    End If

    strFiltro = Left$(strFiltro, Len(strFiltro) - 1)
    strPastaDestino = PastaDestinoFichas(frmOrigem.Name)
    strArquivo = strPastaDestino & "\fichas_acompanhamento_" & _
                 Format(Now, "yyyymmdd_hhnnss") & ".pdf"

    DoCmd.OpenReport _
        NOME_RELATORIO, _
        acViewReport, _
        , _
        "[NomeAcolhido] IN (" & strFiltro & ")", _
        acHidden

    DoCmd.OutputTo _
        acOutputReport, _
        NOME_RELATORIO, _
        acFormatPDF, _
        strArquivo, _
        False

    DoCmd.Close acReport, NOME_RELATORIO

    Exit Sub

TrataErro:
    On Error Resume Next
    If Not rs Is Nothing Then
        rs.Close
        Set rs = Nothing
    End If
    DoCmd.Close acReport, NOME_RELATORIO
    MsgBox "Nao foi possivel gerar as fichas de acompanhamento." & vbCrLf & _
           Err.Number & " - " & Err.Description, _
           vbExclamation, _
           "Gerar Fichas"
End Sub

Public Function GerarFichasAcompanhamentoListaAtual() As Boolean
    On Error GoTo TrataErro

    GerarFichasAcompanhamentoDaLista Screen.ActiveForm
    GerarFichasAcompanhamentoListaAtual = True
    Exit Function

TrataErro:
    MsgBox "Nao foi possivel identificar o formulario ativo para gerar as fichas.", _
           vbExclamation, _
           "Gerar Fichas"
    GerarFichasAcompanhamentoListaAtual = False
End Function

Private Function PastaDestinoFichas(nomeFormulario As String) As String
    Dim strBase As String
    Dim strTela As String
    Dim strData As String

    strTela = NomePastaTela(nomeFormulario)
    strData = Format(Date, "yyyy-mm-dd")

    strBase = CurrentProject.Path & "\Relatorios_Fichas"
    GarantirPasta strBase
    GarantirPasta strBase & "\" & strTela
    GarantirPasta strBase & "\" & strTela & "\" & strData

    PastaDestinoFichas = strBase & "\" & strTela & "\" & strData
End Function

Private Function NomePastaTela(nomeFormulario As String) As String
    Select Case nomeFormulario
        Case "Cadastro de Acolhido"
            NomePastaTela = "acolhidos_atuais"
        Case "Cadastro de Acolhido - INCLUIDOS PARESCON"
            NomePastaTela = "parescon"
        Case "Cadastro de Acolhidos SEM DEC VISITAS"
            NomePastaTela = "sem_decisao_visitas"
        Case "Formulário Cadastro de DESTITUIDOS"
            NomePastaTela = "destituidos"
        Case "Formulário Cadastro de DESTITUIDOS COM TRANSITO"
            NomePastaTela = "destituidos_com_transito"
        Case "Formulário Crianças SEM DESTITUIÇÕES"
            NomePastaTela = "sem_destituicao"
        Case "Formulário de Cadastro de Desacolhidos"
            NomePastaTela = "desacolhidos"
        Case "Formulário de Cadastro GERAL-Des-Acol"
            NomePastaTela = "geral_desacolhidos_acolhidos"
        Case "Formulário Destituições Atrasadas"
            NomePastaTela = "destituicoes_atrasadas"
        Case "Formulário Processos Visitas INDEFERIDAS"
            NomePastaTela = "visitas_indeferidas"
        Case "Formulário Processos Visitas Indeferidas 6M"
            NomePastaTela = "sem_visitas_6m"
        Case Else
            NomePastaTela = NomeSeguroPasta(nomeFormulario)
    End Select
End Function

Private Sub GarantirPasta(caminho As String)
    If Len(Dir(caminho, vbDirectory)) = 0 Then
        MkDir caminho
    End If
End Sub

Private Function NomeSeguroPasta(valor As String) As String
    Dim i As Long
    Dim ch As String
    Dim saida As String

    valor = LCase$(Trim$(valor))

    For i = 1 To Len(valor)
        ch = Mid$(valor, i, 1)
        If ch Like "[a-z0-9]" Then
            saida = saida & ch
        Else
            saida = saida & "_"
        End If
    Next i

    Do While InStr(saida, "__") > 0
        saida = Replace(saida, "__", "_")
    Loop

    If Left$(saida, 1) = "_" Then saida = Mid$(saida, 2)
    If Right$(saida, 1) = "_" Then saida = Left$(saida, Len(saida) - 1)
    If Len(saida) = 0 Then saida = "relatorio"

    NomeSeguroPasta = saida
End Function