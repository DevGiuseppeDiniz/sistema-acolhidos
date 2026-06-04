Option Compare Database
Option Explicit

Public Function AtualizarLista64PorEntidade() As Boolean
On Error GoTo TrataErro

    Dim frm As Form
    Set frm = Screen.ActiveForm

    frm.Controls("Lista64").value = Null
    frm.Controls("Lista64").Requery

    AtualizarLista64PorEntidade = True
    Exit Function

TrataErro:
    MsgBox "Nao foi possivel atualizar a lista de acolhidos pela entidade selecionada." & vbCrLf & _
           Err.Description, vbExclamation, "Filtro por entidade"
    AtualizarLista64PorEntidade = False
End Function