# Workflow Access + Git + YouTrack

Este guia existe para permitir colaboração no sistema Access sem troca manual de bases `.accdb`.

## Ideia Principal

O arquivo `.accdb` é binário e difícil de comparar. Por isso, o Git deve versionar os objetos exportados em texto:

- módulos VBA;
- formulários;
- relatórios;
- macros;
- consultas SQL;
- documentação;
- scripts.

O `.accdb` continua sendo usado para desenvolver e testar no Access, mas não deve ser a fonte principal do histórico.

## Regra De Ouro

Nunca versionar:

- base com dados reais;
- backups `.accdb`;
- arquivos `.laccdb`;
- PDFs gerados;
- senhas ou tokens.

Versionar:

- `vba_export/`;
- `scripts/`;
- `docs/`;
- `README.md`;
- `.gitignore`;
- `.gitattributes`.

## Fluxo Para Uma Nova Tarefa

1. Escolha ou crie uma issue no YouTrack, por exemplo `SA-15`.
2. Atualize sua branch principal:

```powershell
git checkout main
git pull
```

3. Crie uma branch com o numero da issue:

```powershell
git checkout -b feature/SA-15-gerar-fichas-pdf
```

4. Abra `sistema-acolhidos.accdb` no Access.
5. Faça a alteração.
6. Teste manualmente no Access.
7. Feche o Access.
8. Exporte os objetos alterados:

```powershell
.\scripts\export-access.ps1
```

9. Veja o que mudou:

```powershell
git status
git diff
```

10. Faça commit:

```powershell
git add vba_export
git commit -m "SA-15 Gera fichas em PDF por tela"
```

11. Envie a branch:

```powershell
git push -u origin feature/SA-15-gerar-fichas-pdf
```

12. Abra Pull Request no GitHub e vincule com a issue `SA-15`.

## Como Criar Issue No YouTrack Pelo Script

Configure variáveis de ambiente no PowerShell:

```powershell
$env:YOUTRACK_BASE_URL = "https://dev-giuseppediniz.youtrack.cloud"
$env:YOUTRACK_TOKEN = "perm:seu-token"
$env:YOUTRACK_PROJECT_SHORT_NAME = "SA"
```

Crie uma issue:

```powershell
.\scripts\youtrack-create-issue.ps1 `
  -Summary "Melhorar painel FPrincipalAcolhidos" `
  -Description "Padronizar visual, preservar regras atuais e exportar objetos alterados."
```

O script retorna o id da issue criada, como `SA-15`.

## Como Vincular Commits Ao YouTrack

Use o id da issue no nome da branch e no commit:

```text
feature/SA-15-gerar-fichas-pdf
SA-15 Gera fichas em PDF por tela
```

Depois que o GitHub estiver integrado ao YouTrack, o YouTrack reconhece referências a issues em commits e PRs.

## Quando Der Conflito

Conflito em arquivo exportado do Access deve ser tratado com cuidado:

1. Não resolver no escuro.
2. Comparar quais objetos foram alterados.
3. Se duas pessoas mexeram no mesmo formulário, escolher uma versão no Access e reexportar.
4. Evitar duas pessoas editando o mesmo formulário ao mesmo tempo.

## Checklist Antes De Abrir PR

- Access abre sem erro.
- Tela alterada foi testada.
- `.\scripts\export-access.ps1` foi executado.
- `git diff` foi revisado.
- Nenhum `.accdb`, `.pdf`, backup ou dado real entrou no commit.
- Commit menciona a issue `SA-xx`.

## Fluxo Recomendado Para O Projeto Atual

Para cada melhoria:

1. Criar issue no YouTrack.
2. Criar branch a partir da issue.
3. Alterar no Access.
4. Exportar.
5. Commitar apenas texto exportado/scripts/docs.
6. Abrir PR.
7. Revisar.
8. Fazer merge.
9. Gerar `.accdb` de release quando necessário.
