#!/bin/bash

# Alinha nomes de arquivos em checks/assets/tex com os nomes esperados pelos testes (modo interativo)
# Lê os nomes de relatórios a partir de checks/test_*.py e checks/utils.py (Report('NAME', 'volume'))

set -euo pipefail

confirm() {
  local prompt_msg="$1"
  local default_answer="N"
  local answer
  read -r -p "$prompt_msg [y/N]: " answer || true
  answer=${answer:-$default_answer}
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

echo "=== ALINHANDO NOMES DE CHECKS (INTERATIVO) ==="
echo ""

assets_dir="checks/assets/tex"
if [ ! -d "$assets_dir" ]; then
  echo "❌ Diretório não encontrado: $assets_dir"
  exit 1
fi

# Coletar todos os nomes esperados dos testes (Report('NAME', 'volume'))
mapfile -t expected_names < <(grep -RhoE "Report\('([^']+)'" checks | sed -E "s/.*Report\('([^']+)'.*/\1/" | sort -u)

if [ ${#expected_names[@]} -eq 0 ]; then
  echo "⚠️  Nenhum nome esperado encontrado nos testes."
  exit 0
fi

for name in "${expected_names[@]}"; do
  expected_file="${assets_dir}/${name}.tex"
  if [ -f "$expected_file" ]; then
    echo "✅ ${name}.tex - OK"
    continue
  fi

  # Buscar variações case-insensitive
  mapfile -t candidates < <(find "$assets_dir" -maxdepth 1 -type f -iname "${name}.tex" | sort)
  if [ ${#candidates[@]} -eq 0 ]; then
    echo "❌ ${name}.tex - Não encontrado em ${assets_dir} (nem variações)"
    continue
  fi

  if [ ${#candidates[@]} -gt 1 ]; then
    echo "⚠️  ${name}.tex - Múltiplas variações encontradas:"
    for c in "${candidates[@]}"; do
      echo "  - $(basename "$c")"
    done
    echo "   Resolva manualmente e reexecute se necessário."
    continue
  fi

  src="${candidates[0]}"
  echo "⚠️  ${name}.tex - Encontrado como: $(basename "$src")"
  echo "   Comando: mv \"$src\" \"$expected_file\""
  if confirm "   Deseja renomear para o nome esperado?"; then
    mv "$src" "$expected_file"
    echo "   ✅ Renomeado com sucesso"
  else
    echo "   - Renomeação cancelada"
  fi
done

echo ""
echo "=== FIM DO ALINHAMENTO DE CHECKS ==="



