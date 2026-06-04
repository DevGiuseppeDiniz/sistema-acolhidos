SELECT Count(*) AS TotalProcessos
FROM (SELECT DISTINCT NPedProv AS Processo
    FROM CadastroAcolhidos
    WHERE DataDesacolhimento Is Null
      AND NPedProv Is Not Null
      AND NPedProv <> ''
    UNION
    SELECT DISTINCT NDestituicao AS Processo
    FROM CadastroAcolhidos
    WHERE DataDesacolhimento Is Null
      AND NDestituicao Is Not Null
      AND NDestituicao <> ''
)  AS Processos;
