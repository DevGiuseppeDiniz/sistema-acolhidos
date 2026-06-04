SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.DataDesacolhimento, CadastroAcolhidos.NDestituicao, CadastroAcolhidos.DataInicioDest, CadastroAcolhidos.DataDestituição
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.DataDesacolhimento) Is Null) AND ((CadastroAcolhidos.DataInicioDest)<Date()-120) AND ((CadastroAcolhidos.DataDestituição) Is Null));
