SELECT CadastroAcolhidos.NomeAcolhido, CadastroAcolhidos.DataDesacolhimento, CadastroAcolhidos.AUTORIZAVisitas, CadastroAcolhidos.DataDecidVisitas, CadastroAcolhidos.DataAcolhimento, CadastroAcolhidos.DataDestituição, CadastroAcolhidos.NDestituicao
FROM CadastroAcolhidos
WHERE (((CadastroAcolhidos.DataDesacolhimento) Is Null) AND ((CadastroAcolhidos.AUTORIZAVisitas)="Não") AND ((CadastroAcolhidos.DataAcolhimento)<Date()-180) AND ((CadastroAcolhidos.NDestituicao) Is Null));
