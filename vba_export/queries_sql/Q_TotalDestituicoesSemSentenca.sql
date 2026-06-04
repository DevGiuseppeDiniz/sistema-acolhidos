SELECT Count(*) AS TotalDestituicoes
FROM (SELECT DISTINCT NDestituicao
    FROM CadastroAcolhidos
    WHERE DataDesacolhimento Is Null
      AND DataDestituição Is Null
      AND NDestituicao Is Not Null
      AND NDestituicao <> ''
)  AS Destituicoes;
