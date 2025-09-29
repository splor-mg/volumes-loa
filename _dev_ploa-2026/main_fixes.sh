#!/bin/bash

# Script principal para protocolos de manutenção do projeto volumes-loa
# Uso:
#   bash _dev_ploa-2026/main_fixes.sh capas-symlink [--dry-run] [--force] [--volumes 2,3]

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &> /dev/null && pwd)"

ensure_exec() {
  echo "Configurando permissões de execução em ${SCRIPT_DIR}:"
  # Lista explícita para evitar alterar arquivos indevidos
  local files=(
    "${SCRIPT_DIR}/main_fixes.sh"
    "${SCRIPT_DIR}/capas_symlink.py"
  )
  for f in "${files[@]}"; do
    if [ -f "$f" ]; then
      chmod +x "$f" || true
      echo "  +x $(basename "$f")"
    fi
  done
}

confirm() {
  local prompt_msg="$1"
  local default_answer="n"
  local answer
  echo ""
  read -r -p "$prompt_msg (y/n): " answer || true
  answer=${answer:-$default_answer}
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

show_protocols() {
  echo "========================================================"
  echo "PROTOCOLOS DISPONÍVEIS - PROJETO VOLUMES-LOA"
  echo "========================================================"
  echo ""
  echo "1) capas-symlink    - Criar/atualizar symlinks de capaLOA.pdf nos volumes (>=2)"
  echo "   Uso: bash _dev_ploa-2026/main_fixes.sh capas-symlink [--dry-run] [--force] [--volumes 2,3]"
  echo ""
}

run_capas_symlink_flow() {
  echo "Protocolo: capas-symlink"
  echo "- Fonte: ${REPO_ROOT}/capas/capaLOA.pdf"
  echo "- Alvos: volume*/Rnw/capaLOA.pdf (>= volume2)"
  # Descoberta de volumes (>=2)
  mapfile -t DETECTED_VOLUMES < <(ls -d "${REPO_ROOT}"/volume*/Rnw 2>/dev/null | sed -E 's#.*/volume([0-9]+)/Rnw#\1#g' | awk '$1 >= 2' | sort -n | uniq)
  echo "Volumes detectados: ${DETECTED_VOLUMES[*]:-nenhum}"

  # Limitar volumes?
  VOLUMES_ARG=""
  if confirm "Deseja limitar a execução a volumes específicos?"; then
    read -r -p "Informe números separados por vírgula (ex.: 2,5,7): " USER_VOLS || true
    if [ -n "${USER_VOLS:-}" ]; then
      VOLUMES_ARG=("--volumes" "${USER_VOLS}")
    fi
  fi

  # Fazer dry-run primeiro?
  if confirm "Executar um dry-run (simulação) antes?"; then
    echo "-- DRY-RUN --"
    python3 "${SCRIPT_DIR}/capas_symlink.py" --dry-run ${VOLUMES_ARG:+"${VOLUMES_ARG[@]}"}
    echo "-- FIM DO DRY-RUN --"
  fi

  # Aplicar mudanças reais?
  if confirm "Aplicar mudanças agora?"; then
    FORCE_ARG=()
    if confirm "Forçar recriação dos links mesmo se já corretos (--force)?"; then
      FORCE_ARG=("--force")
    fi
    python3 "${SCRIPT_DIR}/capas_symlink.py" ${FORCE_ARG:+"${FORCE_ARG[@]}"} ${VOLUMES_ARG:+"${VOLUMES_ARG[@]}"}
    echo "OK: symlinks atualizados."
  else
    echo "Pulado pelo usuário."
  fi
}

ensure_exec

case "${1-}" in
  capas-symlink)
    shift || true
    run_capas_symlink_flow
    ;;
  "")
    # Fluxo padrão sem argumentos: listar e executar etapas em sequência com confirmações
    show_protocols
    if confirm "Deseja executar o protocolo 1) capas-symlink agora?"; then
      run_capas_symlink_flow
    else
      echo "Nenhum protocolo executado."
    fi
    ;;
  help|-h|--help)
    show_protocols
    ;;
  *)
    echo "Comando desconhecido: $1" >&2
    echo "Use: bash _dev_ploa-2026/main_fixes.sh help" >&2
    exit 1
    ;;
esac

