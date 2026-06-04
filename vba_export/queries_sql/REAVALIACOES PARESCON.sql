SELECT CadastroAcolhidos.NPedProv, CadastroAcolhidos.NDestituicao, CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.DataAcolhimento, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.PARESCON, CadastroAcolhidos.DataDesacolhimento
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.NDestituicao) Is Null) AND ((CadastroAcolhidos.PARESCON)="SIM") AND ((CadastroAcolhidos.DataDesacolhimento) Is Null));
