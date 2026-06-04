SELECT Base.NomeAcolhido
FROM [ConsultaSomenteDesacolhidos] AS Base
WHERE ([Forms]![Formulário de Cadastro de Desacolhidos]![EntidadeAcolhimento] Is Null OR Base.EntidadeAcolhimento = [Forms]![Formulário de Cadastro de Desacolhidos]![EntidadeAcolhimento])
ORDER BY Base.NomeAcolhido;
