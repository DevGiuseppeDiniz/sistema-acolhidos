SELECT Base.NomeAcolhido
FROM [ConsultaGERAL-Des-Acol] AS Base
WHERE ([Forms]![Formulário de Cadastro GERAL-Des-Acol]![EntidadeAcolhimento] Is Null OR Base.EntidadeAcolhimento = [Forms]![Formulário de Cadastro GERAL-Des-Acol]![EntidadeAcolhimento])
ORDER BY Base.NomeAcolhido;
