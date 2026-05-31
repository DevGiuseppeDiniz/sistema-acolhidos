Option Compare Binary
Option Explicit

Private strUsuarioAtual As String
Private Const SENHA_PADRAO = "123456"

Function getSenhaPadrao() As String
  getSenhaPadrao = SENHA_PADRAO
End Function

Sub setUsuarioAtual(argLogin As String)
  strUsuarioAtual = argLogin
End Sub

Function getUsuarioAtual() As String
  getUsuarioAtual = strUsuarioAtual
End Function

Function getGrupoUsuarioAtual() As String
  
  getGrupoUsuarioAtual = Nz(DLookup("grupo", "Usuario", _
                    "login='" & strUsuarioAtual & "'"), "")
  
  Select Case getGrupoUsuarioAtual
    Case 0
      getGrupoUsuarioAtual = "Administradores"
    Case 1
      getGrupoUsuarioAtual = "Gerentes"
    Case 2
      getGrupoUsuarioAtual = "Usuários"
    Case 3
      getGrupoUsuarioAtual = "Visitantes"
    Case Else
      getGrupoUsuarioAtual = ""
  End Select
  
End Function

Function verificaLogin(argLogin As String, argSenha As String) As Boolean

    Dim criterio As String
    
    'Convertendo a senha clara
    'em código hash MD5 para
    'comparação e validação
    argSenha = getMD5(argSenha)
    
    criterio = "login='" & argLogin & "' And senha='" & argSenha & "'"
    
    If Nz(DCount("login", "Usuario", criterio), 0) > 0 Then
        verificaLogin = True
        setUsuarioAtual argLogin
    Else
        verificaLogin = False
    End If

End Function

Sub alterarSenha(argLogin As String, argSenha As String)

    Dim strSQL As String
    
    'Convertendo a senha clara
    'em código hash MD5 para
    'armazenamento seguro
    argSenha = getMD5(argSenha)

    strSQL = "Update Usuario Set senha='" & argSenha & "'" & _
            "Where login='" & argLogin & "'"
    DoCmd.SetWarnings False
    DoCmd.RunSQL strSQL
    DoCmd.SetWarnings True
    
End Sub