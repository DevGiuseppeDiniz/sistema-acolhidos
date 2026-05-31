Option Compare Database


Public Function fncPeriodoAcolhimento(DataAcolhimento As Date) As String
On Error GoTo trataerro
Dim Anos As Byte, Meses As Variant, Dias As Byte, DataRef As Date
If DataAcolhimento > Date Or DataAcolhimento = 0 Then
    fncPeriodoAcolhimento = ""
    Exit Function
End If
If DataAcolhimento = Date Then
    fncPeriodoAcolhimento = 0
    Exit Function
End If
Anos = Int(DateDiff("d", DataAcolhimento, Date) / 365.25)
DataRef = DateSerial(Year(Date) + (Format(DataAcolhimento, "mmdd") > Format(Date, "mmdd")), Format(DataAcolhimento, "mm"), Format(DataAcolhimento, "dd"))
Meses = DateDiff("m", DataRef, Date) + (Format(DataAcolhimento, "dd") > Format(Date, "dd"))
DataRef = DateSerial(Year(Date), Format(Date, "mm") + (Format(DataAcolhimento, "dd") > Format(Date, "dd")), Format(DataAcolhimento, "dd"))
DataRef = IIf(Format(DataAcolhimento, "dd") <> Format(DataRef, "dd"), DataRef - Format(DataRef, "dd"), DataRef)
Dias = CDbl(Date) - CDbl(DataRef)
fncPeriodoAcolhimento = IIf(Anos <= 1, IIf(Anos = 0, "", Anos & " ano "), Anos & " anos ") & _
                   IIf(Meses <= 1, IIf(Meses = 0, "", Meses & " mes "), Meses & " meses ") & _
                   IIf(Dias <= 1, IIf(Dias = 0, "", Dias & " dia "), Dias & " dias ")
sair:
    Exit Function
trataerro:
    MsgBox "Erro: " & Err.Number & vbCrLf & Err.Description, vbCritical, "Aviso", Err.HelpFile, Err.HelpContext
    Resume sair:
End Function