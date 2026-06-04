SELECT Base.NomeAcolhido
FROM [Consulta VISITAS SEM DECISAO] AS Base
WHERE ([Forms]![Cadastro de Acolhidos SEM DEC VISITAS]![EntidadeAcolhimento] Is Null OR Base.EntidadeAcolhimento = [Forms]![Cadastro de Acolhidos SEM DEC VISITAS]![EntidadeAcolhimento])
ORDER BY Base.NomeAcolhido;
