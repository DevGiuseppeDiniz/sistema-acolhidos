SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.NDestituicao, CadastroAcolhidos.DataDesacolhimento, CadastroAcolhidos.NPedProv, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.DataAcolhimento, fncPeriodoAcolhimento(Nz([DataAcolhimento],0)) AS [Periodo Acolhimento]
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.NDestituicao) Is Null) AND ((CadastroAcolhidos.DataDesacolhimento) Is Null));
