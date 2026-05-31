# Sistema Acolhidos

Projeto legado em Microsoft Access (`.accdb`) com VBA, formulários, relatórios e consultas exportados para texto para facilitar versionamento, revisão e colaboração.

## Estrutura

- `vba_export/`: objetos do Access exportados para texto e versionados.
- `scripts/`: automações para exportar/importar objetos e criar issues no YouTrack.
- `docs/`: fluxo de trabalho para colaboração com Git, GitHub e YouTrack.

Arquivos `.accdb`, relatórios gerados e backups locais ficam fora do Git.

## Começo Rápido

1. Abra o arquivo `sistema-acolhidos.accdb` e faça a alteração no Access.
2. Feche o Access.
3. Rode:

```powershell
.\scripts\export-access.ps1
```

4. Revise as alterações:

```powershell
git status
git diff
```

5. Faça commit citando a issue do YouTrack:

```powershell
git add vba_export docs scripts README.md .gitignore .gitattributes
git commit -m "SA-123 Ajusta geracao de fichas em PDF"
```

Veja o fluxo completo em [docs/workflow-access-git-youtrack.md](docs/workflow-access-git-youtrack.md).

## Pedidos Pelo YouTrack

Pedidos de implementacao devem entrar pelo YouTrack no projeto `SA`.

Use o modelo em [docs/modelo-issue-youtrack.md](docs/modelo-issue-youtrack.md) e siga o fluxo em [docs/fluxo-pedidos-youtrack-git.md](docs/fluxo-pedidos-youtrack-git.md).

Para iniciar uma branch a partir de uma issue:

```powershell
.\scripts\start-task.ps1 -IssueId SA-15 -Title "Gerar PDF das fichas por tela"
```

Branches tambem podem ser criadas automaticamente a partir do YouTrack. Veja [docs/auto-branch-youtrack.md](docs/auto-branch-youtrack.md).
