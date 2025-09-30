---
title: "Falha na geração dos volumes da LOA em {{ date | date }}"
labels: [bug]
---

## Falha na geração dos volumes da LOA

- Run: {{ env.RUN_URL }}
- Ref: {{ env.REF }}
- SHA: {{ env.SHA }}
- Disparado por: {{ env.SOURCE }} (repository_dispatch: gerar-volumes)

Logs anexados como artifact: gerar-volumes-logs.

### Etapas executadas
- make docker
- make format
- make rm-all
- make v7 .. v1
- make check

### Próximos passos
1. Baixe o artifact "gerar-volumes-logs" no link do run.
2. Verifique em qual etapa ocorreu a falha e corrija.
3. Re-execute o pipeline.


