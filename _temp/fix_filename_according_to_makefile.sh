#!/bin/bash

# Renomeia arquivos .Rnw para o nome esperado pelo Makefile (modo interativo)
# Ex.: T7_Quadro_Geral_da_Receita.Rnw -> T7_QUADRO_GERAL_DA_RECEITA.Rnw

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

echo "=== CORRIGINDO NOMES .RNW SEGUNDO O MAKEFILE (INTERATIVO) ==="
echo ""

check_rnw_file() {
  local expected_name="$1"
  local volume_dir="$2"
  local rnw_dir="${volume_dir}/Rnw"

  if [ ! -d "$rnw_dir" ]; then
    return 0
  fi

  if [ -f "${rnw_dir}/${expected_name}" ]; then
    echo "✅ ${expected_name} - OK"
    return 0
  fi

  local variations
  variations=$(find "$rnw_dir" -maxdepth 1 -type f -name "*.Rnw" -iname "${expected_name%.Rnw}.Rnw" 2>/dev/null || true)

  if [ -n "$variations" ]; then
    local actual_file
    actual_file=$(basename "$variations")
    echo "⚠️  ${expected_name} - Encontrado como: ${actual_file}"
    echo "   Comando: mv \"${rnw_dir}/${actual_file}\" \"${rnw_dir}/${expected_name}\""

    if confirm "   Deseja renomear para o nome esperado?"; then
      mv "${rnw_dir}/${actual_file}" "${rnw_dir}/${expected_name}"
      echo "   ✅ Renomeado com sucesso"
    else
      echo "   - Renomeação cancelada"
    fi
  else
    echo "❌ ${expected_name} - Arquivo não encontrado"
  fi
}

echo "Verificando arquivos .Rnw do Volume 1 (coletando a partir de utils/makefile/*)..."
echo ""

# Extrair esperados dos geradores em utils/makefile/ (linhas com pdf/*.pdf e volume1/Rnw/*.Rnw)
mapfile -t expected_files < <(
  grep -RhoE 'pdf/[A-Za-z0-9_]+\.pdf' utils/makefile | sed -E 's#^pdf/([A-Za-z0-9_]+)\.pdf$#\1#' | sort -u | \
  while read -r stem; do
    # Apenas stems que têm correspondente .Rnw em volume1/Rnw segundo convenção
    # e que venha dos geradores PRODEMGE/DCGF
    if grep -R "${stem}\.pdf" -n utils/makefile >/dev/null 2>&1; then
      echo "${stem}.Rnw"
    fi
  done
)

for file in "${expected_files[@]}"; do
  check_rnw_file "$file" "volume1"
done

echo ""
echo "=== FIM DA CORREÇÃO DE NOMES DE ARQUIVOS ==="


