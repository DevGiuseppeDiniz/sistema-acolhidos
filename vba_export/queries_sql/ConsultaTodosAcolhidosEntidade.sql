SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.DataDesacolhimento, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.NPedProv, CadastroAcolhidos.NDestituicao
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.DataDesacolhimento) Is Null))
ORDER BY CadastroAcolhidos.NPedProv;
