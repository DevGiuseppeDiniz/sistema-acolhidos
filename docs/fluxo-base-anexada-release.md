# Fluxo Com Base Anexada E Release

Este fluxo foi desenhado para que a pessoa que solicita mudancas use apenas o YouTrack.

## Visao Geral

```text
Solicitante cria card no YouTrack
  -> anexa base .accdb/.zip
  -> descreve o pedido
  -> card vai para Ready for Dev
  -> GitHub cria branch e baixa a base como artifact
  -> desenvolvedor trabalha na branch
  -> desenvolvedor gera nova base .accdb
  -> publica GitHub Release
  -> comenta no YouTrack com link da nova versao
```

## Para O Solicitante

1. Criar card no projeto `SA`.
2. Preencher o descritivo.
3. Anexar a base `.accdb` ou `.zip`.
4. Nao mexer em Git.

## Para Triagem

Mover para `Ready for Dev` apenas quando:

- pedido estiver claro;
- base estiver anexada, se necessaria;
- criterios de aceite estiverem preenchidos.

## Automacao Ao Entrar Em Ready For Dev

O workflow `YouTrack Create Branches`:

- procura issues no estado `Ready for Dev`;
- cria branch `feature/SA-xx-titulo`;
- baixa anexos `.accdb`, `.accde`, `.zip` e `.7z`;
- publica esses anexos como artifact do GitHub Actions por 30 dias;
- comenta no YouTrack com link da branch e do workflow.

Importante: a base anexada nao entra no Git.

## Como O Desenvolvedor Usa A Base

1. Abrir a action run comentada no YouTrack.
2. Baixar o artifact `youtrack-base-attachments`.
3. Copiar a base para uma pasta local de trabalho.
4. Fazer backup da base atual.
5. Comparar/incorporar alteracoes manualmente no Access, quando necessario.
6. Implementar na branch criada.
7. Rodar:

```powershell
.\scripts\export-access.ps1
```

8. Commitar:

```powershell
git add vba_export
git commit -m "SA-xx Implementa pedido"
git push
```

## Entrega Da Nova Versao

Depois de gerar a base final `.accdb`, publicar release:

```powershell
$env:GITHUB_REPOSITORY = "DevGiuseppeDiniz/sistema-acolhidos"
$env:GITHUB_TOKEN_FOR_RELEASES = "<token github>"
$env:YOUTRACK_BASE_URL = "https://dev-giuseppediniz.youtrack.cloud"
$env:YOUTRACK_TOKEN = "<token youtrack>"

.\scripts\publish-release.ps1 `
  -IssueId SA-15 `
  -Version 2026.05.31.1 `
  -DatabasePath .\sistema-acolhidos.accdb
```

O script:

- cria uma GitHub Release;
- sobe a base `.accdb` como asset da release;
- comenta no card do YouTrack com o link da nova versao.

## Estado Final No YouTrack

Depois da release:

```text
Pronto para Teste
```

O solicitante baixa a base pelo link da release e testa.

Se aprovado:

```text
Concluido
```

Se houver ajuste:

```text
Ajustes Solicitados
```
