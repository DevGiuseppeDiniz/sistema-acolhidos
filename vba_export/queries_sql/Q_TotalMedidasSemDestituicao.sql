SELECT Count(*) AS TotalMedidas
FROM (SELECT DISTINCT NPedProv
    FROM CadastroAcolhidos
    WHERE DataDesacolhimento Is Null
      AND NPedProv Is Not Null
      AND NPedProv <> ''
      AND (NDestituicao Is Null OR NDestituicao = '')
)  AS Medidas;
