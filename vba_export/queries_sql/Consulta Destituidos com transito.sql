SELECT [Consulta Destituidos].NomeAcolhido, [Consulta Destituidos].NomeAcolhido, [Consulta Destituidos].PaiAcolhido, [Consulta Destituidos].EntidadeAcolhimento, [Consulta Destituidos].PeriodoAcolhimento, [Consulta Destituidos].NDestituicao, [Consulta Destituidos].DataTransito, [Consulta Destituidos].AcolhidoDestituido, [Consulta Destituidos].DataDesacolhimento
FROM [Consulta Destituidos]
WHERE ((([Consulta Destituidos].DataTransito) Is Not Null) AND (([Consulta Destituidos].AcolhidoDestituido)="sim") AND (([Consulta Destituidos].DataDesacolhimento) Is Null));
