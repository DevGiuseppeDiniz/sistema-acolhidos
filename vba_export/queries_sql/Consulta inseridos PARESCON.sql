SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.PARESCON, CadastroAcolhidos.NPedProv, CadastroAcolhidos.EntidadeAcolhimento
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.PARESCON)="SIM") AND ((CadastroAcolhidos.DataDesacolhimento) Is Null));
