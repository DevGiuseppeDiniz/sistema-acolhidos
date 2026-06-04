SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.MaeAcolhido, CadastroAcolhidos.NPedProv, CadastroAcolhidos.NDestituicao, fncPeriodoAcolhimento(Nz([DataAcolhimento],0)) AS [Periodo Acolhimento], CadastroAcolhidos.DECVisitas, CadastroAcolhidos.DataAcolhimento, CadastroAcolhidos.DataDesacolhimento
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.DECVisitas)="NÃO") AND ((CadastroAcolhidos.DataAcolhimento)<Date()-15) AND ((CadastroAcolhidos.DataDesacolhimento) Is Null));
