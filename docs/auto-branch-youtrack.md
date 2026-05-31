# Automacao: Card YouTrack -> Branch GitHub

Esta automacao cria branches no GitHub automaticamente para cards do YouTrack que estejam prontos para desenvolvimento.

## Fluxo

```text
Colega cria card no YouTrack
  -> voce revisa e muda State para "Ready for Dev"
  -> GitHub Actions roda a cada 30 minutos ou manualmente
  -> branch e criada no GitHub
  -> anexos de base sao baixados como artifact
  -> comentario e adicionado no card com link da branch e do workflow
```

## Arquivos

- `.github/workflows/youtrack-create-branches.yml`
- `automation/youtrack-github-branch/create-branches-from-youtrack.ps1`

## Secrets Necessarios No GitHub

Em `GitHub > Repository > Settings > Secrets and variables > Actions`, criar:

### `YOUTRACK_BASE_URL`

```text
https://dev-giuseppediniz.youtrack.cloud
```

### `YOUTRACK_TOKEN`

Token do YouTrack com permissao para:

- ler issues do projeto `SIS`;
- comentar em issues.

Nao e necessario criar secret GitHub para branch. O workflow usa o `github.token`
nativo do GitHub Actions com permissao `contents: write`.

## Configuracoes Da Automacao

No workflow:

```yaml
YOUTRACK_PROJECT_SHORT_NAME: SIS
YOUTRACK_READY_STATE: Ready for Dev
YOUTRACK_QUERY: "project: {sistema-acolhidos} State: {Ready for Dev}"
BASE_BRANCH: main
BRANCH_TYPE: feature
```

Se o estado no YouTrack estiver em portugues, por exemplo `Pronto para Desenvolvimento`, altere `YOUTRACK_READY_STATE` e a query para `project: {sistema-acolhidos} State: {Pronto para Desenvolvimento}`.

## Padrao De Branch

Para uma issue:

```text
SIS-15 Gerar PDF das fichas por tela
```

A branch criada sera:

```text
feature/SIS-15-gerar-pdf-das-fichas-por-tela
```

## Como Testar Manualmente

1. Crie uma issue no YouTrack.
2. Mude o estado para `Ready for Dev`.
3. No GitHub, abra `Actions`.
4. Rode o workflow `YouTrack Create Branches` manualmente.
5. Primeiro rode com `dry_run = true`.
6. Use a query padrao `project: {sistema-acolhidos} State: {Ready for Dev}`.
7. Confira no log se a issue foi encontrada e qual branch seria criada.
8. Rode novamente com `dry_run = false`.
9. Confira se a branch apareceu em `Code > Branches`.
10. Confira se o artifact `youtrack-base-attachments` apareceu, caso o card tenha `.accdb`/`.zip`.
11. Confira se a issue recebeu um comentario com o link da branch.

## Evitar Branches Para Pedidos Incompletos

Nao recomendamos criar branch quando o card e apenas criado. O melhor ponto de automacao e quando o card muda para `Ready for Dev`, porque:

- o pedido ja foi revisado;
- evita branch para card duplicado;
- evita branch para card sem criterio de aceite;
- mantem o Git mais limpo.

## Se A Branch Ja Existir

O script ignora issues cuja branch ja exista.

## Limitacoes

- O script nao muda o estado da issue depois de criar a branch.
- O script nao cria Pull Request.
- O script depende do nome exato do estado configurado em `YOUTRACK_READY_STATE`.

