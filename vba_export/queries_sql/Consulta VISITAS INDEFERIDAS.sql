SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.MaeAcolhido, CadastroAcolhidos.NPedProv, CadastroAcolhidos.NDestituicao, fncPeriodoAcolhimento(Nz([DataAcolhimento],0)) AS [Periodo Acolhimento], CadastroAcolhidos.DECVisitas, CadastroAcolhidos.AUTORIZAVisitas, CadastroAcolhidos.DataDesacolhimento
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.DECVisitas)="SIM") AND ((CadastroAcolhidos.AUTORIZAVisitas)="NÃO") AND ((CadastroAcolhidos.DataDesacolhimento) Is Null));
