SELECT Count(*) AS TotalProcessos
FROM (SELECT DISTINCT NPedProv AS Processo
    FROM CadastroAcolhidos
    WHERE NPedProv Is Not Null
      AND NPedProv <> ''
    UNION
    SELECT DISTINCT NDestituicao AS Processo
    FROM CadastroAcolhidos
    WHERE NDestituicao Is Not Null
      AND NDestituicao <> ''
)  AS Processos;
