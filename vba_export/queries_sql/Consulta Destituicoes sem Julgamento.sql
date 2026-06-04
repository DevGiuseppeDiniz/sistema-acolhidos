SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.NDestituicao, CadastroAcolhidos.DataInicioDest, CadastroAcolhidos.DiasTramitaDest
FROM CadastroAcolhidos
GROUP BY CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.NDestituicao, CadastroAcolhidos.DataInicioDest, CadastroAcolhidos.DiasTramitaDest, CadastroAcolhidos.DataDesacolhimento, CadastroAcolhidos.DataDestituição
HAVING (((CadastroAcolhidos.NDestituicao)<>"") AND ((CadastroAcolhidos.DataDesacolhimento) Is Null) AND ((CadastroAcolhidos.DataDestituição) Is Null));
