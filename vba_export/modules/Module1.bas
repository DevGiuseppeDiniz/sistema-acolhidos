Option Compare Database
Public Sub Zipabanco()
    Dim strDate As String, DefPath As String
    Dim oApp As Object
    Dim FName, FileNameZip
    Dim strPrefix As String
     On Error Resume Next
    
    'Caminho da pasta onde esta o banco a zipar
    DefPath = Application.CurrentProject.Path & "\Backups - Controle Acolhidos"
    If Right(DefPath, 1) <> "\" Then
        DefPath = DefPath & "\"
    End If
 
    strDate = Format(Now, "dd-mmm-yy_h-mm-ss")
    FileNameZip = DefPath & "BackupSistemaAcolhidos_" & strDate & ".zip"
    
    strPrefix = "Controle de Acolhidos"
    
        FName = Application.CurrentProject.Path & "\" & strPrefix & ".accdb"
        On Error Resume Next
    CriaNovoZip (FileNameZip)
    Set oApp = CreateObject("Shell.Application")
    oApp.NameSpace(FileNameZip).CopyHere FName
    'Call MsgBox("Criado com Sucesso em: " & FileNameZip, vbInformation, "Sucesso")
    Set oApp = Nothing
   Exit Sub
End Sub

Public Sub CriaNovoZip(sPath)
    Dim ofso, arrHex, sBin, i, Zip
    On Error Resume Next
    Set ofso = CreateObject("Scripting.FileSystemObject")
    arrHex = Array(80, 75, 5, 6, 0, 0, 0, _
                   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    For i = 0 To UBound(arrHex)
        sBin = sBin & Chr(arrHex(i))
    Next
    On Error Resume Next
    With ofso.CreateTextFile(sPath, True)
        .Write sBin
        .Close
    End With
   Exit Sub
End Sub