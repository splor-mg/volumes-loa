#!/bin/bash

# Script para corrigir problema de case sensitivity
# Modo interativo: mostra o comando exato e pede confirmação

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

echo "=== Corrigindo case sensitivity de funcoes.r para funcoes.R (INTERATIVO) ==="
echo "Procurando arquivos .R que contêm 'funcoes.r'..."

# Primeiro, vamos ver quantos arquivos serão afetados
count=$(find . -name "*.R" -type f -exec grep -l "funcoes\\.r" {} \; | wc -l)
echo "Encontrados $count arquivos que precisam ser corrigidos"

if [ "$count" -eq 0 ]; then
  echo "Nenhum arquivo encontrado com 'funcoes.r'"
  exit 0
fi

echo ""
echo "Arquivos que serão modificados:"
find . -name "*.R" -type f -exec grep -l "funcoes\\.r" {} \;

echo ""
echo "Comando que será executado para aplicar a correção (com backup .bak):"
echo "  find . -name \"*.R\" -type f -exec sed -i.bak 's/funcoes\\.r/funcoes.R/g' {} \\;"

if confirm "Deseja aplicar a correção agora?"; then
  echo "Executando correção..."
  find . -name "*.R" -type f -exec sed -i.bak 's/funcoes\\.r/funcoes.R/g' {} \;
  echo "Correção concluída!"
  echo ""
  echo "Backups criados com extensão .bak."
  if confirm "Deseja remover todos os arquivos .bak gerados agora?"; then
    find . -name "*.R.bak" -type f -print -delete
    echo "Backups .bak removidos."
  else
    echo "Backups mantidos conforme solicitado."
  fi
else
  echo "Correção cancelada a pedido do usuário."
  exit 0
fi

echo ""
echo "Verificando se ainda existem arquivos com 'funcoes.r':"
remaining=$(find . -name "*.R" -type f -exec grep -l "funcoes\\.r" {} \; | wc -l)
if [ "$remaining" -eq 0 ]; then
  echo "✅ Todos os arquivos foram corrigidos com sucesso!"
else
  echo "⚠️  Ainda existem $remaining arquivos com 'funcoes.r'"
fi
