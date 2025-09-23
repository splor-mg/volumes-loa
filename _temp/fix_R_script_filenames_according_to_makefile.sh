#!/bin/bash

# Renomeia scripts .R para o nome esperado pelo Makefile (modo interativo)
# Baseia-se nas regras pattern do Makefile: volume1/data/%.txt: volume1/R/%.R

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

echo "=== CORRIGINDO NOMES DE SCRIPTS .R SEGUNDO O MAKEFILE (INTERATIVO) ==="
echo ""

makefile_path="Makefile"
if [ ! -f "$makefile_path" ]; then
  echo "❌ Makefile não encontrado na raiz do projeto"
  exit 1
fi

# Extrair padrões de dependências para volume1/data/%.txt : volume1/R/%.R
mapfile -t expected_stems < <(grep -Eo '^\$\(DEP_.*_TXT_V1\): volume1/data/%\.txt: volume1/R/%\.R' "$makefile_path" >/dev/null 2>&1; \
  grep -Eo 'volume1/data/([A-Za-z0-9_]+)\.txt: volume1/R/\1\.R' "$makefile_path" | sed -E 's#^volume1/data/([A-Za-z0-9_]+)\.txt: volume1/R/\1\.R$#\1#' || true)

# Adicional: coletar stems explícitos de regras específicas
mapfile -t explicit_rules < <(grep -Eo '^volume1/data/[A-Za-z0-9_]+\.txt: volume1/R/[A-Za-z0-9_]+\.R' "$makefile_path" | sed -E 's#^volume1/data/([A-Za-z0-9_]+)\.txt: volume1/R/([A-Za-z0-9_]+)\.R$#\2#')

stems=("${expected_stems[@]}" "${explicit_rules[@]}")

# Remover duplicatas
uniq_stems=()
declare -A seen
for s in "${stems[@]}"; do
  if [ -n "${s:-}" ] && [ -z "${seen[$s]:-}" ]; then
    uniq_stems+=("$s")
    seen[$s]=1
  fi
done

if [ ${#uniq_stems[@]} -eq 0 ]; then
  echo "⚠️  Nenhum padrão de script .R identificado a partir do Makefile."
  echo "   (O Makefile pode gerar as dependências via scripts R dinâmicos.)"
fi

target_dir="volume1/R"
if [ ! -d "$target_dir" ]; then
  echo "❌ Diretório não encontrado: $target_dir"
  exit 1
fi

for stem in "${uniq_stems[@]}"; do
  expected_file="$target_dir/${stem}.R"
  if [ -f "$expected_file" ]; then
    echo "✅ ${stem}.R - OK"
    continue
  fi

  # Buscar variações case-insensitive do stem
  mapfile -t candidates < <(find "$target_dir" -maxdepth 1 -type f -iname "${stem}.R" | sort)

  if [ ${#candidates[@]} -eq 0 ]; then
    # tentar heurística: mesmo prefixo Tn_ (para casos como T8_*)
    prefix="$(echo "$stem" | sed -E 's_^([Tt][0-9]+).*$\1_')"
    if [[ "$prefix" =~ ^[Tt][0-9]+$ ]]; then
      mapfile -t candidates < <(find "$target_dir" -maxdepth 1 -type f -iname "${prefix}_*.R" | sort)
    fi
  fi

  if [ ${#candidates[@]} -eq 0 ]; then
    echo "❌ ${stem}.R - Não encontrado (nem variações)"
    continue
  fi

  if [ ${#candidates[@]} -gt 1 ]; then
    echo "⚠️  ${stem}.R - Múltiplas variações encontradas:"
    for c in "${candidates[@]}"; do
      echo "  - $(basename "$c")"
    done
    echo "   Faça a escolha manualmente e reexecute se necessário."
    continue
  fi

  src="${candidates[0]}"
  echo "⚠️  ${stem}.R - Encontrado como: $(basename "$src")"
  echo "   Comando: mv \"$src\" \"$expected_file\""
  if confirm "   Deseja renomear para o nome esperado?"; then
    mv "$src" "$expected_file"
    echo "   ✅ Renomeado com sucesso"
  else
    echo "   - Renomeação cancelada"
  fi
done

echo ""
echo "=== FIM DA CORREÇÃO DE SCRIPTS .R ==="



