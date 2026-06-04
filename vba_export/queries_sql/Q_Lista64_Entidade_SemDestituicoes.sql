SELECT Base.NomeAcolhido
FROM [CadastroSEMDestituicao] AS Base
WHERE ([Forms]![Formulário Crianças SEM DESTITUIÇÕES]![EntidadeAcolhimento] Is Null OR Base.EntidadeAcolhimento = [Forms]![Formulário Crianças SEM DESTITUIÇÕES]![EntidadeAcolhimento])
ORDER BY Base.NomeAcolhido;
