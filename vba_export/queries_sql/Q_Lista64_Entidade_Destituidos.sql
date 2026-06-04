SELECT Base.NomeAcolhido
FROM [Consulta Destituidos] AS Base
WHERE ([Forms]![Formulário Cadastro de DESTITUIDOS]![EntidadeAcolhimento] Is Null OR Base.EntidadeAcolhimento = [Forms]![Formulário Cadastro de DESTITUIDOS]![EntidadeAcolhimento])
ORDER BY Base.NomeAcolhido;
