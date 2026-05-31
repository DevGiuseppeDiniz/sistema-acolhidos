# Setup YouTrack + GitHub

## Objetivo

Conectar o projeto YouTrack `SA` ao repositorio GitHub `DevGiuseppeDiniz/sistema-acolhidos` para rastrear commits, branches e pull requests relacionados a issues.

## YouTrack

URL:

```text
https://dev-giuseppediniz.youtrack.cloud
```

Projeto:

```text
SA
```

## GitHub

Repositorio:

```text
https://github.com/DevGiuseppeDiniz/sistema-acolhidos
```

## Passos Manuais No YouTrack

1. Acesse o YouTrack como administrador.
2. Abra o projeto `SA`.
3. Va em `Project Settings` > `VCS Integrations`.
4. Adicione integracao com GitHub.
5. Autorize acesso ao repositorio `DevGiuseppeDiniz/sistema-acolhidos`.
6. Configure o mapeamento para reconhecer issue ids como `SA-123`.

## Token Para Automacoes

Crie um token permanente ou token de app com permissao para criar issues no projeto `SA`.

Nunca commitar o token. Use variavel de ambiente:

```powershell
$env:YOUTRACK_TOKEN = "perm:..."
```

## Campos Que Podemos Automatizar

Inicialmente:

- resumo;
- descricao;
- projeto;
- tags, se existirem;
- tipo/prioridade, depois que confirmarmos os nomes dos campos no YouTrack.

Depois:

- assignee;
- sprint;
- estado inicial;
- links para branch/PR;
- comentarios com resumo tecnico.

## Fluxo De Pedido Recomendado

1. Colega cria issue no YouTrack usando [modelo-issue-youtrack.md](modelo-issue-youtrack.md).
2. Desenvolvedor cria branch com `scripts/start-task.ps1`.
3. Commits e PRs mencionam `SA-xx`.
4. Integracao GitHub + YouTrack mostra commits/PRs dentro da issue.

## Criacao Automatica De Branch

Este repositorio tambem possui um workflow GitHub Actions que consulta issues em `Ready for Dev` e cria branches automaticamente.

Veja [auto-branch-youtrack.md](auto-branch-youtrack.md).
