SELECT Base.NomeAcolhido
FROM [Consulta VISITAS INDEFERIDAS] AS Base
WHERE ([Forms]![Formulário Processos Visitas INDEFERIDAS]![EntidadeAcolhimento] Is Null OR Base.EntidadeAcolhimento = [Forms]![Formulário Processos Visitas INDEFERIDAS]![EntidadeAcolhimento])
ORDER BY Base.NomeAcolhido;
