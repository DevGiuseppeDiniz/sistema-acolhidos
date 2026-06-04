SELECT Base.NomeAcolhido
FROM [Consulta Destituidos com transito] AS Base
WHERE ([Forms]![Formulário Cadastro de DESTITUIDOS COM TRANSITO]![EntidadeAcolhimento] Is Null OR Base.EntidadeAcolhimento = [Forms]![Formulário Cadastro de DESTITUIDOS COM TRANSITO]![EntidadeAcolhimento])
ORDER BY Base.NomeAcolhido;
