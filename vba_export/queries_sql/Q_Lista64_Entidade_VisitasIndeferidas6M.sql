SELECT Base.NomeAcolhido
FROM [ConsultaSEMVisitas6meses] AS Base
WHERE ([Forms]![Formulário Processos Visitas Indeferidas 6M]![EntidadeAcolhimento] Is Null OR Base.EntidadeAcolhimento = [Forms]![Formulário Processos Visitas Indeferidas 6M]![EntidadeAcolhimento])
ORDER BY Base.NomeAcolhido;
