# Modelo De Issue YouTrack

Copie e cole este modelo na descricao da issue.

```text
Contexto:


Pedido:


Comportamento atual:


Comportamento esperado:


Telas/relatorios envolvidos:
- 

Regras de negocio:
- 

CritÃ©rios de aceite:
- 
- 
- 

Impacto esperado:


Arquivos ou prints anexados:
- 

ObservaÃ§Ãµes:

```

## Exemplo

```text
Contexto:
Na tela Cadastro de Acolhido existe o botao Gerar Fichas de Acompanhamento.

Pedido:
Gerar um PDF apenas com os acolhidos que aparecem na Lista64 da tela atual.

Comportamento atual:
O relatorio abre sem separar o arquivo por tela/data.

Comportamento esperado:
Ao clicar no botao, gerar um PDF em Relatorios_Fichas/<nome_da_tela>/<data>.

Telas/relatorios envolvidos:
- Cadastro de Acolhido
- Cadastro de Acolhidos SEM DEC VISITAS
- Fichas de Acompanhamento

Regras de negocio:
- Usar somente os nomes exibidos na Lista64.
- Nao alterar a consulta base do relatorio.

CritÃ©rios de aceite:
- Gera PDF sem erro.
- Pasta por tela criada automaticamente.
- Pasta por data criada automaticamente.
- Arquivo .accdb nao entra no Git.

Impacto esperado:
Facilitar emissao de fichas por tipo de consulta.
```

