
# Protocolos - _dev_ploa-2026

## Início rápido
Torne o script executável e execute o menu de protocolos:
```bash
chmod +x _dev_ploa-2026/main_fixes.sh
./_dev_ploa-2026/main_fixes.sh help
```
Executar diretamente um protocolo (ex.: criar symlinks das capas):
```bash
./_dev_ploa-2026/main_fixes.sh capas-symlink
```

## capas-symlink
Cria/atualiza symlinks de `capaLOA.pdf` nos volumes (>= 2), apontando para `capas/capaLOA.pdf`.

- Fonte: `capas/capaLOA.pdf`
- Alvos: `volumeX/Rnw/capaLOA.pdf` para X >= 2
- Regras:
  - Se existir arquivo regular, é feito backup `capaLOA.pdf.backup-YYYYmmdd-HHMMSS.pdf` e criado o link
  - Se já houver link correto, nada é feito (a não ser com `--force`)

Uso:
```bash
bash _dev_ploa-2026/main_fixes.sh capas-symlink
bash _dev_ploa-2026/main_fixes.sh capas-symlink --dry-run
bash _dev_ploa-2026/main_fixes.sh capas-symlink --volumes 2,5 --force
```

Também é possível chamar diretamente o script Python:
```bash
python3 _dev_ploa-2026/capas_symlink.py [--dry-run] [--force] [--volumes 2,3]
```

Orientações:
- Execute a partir da raiz do repositório (`volumes-loa`).
- O `volume1` é ignorado propositalmente (suporta capa própria).
- Em caso de arquivo já existente, um backup é criado e então o link é feito.

Verificação rápida:
```bash
ls -l volume2/Rnw/capaLOA.pdf
# deve apontar para ../../capas/capaLOA.pdf
```

Desfazer (se necessário):
- Remover o link e restaurar backup (exemplo para volume 2):
```bash
rm volume2/Rnw/capaLOA.pdf
mv volume2/Rnw/capaLOA.pdf.backup-YYYYmmdd-HHMMSS.pdf volume2/Rnw/capaLOA.pdf
```

Observações:
- Em ambientes Windows nativos, symlinks podem exigir permissões elevadas; no WSL2 funciona normalmente.
- Se quiser forçar recriação, use `--force`. Para ensaiar, use `--dry-run`.

### Flags e variantes
- `--dry-run`: mostra o que seria feito, sem alterar arquivos.
- `--force`: recria o symlink mesmo que já aponte para o destino previsto.
- `--volumes 2,5,7`: limita a execução aos volumes listados (números separados por vírgula). Sem essa opção, o script detecta automaticamente todos os volumes ≥ 2 presentes no repo.

