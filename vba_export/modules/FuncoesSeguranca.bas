Option Compare Binary
Option Explicit

Function forcaSenha(argSenha As String) As Integer
'================================================================
'Função forcaSenha()
'
'Verifica se uma senha é segura com base nos parâmetros passados,
'levando em consideração tamanho da senha, presença de letras
'minúsculas e maiúsculas, números, símbolos e repetições.
'
'Valores de resultado (0 a 100):
' >= 0  e < 20 => Senha Muito Fraca
' >= 20 e < 50  --> Senha Fraca
' >= 50 e < 80  --> Senha Média
' >= 80 e < 90  --> Senha Forte
' >= 90 e < 100 --> Senha Muito Forte
' = 100         --> Senha Fortíssima
'
'Autor: Plinio Mabesi
'Fevereiro 2012
'pliniomabesi@gmail.com
'www.mabesi.com
'================================================================

    'Declaração de variáveis
    Dim i As Integer, j As Integer
    Dim caracteresRepetidos As Integer
    Dim strMinusculas As String, strMaiusculas As String
    Dim strNumeros As String, strSimbolos As String
    Dim contemMaiuscula As Boolean, contemMinuscula As Boolean
    Dim contemNumero As Boolean, contemSimbolo As Boolean
    Dim tamanhoSenha As Integer
    
    'Letras, síbolos e números
    strMinusculas = "abcdefghijklmnopqrstuvwxyz"
    strMaiusculas = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    strSimbolos = """!@#$%¨&*()-_=+`´[]{}§£¢ªº^~<>,.;:/?\| "
    strNumeros = "0123456789"
    
    'Obtem o tamanho da senha
    tamanhoSenha = Len(argSenha)
    
    'Atribui pontuação imediata
    'para senhas muito curtas
    If tamanhoSenha = 0 Then
      forcaSenha = 0
      Exit Function
    ElseIf tamanhoSenha = 1 Then
      forcaSenha = 4
      Exit Function
    End If
    
    'Obtem a pontuação da senha pelo seu tamanho
    '0 a 70 pontos ( >=12 --> 70 pt )
    If tamanhoSenha < 12 Then
      forcaSenha = ((tamanhoSenha * tamanhoSenha) / 144) * 70
    Else
      forcaSenha = 70
    End If
    
    'Verifica se contem letras minúsculas
    For i = 1 To tamanhoSenha
        If InStr(1, strMinusculas, Mid(argSenha, i, 1)) > 0 Then
            contemMinuscula = True
        End If
    Next i
    
    'Verifica se contem letras maiúsculas
    For i = 1 To tamanhoSenha
        If InStr(1, strMaiusculas, Mid(argSenha, i, 1)) > 0 Then
            contemMaiuscula = True
        End If
    Next i
    
    'Verifica se contem números
      For i = 1 To tamanhoSenha
          If InStr(1, strNumeros, Mid(argSenha, i, 1)) > 0 Then
              contemNumero = True
          End If
      Next i
    
    'Verifica se contem símbolos
      For i = 1 To tamanhoSenha
          If InStr(1, strSimbolos, Mid(argSenha, i, 1)) > 0 Then
              contemSimbolo = True
          End If
      Next i
      
      'Soma 10 pontos caso a senha contenha
      'letras minúsculas e maiúsculas
      If contemMinuscula And contemMaiuscula Then
        forcaSenha = forcaSenha + 10
      ElseIf contemMinuscula Or contemMaiuscula Then
        forcaSenha = forcaSenha + 4
      End If
      
      If contemNumero Then
        forcaSenha = forcaSenha + 10
      End If
      
      If contemSimbolo Then
        forcaSenha = forcaSenha + 10
      End If
      
      'Verifica se há caracteres repetidos
      'e deduz pontos proporcionalmente
      caracteresRepetidos = 0
      For i = 1 To tamanhoSenha
          For j = i + 1 To tamanhoSenha
              If Mid(argSenha, i, 1) = Mid(argSenha, j, 1) Then
                  caracteresRepetidos = caracteresRepetidos + 1
                  Exit For
              End If
          Next j
      Next i
      
      'Resultado do cálculo de força de senha
      forcaSenha = forcaSenha - (caracteresRepetidos * 2)

End Function

Function limparSenha(argExpressao As String) As String

  'Retirando as aspas simples
  limparSenha = Replace(argExpressao, "'", "")
  
  'Retirando os sinais de ponto e vírgula
  limparSenha = Replace(argExpressao, ";", "")
  
End Function

Function getMD5(argSenha As String) As String

  'Declarando um objeto da
  'classe HashMD5
  Dim objMD5 As New HashMD5
  
  'Utilizando o método DigestStrToHexStr para
  'obter um hash MD5 de 32 caracteres hexadecimais
  'a partir da senha informada.
  getMD5 = objMD5.DigestStrToHexStr(argSenha)

End Function


Sub teste()
Debug.Print getMD5("E o vento levou")
End Sub