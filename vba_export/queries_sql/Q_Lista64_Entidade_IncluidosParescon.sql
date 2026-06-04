SELECT Base.NomeAcolhido
FROM [Consulta inseridos PARESCON] AS Base
WHERE ([Forms]![Cadastro de Acolhido - INCLUIDOS PARESCON]![EntidadeAcolhimento] Is Null OR Base.EntidadeAcolhimento = [Forms]![Cadastro de Acolhido - INCLUIDOS PARESCON]![EntidadeAcolhimento])
ORDER BY Base.NomeAcolhido;
