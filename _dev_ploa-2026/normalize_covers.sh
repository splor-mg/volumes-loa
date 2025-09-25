#!/bin/bash

# Script interativo para padronizar nomes de capaLOA.pdf em volume*/Rnw/
# - Detecta variações de nome (ex.: CapaLOA.pdf, CAPALOA.pdf) com busca case-insensitive
# - Mostra os comandos que serão executados e pede confirmação antes de renomear

set -euo pipefail

confirm() {
  local prompt_msg="$1"
  local default_answer="n"
  local answer
  read -r -p "$prompt_msg (y/n): " answer || true
  answer=${answer:-$default_answer}
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

echo "=== NORMALIZANDO CAPAS LOA (INTERATIVO) ==="
echo ""

normalize_volume_cover() {
  local vol="$1"
  local dir="volume${vol}/Rnw"

  if [ ! -d "$dir" ]; then
    echo "Volume ${vol}: ❌ Diretório não encontrado: ${dir}"
    echo ""
    return 0
  fi

  # Se já existe com o nome correto, nada a fazer
  if [ -f "${dir}/capaLOA.pdf" ]; then
    echo "Volume ${vol}: ✅ Já possui ${dir}/capaLOA.pdf"
    echo ""
    return 0
  fi

  # Procurar variações case-insensitive
  mapfile -t matches < <(find "$dir" -maxdepth 1 -type f -iname "capaLOA.pdf" | sort)

  if [ "${#matches[@]}" -eq 0 ]; then
    echo "Volume ${vol}: ❌ Nenhum arquivo de capa localizado (esperado algo como ${dir}/capaLOA.pdf)"
    echo ""
    return 0
  fi

  if [ "${#matches[@]}" -gt 1 ]; then
    echo "Volume ${vol}: ⚠️  Múltiplas variações encontradas:"
    for f in "${matches[@]}"; do
      echo "  - $f"
    done
    echo "Escolha manualmente qual renomear para ${dir}/capaLOA.pdf e reexecute se necessário."
    echo ""
    return 0
  fi

  local src="${matches[0]}"
  local dst="${dir}/capaLOA.pdf"

  if [ -f "$dst" ]; then
    echo "Volume ${vol}: ⚠️  Arquivo destino já existe: $dst (nenhuma ação tomada)"
    echo ""
    return 0
  fi

  # Se a origem já tem o nome correto (mas vindo via -iname), apenas confirmar
  if [ "$(basename "$src")" = "capaLOA.pdf" ]; then
    echo "Volume ${vol}: ✅ Arquivo já padronizado em: $src"
    echo ""
    return 0
  fi

  echo "Volume ${vol}: ⚠️  Encontrado arquivo de capa com nome diferente: $src"
  echo "Comando que será executado para padronizar:"
  echo "  mv \"$src\" \"$dst\""

  if confirm "Deseja renomear este arquivo agora?"; then
    mv "$src" "$dst"
    echo "Volume ${vol}: ✅ Renomeado com sucesso para $dst"
  else
    echo "Volume ${vol}: - Renomeação cancelada a pedido do usuário."
  fi

  echo ""
}

for vol in 1 2 3 4 5 6 7; do
  normalize_volume_cover "$vol"
done

echo "=== FIM DA NORMALIZAÇÃO DE CAPAS ==="



