#!/bin/bash

# Script principal para correções amplas no projeto volumes-loa
# Modo interativo: mostra os comandos que serão executados e pede confirmação

set -euo pipefail

confirm() {
  local prompt_msg="$1"
  local default_answer="N"
  local answer
  echo ""
  read -r -p "$prompt_msg [y/N]: " answer || true
  answer=${answer:-$default_answer}
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

echo "=========================================="
echo "CORREÇÕES AMPLAS - PROJETO VOLUMES-LOA (INTERATIVO)"
echo "=========================================="
echo ""

# Tornar os scripts executáveis (não executa nada do projeto)
echo "Tornando scripts auxiliares executáveis:"
echo "  chmod +x _temp/check_current_state.sh"
echo "  chmod +x _temp/fix_case_sensitivity.sh"
echo "  chmod +x _temp/test_all_volumes.sh"
chmod +x _temp/check_current_state.sh
chmod +x _temp/fix_case_sensitivity.sh
chmod +x _temp/fix_filename_according_to_makefile.sh
chmod +x _temp/normalize_covers.sh
chmod +x _temp/fix_R_script_filenames_according_to_makefile.sh
chmod +x _temp/fix_checks_filenames.sh
chmod +x _temp/test_all_volumes.sh

# 1) Verificar estado atual
echo ""
echo "1) Verificação do estado atual"
echo "   Comando a executar: ./_temp/check_current_state.sh"
if confirm "Deseja executar a verificação agora?"; then
  ./_temp/check_current_state.sh
else
  echo "- Etapa 'verificação' pulada a pedido do usuário."
fi

# 2) Correção de case sensitivity
echo ""
echo "2) Correção de case sensitivity (substituir 'funcoes.r' → 'funcoes.R')"
echo "   Este passo chamará o script que lista arquivos afetados e pergunta antes de aplicar a mudança."
echo "   Comando a executar: ./_temp/fix_case_sensitivity.sh"
if confirm "Deseja executar a correção agora?"; then
  ./_temp/fix_case_sensitivity.sh
else
  echo "- Etapa 'correção' pulada a pedido do usuário."
fi

# 3) Correção de case sensitivity em nomes de arquivos .Rnw
echo ""
echo "3) Correção de case sensitivity em nomes de arquivos .Rnw"
echo "   Este passo detecta arquivos .Rnw com nomes incorretos (ex.: T7_Quadro_Geral_da_Receita.Rnw)"
echo "   e oferece renomear para o nome esperado pelo Makefile (ex.: T7_QUADRO_GERAL_DA_RECEITA.Rnw)."
echo "   Comando a executar: ./_temp/fix_filename_according_to_makefile.sh"
if confirm "Deseja executar a correção de nomes de arquivos agora?"; then
  ./_temp/fix_filename_according_to_makefile.sh
else
  echo "- Etapa 'correção de nomes de arquivos' pulada a pedido do usuário."
fi

# 4) Normalização de capas (capaLOA.pdf) por volume
echo ""
echo "4) Normalizar nomes de capas (capaLOA.pdf) em volume*/Rnw/"
echo "   Este passo detecta variações de nome (ex.: CapaLOA.pdf) e oferece renomear para 'capaLOA.pdf'."
echo "   Comando a executar: ./_temp/normalize_covers.sh"
if confirm "Deseja executar a normalização de capas agora?"; then
  ./_temp/normalize_covers.sh
else
  echo "- Etapa 'normalização de capas' pulada a pedido do usuário."
fi

# 5) Correção de nomes de scripts .R conforme Makefile
echo ""
echo "5) Correção de nomes de scripts .R conforme Makefile"
echo "   Este passo detecta variações de nomes dos scripts .R esperados para gerar os .txt de volume1/data."
echo "   Comando a executar: ./_temp/fix_R_script_filenames_according_to_makefile.sh"
if confirm "Deseja executar a correção de scripts .R agora?"; then
  ./_temp/fix_R_script_filenames_according_to_makefile.sh
else
  echo "- Etapa 'correção de scripts .R' pulada a pedido do usuário."
fi

# 6) Alinhar nomes dos arquivos de referência dos checks (golden .tex)
echo ""
echo "6) Alinhar nomes dos arquivos de referência dos checks (golden .tex)"
echo "   Este passo verifica se os nomes em checks/assets/tex correspondem ao esperado pelos testes e propõe renomear."
echo "   Comando a executar: ./_temp/fix_checks_filenames.sh"
if confirm "Deseja executar o alinhamento dos nomes dos checks agora?"; then
  ./_temp/fix_checks_filenames.sh
else
  echo "- Etapa 'alinhamento de nomes dos checks' pulada a pedido do usuário."
fi

# 7) Testes/checagens pós-correção
echo ""
echo "7) Testar/checar todos os volumes após as correções"
echo "   Comando a executar: ./_temp/test_all_volumes.sh"
if confirm "Deseja executar os testes/checagens agora?"; then
  ./_temp/test_all_volumes.sh
else
  echo "- Etapa 'testes/checagens' pulada a pedido do usuário."
fi

echo ""
echo "=========================================="
echo "Fluxo interativo concluído."
echo "Você pode reexecutar qualquer etapa manualmente a partir de _temp/."
echo "=========================================="
