SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.DataDesacolhimento, CadastroAcolhidos.DataInicioDest, CadastroAcolhidos.DataDestituição, CadastroAcolhidos.NDestituicao
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.DataDesacolhimento) Is Null) AND ((CadastroAcolhidos.DataDestituição) Is Null) AND ((CadastroAcolhidos.NDestituicao) Is Not Null And (CadastroAcolhidos.NDestituicao)<>""));
