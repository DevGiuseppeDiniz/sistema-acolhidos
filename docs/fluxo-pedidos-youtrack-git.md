# Fluxo De Pedidos: YouTrack -> Git

Este fluxo permite que uma pessoa sem conhecimento profundo de Git/Access registre pedidos no YouTrack, e que a implementacao fique rastreavel no GitHub.

## Papel Do YouTrack

O YouTrack e a entrada oficial de pedidos.

Todo pedido deve virar uma issue no projeto `SA`, por exemplo:

```text
SA-15 Gerar PDF das fichas por tela
```

## Papel Do GitHub

O GitHub registra a implementacao:

- branch criada a partir da issue;
- commits com o numero da issue;
- Pull Request vinculado ao pedido;
- historico tecnico do que mudou.

## Como O Colega Deve Abrir Um Pedido

No YouTrack, criar uma issue no projeto `SA` com:

### Titulo

Use uma frase curta e objetiva:

```text
Gerar PDF das fichas filtradas pela tela atual
```

### Descricao

Use este modelo:

```text
Contexto:
Explique onde fica a tela/rotina no Access.

Pedido:
Descreva o que deve mudar.

Comportamento atual:
Explique o que acontece hoje.

Comportamento esperado:
Explique como deve funcionar depois.

Telas/relatorios envolvidos:
- FPrincipalAcolhidos
- Cadastro de Acolhido
- Fichas de Acompanhamento

Critérios de aceite:
- Ao clicar no botão X, o sistema deve...
- O arquivo deve ser salvo em...
- Não deve alterar...

Observações:
Inclua prints, exemplos ou regras especificas.
```

## Campos Recomendados No YouTrack

Se existirem no projeto:

- `Type`: Feature, Bug, Improvement ou Task.
- `Priority`: Normal, High ou Critical.
- `State`: Open/Backlog.
- `Assignee`: pessoa responsavel, se ja souber.
- `Subsystem`: Access, VBA, Relatorio, CI/CD, YouTrack.

## Como O Desenvolvedor Inicia A Implementacao

Depois que a issue existir, use o numero dela para criar a branch:

```powershell
.\scripts\start-task.ps1 -IssueId SA-15 -Title "Gerar PDF das fichas filtradas pela tela atual"
```

Isso cria uma branch no padrao:

```text
feature/SA-15-gerar-pdf-das-fichas-filtradas-pela-tela-atual
```

## Como Commitar

Todo commit deve mencionar a issue:

```powershell
git commit -m "SA-15 Gera PDF das fichas por tela"
```

## Como Abrir Pull Request

O Pull Request deve ter:

```text
Titulo:
SA-15 Gera PDF das fichas por tela

Descricao:
Closes SA-15

Resumo:
- Centraliza a rotina de geração das fichas.
- Gera PDF em pasta por tela e data.

Testes:
- Testado em Cadastro de Acolhido.
- PDF gerado em Relatorios_Fichas/acolhidos_atuais/YYYY-MM-DD.
```

## Como O YouTrack Passa A Constar No Git

O vinculo acontece por tres lugares:

1. Nome da branch:

```text
feature/SA-15-gerar-pdf
```

2. Mensagem do commit:

```text
SA-15 Gera PDF das fichas
```

3. Descricao do PR:

```text
Closes SA-15
```

Quando a integracao GitHub + YouTrack estiver ativa, o YouTrack tambem passa a mostrar commits e PRs ligados a issue.

## Checklist Para Aceitar Um Pedido

Antes de implementar:

- A issue tem contexto suficiente?
- Tem comportamento esperado?
- Tem criterio de aceite?
- Informa telas/relatorios envolvidos?
- Nao pede para versionar dados reais?

Antes de concluir:

- Access testado.
- `.\scripts\export-access.ps1` executado.
- `git diff` revisado.
- Commit menciona `SA-xx`.
- PR menciona `SA-xx`.
