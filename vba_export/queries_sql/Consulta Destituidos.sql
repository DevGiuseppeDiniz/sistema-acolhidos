SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.MaeAcolhido, CadastroAcolhidos.PaiAcolhido, CadastroAcolhidos.EntidadeAcolhimento, CadastroAcolhidos.PeriodoAcolhimento, CadastroAcolhidos.NDestituicao, CadastroAcolhidos.DataDestituição, CadastroAcolhidos.DataTransito, CadastroAcolhidos.AcolhidoDestituido, CadastroAcolhidos.DataDesacolhimento
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.AcolhidoDestituido)="sim") AND ((CadastroAcolhidos.DataDesacolhimento) Is Null));
