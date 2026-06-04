SELECT Base.NomeAcolhido
FROM [Consulta Destituições em Andamento] AS Base
WHERE ([Forms]![Formulário Destituições em Andamento]![EntidadeAcolhimento] Is Null OR Base.EntidadeAcolhimento = [Forms]![Formulário Destituições em Andamento]![EntidadeAcolhimento])
ORDER BY Base.NomeAcolhido;
