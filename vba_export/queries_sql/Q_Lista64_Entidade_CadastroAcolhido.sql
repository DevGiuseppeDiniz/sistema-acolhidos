SELECT Base.NomeAcolhido
FROM [ConsultaTodosAcolhidosEntidade] AS Base
WHERE ([Forms]![Cadastro de Acolhido]![EntidadeAcolhimento] Is Null OR Base.EntidadeAcolhimento = [Forms]![Cadastro de Acolhido]![EntidadeAcolhimento])
ORDER BY Base.NomeAcolhido;
