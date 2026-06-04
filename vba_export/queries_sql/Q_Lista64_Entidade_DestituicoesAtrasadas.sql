SELECT Base.NomeAcolhido
FROM [Destituições atrasadas] AS Base
WHERE ([Forms]![Formulário Destituições Atrasadas]![EntidadeAcolhimento] Is Null OR Base.EntidadeAcolhimento = [Forms]![Formulário Destituições Atrasadas]![EntidadeAcolhimento])
ORDER BY Base.NomeAcolhido;
