SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.MaeAcolhido, CadastroAcolhidos.PaiAcolhido, CadastroAcolhidos.DataAcolhimento, CadastroAcolhidos.MotivoAcolhimento, CadastroAcolhidos.DataDesacolhimento, CadastroAcolhidos.MotivoDesacolhimento, CadastroAcolhidos.NPedProv, CadastroAcolhidos.AtualizacaoFicha
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.DataDesacolhimento)=[DataDesacolhimento]));
