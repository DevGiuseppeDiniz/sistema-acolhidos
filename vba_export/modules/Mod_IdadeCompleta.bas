Option Compare Database

Public Function fncIdadeCompleta(DataNascimentoAcolhido As Date) As String
On Error GoTo trataerro
Dim Anos As Byte, Meses As Variant, Dias As Byte, DataRef As Date
If DataNascimentoAcolhido > Date Or DataNascimentoAcolhido = 0 Then
    fncIdadeCompleta = ""
    Exit Function
End If
If DataNascimentoAcolhido = Date Then
    fncIdadeCompleta = 0
    Exit Function
End If
Anos = Int(DateDiff("d", DataNascimentoAcolhido, Date) / 365.25)
DataRef = DateSerial(Year(Date) + (Format(DataNascimentoAcolhido, "mmdd") > Format(Date, "mmdd")), Format(DataNascimentoAcolhido, "mm"), Format(DataNascimentoAcolhido, "dd"))
Meses = DateDiff("m", DataRef, Date) + (Format(DataNascimentoAcolhido, "dd") > Format(Date, "dd"))
DataRef = DateSerial(Year(Date), Format(Date, "mm") + (Format(DataNascimentoAcolhido, "dd") > Format(Date, "dd")), Format(DataNascimentoAcolhido, "dd"))
DataRef = IIf(Format(DataNascimentoAcolhido, "dd") <> Format(DataRef, "dd"), DataRef - Format(DataRef, "dd"), DataRef)
Dias = CDbl(Date) - CDbl(DataRef)
fncIdadeCompleta = IIf(Anos <= 1, IIf(Anos = 0, "", Anos & " ano "), Anos & " anos ") & _
                   IIf(Meses <= 1, IIf(Meses = 0, "", Meses & " mes "), Meses & " meses ") & _
                   IIf(Dias <= 1, IIf(Dias = 0, "", Dias & " dia "), Dias & " dias ")
sair:
    Exit Function
trataerro:
    MsgBox "Erro: " & Err.Number & vbCrLf & Err.Description, vbCritical, "Aviso", Err.HelpFile, Err.HelpContext
    Resume sair:
End Function