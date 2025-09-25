#!/bin/bash

# Script principal para correções amplas no projeto volumes-loa
# Modo interativo: mostra os comandos que serão executados e pede confirmação

set -euo pipefail

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
  echo "1.  Verificação do Estado Atual"
  echo "    - Analisa arquivos e estrutura do projeto"
  echo "    - Script: check_current_state.sh"
  echo ""
  echo "2.  Correção de Case Sensitivity"
  echo "    - Substitui 'funcoes.r' → 'funcoes.R'"
  echo "    - Script: fix_case_sensitivity.sh"
  echo ""
  echo "3.  Correção de Nomes de Arquivos .Rnw"
  echo "    - Alinha nomes com o esperado pelo Makefile"
  echo "    - Script: fix_filename_according_to_makefile.sh"
  echo ""
  echo "4.  Normalização de Capas"
  echo "    - Padroniza nomes de capaLOA.pdf"
  echo "    - Script: normalize_covers.sh"
  echo ""
  echo "5.  Correção de Scripts .R"
  echo "    - Alinha nomes dos scripts .R com Makefile"
  echo "    - Script: fix_R_script_filenames_according_to_makefile.sh"
  echo ""
  echo "6.  Alinhamento de Nomes dos Checks"
  echo "    - Corrige nomes dos arquivos de referência"
  echo "    - Script: fix_checks_filenames.sh"
  echo ""
  echo "7.  Reverter Datapackages para LOA 2025"
  echo "    - Reverte datapackages para commits específicos"
  echo "    - Script: datapckgs_retorno_bases_ultima_ploa.sh"
  echo "    - ⚠️  ATENÇÃO: Esta operação irá reverter arquivos para commits específicos"
  echo ""
  echo "8.  Instalar Pacotes R do Bitbucket"
  echo "    - Instala versões específicas dos pacotes R"
  echo "    - Script: instacao_pacotes_bitbucket_ultima_ploa.sh"
  echo "    - ⚠️  ATENÇÃO: Esta operação deve ser executada com a imagem Docker rodando"
  echo "    - Execute 'make docker' antes de prosseguir"
  echo ""
  echo "9.  Testes/Checagens Pós-Correção"
  echo "    - Testa todos os volumes após as correções"
  echo "    - Script: test_all_volumes.sh"
  echo ""
  echo "0.  Executar Todos os Protocolos (1-9)"
  echo "    - Executa todos os protocolos na ordem recomendada"
  echo ""
}

get_start_option() {
  local start_option
  while true; do
    if [ -t 0 ]; then
      printf "A partir de qual protocolo deseja começar? (1-9, 0=executar todos): " 1>&2
      read -r start_option
    else
      read -r -p "A partir de qual protocolo deseja começar? (1-9, 0=executar todos): " start_option
    fi
    case $start_option in
      [0-9]) 
        if [ "$start_option" -ge 0 ] && [ "$start_option" -le 9 ]; then
          echo "$start_option"
          return
        else
          echo "Opção inválida. Digite um número entre 0 e 9."
        fi
        ;;
      *) echo "Opção inválida. Digite um número entre 0 e 9." ;;
    esac
  done
}

echo "========================================================"
echo "CORREÇÕES AMPLAS - PROJETO VOLUMES-LOA (INTERATIVO)"
echo "========================================================"
echo ""

# Mostrar protocolos disponíveis
show_protocols

# Obter opção de início
start_option=$(get_start_option)

echo ""
echo "========================================================"
echo "INICIANDO EXECUÇÃO"
echo "========================================================"
echo ""

# Ajuste automático de safe.directory para evitar erro de repositório 'duvidoso'
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git rev-parse --is-inside-work-tree 2>&1 | grep -qi 'dubious ownership'; then
    echo "[setup] Detectado 'dubious ownership'. Configurando diretório como seguro para o Git..."
    git config --global --add safe.directory "$(pwd)" || true
  fi
fi

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
chmod +x _temp/datapckgs_retorno_bases_ultima_ploa.sh
chmod +x _temp/install_pacotes_bitbucket_ultima_ploa.sh
chmod +x _temp/test_all_volumes.sh

# Divisória antes de iniciar a sequência de protocolos
echo ""
echo "--------------------------------------------------------"

# Função para executar protocolo
execute_protocol() {
  local protocol_num="$1"
  local protocol_name="$2"
  local script_name="$3"
  local warning="$4"
  
  echo ""
  echo "--------------------------------------------------------"
  echo ""
  echo "=== PROTOCOLO $protocol_num: $protocol_name ==="
  if [ -n "$warning" ]; then
    echo "⚠️  $warning"
  fi
  # Descrição detalhada por protocolo
  case "$script_name" in
    check_current_state.sh)
      echo "Objetivo: Mapear rapidamente o estado do repo (arquivos, volumes, dependências)."
      echo "O que faz:"
      echo "  - Verifica existência de utils/funcoes.R e ocorrência de 'funcoes.r' nos .R"
      echo "  - Lista quantidade de scripts por volume e confere arquivos-chave em 'bancos/'"
      ;;
    fix_case_sensitivity.sh)
      echo "Objetivo: Corrigir referências 'funcoes.r' → 'funcoes.R' em scripts R (case-sensitive no Linux)."
      echo "O que faz:"
      echo "  - Substitui em todos os .R; cria backups '.R.bak' e oferece removê-los ao final"
      echo "Pré-requisito: Arquivo real deve ser 'utils/funcoes.R'"
      ;;
    fix_filename_according_to_makefile.sh)
      echo "Objetivo: Padronizar nomes de arquivos .Rnw conforme regras esperadas."
      echo "O que faz:"
      echo "  - Lê alvos em 'utils/makefile/' e propõe renomear variações em 'volume1/Rnw/'"
      echo "Observação: Atualmente focado no Volume 1"
      ;;
    normalize_covers.sh)
      echo "Objetivo: Padronizar capas para 'capaLOA.pdf' em 'volume*/Rnw/'."
      echo "O que faz:"
      echo "  - Detecta variações (case-insensitive) e renomeia com confirmação"
      ;;
    fix_R_script_filenames_according_to_makefile.sh)
      echo "Objetivo: Alinhar nomes de scripts .R aos stems esperados pelo Makefile."
      echo "O que faz:"
      echo "  - Extrai stems do Makefile; tenta localizar variações e renomear em 'volume1/R/'"
      echo "Observação: Usa heurística para prefixos 'Tn_' quando necessário"
      ;;
    fix_checks_filenames.sh)
      echo "Objetivo: Alinhar nomes de golden .tex ao que os testes esperam."
      echo "O que faz:"
      echo "  - Lê nomes via Report('NAME', ...) nos testes e renomeia em 'checks/assets/tex/'"
      ;;
    datapckgs_retorno_bases_ultima_ploa.sh)
      echo "Objetivo: Reverter 'datapackages/*' para versões da LOA 2025."
      echo "O que faz:"
      echo "  - Lê SHAs em '_temp/datapckgs_commits_ultima_ploa.yml' e faz 'git checkout' dirigido por pasta"
      echo "  - Oferece criar backup em diretório _backup_TIMESTAMP"
      echo "Configuração: _temp/datapckgs_commits_ultima_ploa.yml"
      ;;
    install_pacotes_bitbucket_ultima_ploa.sh)
      echo "Objetivo: Instalar versões específicas dos pacotes R a partir do Bitbucket."
      echo "O que faz:"
      echo "  - Executa Rscript no container Docker e registra logs em 'logs/install_r_pkgs.log'"
      echo "Configuração: _temp/pacotes_bitbucket_versoes_ultima_ploa.yml"
      echo "Pré-requisitos: Docker ativo (make docker), .env com BITBUCKET_AUTH_USER e BITBUCKET_APP_PASSWORD"
      ;;
    test_all_volumes.sh)
      echo "Objetivo: Checar pós-correções por volume e consolidar um resumo."
      echo "O que faz:"
      echo "  - Conta scripts, detecta 'funcoes.r' remanescente e grava log em '_temp/volume7_test_output.log'"
      ;;
  esac
  echo "   Comando a executar: ./_temp/$script_name"
  
  if confirm "Deseja executar este protocolo agora?"; then
    ./_temp/$script_name
  else
    echo "- Protocolo '$protocol_name' pulado a pedido do usuário."
  fi
}

# Executar protocolos baseado na opção escolhida
if [ "$start_option" -eq 0 ]; then
  # Executar todos os protocolos
  echo "Executando todos os protocolos na ordem recomendada..."
  echo ""
  
  execute_protocol "1" "Verificação do Estado Atual" "check_current_state.sh" ""
  execute_protocol "2" "Correção de Case Sensitivity" "fix_case_sensitivity.sh" ""
  execute_protocol "3" "Correção de Nomes de Arquivos .Rnw" "fix_filename_according_to_makefile.sh" ""
  execute_protocol "4" "Normalização de Capas" "normalize_covers.sh" ""
  execute_protocol "5" "Correção de Scripts .R" "fix_R_script_filenames_according_to_makefile.sh" ""
  execute_protocol "6" "Alinhamento de Nomes dos Checks" "fix_checks_filenames.sh" ""
  execute_protocol "7" "Reverter Datapackages para LOA 2025" "datapckgs_retorno_bases_ultima_ploa.sh" "Esta operação irá reverter arquivos para commits específicos. Faça backup se necessário."
  execute_protocol "8" "Instalar Pacotes R do Bitbucket" "install_pacotes_bitbucket_ultima_ploa.sh" "Esta operação deve ser executada com a imagem Docker rodando. Execute 'make docker' antes de prosseguir."
  execute_protocol "9" "Testes/Checagens Pós-Correção" "test_all_volumes.sh" ""
  
else
  # Executar a partir do protocolo escolhido
  case $start_option in
    1) execute_protocol "1" "Verificação do Estado Atual" "check_current_state.sh" "" ;;
    2) execute_protocol "2" "Correção de Case Sensitivity" "fix_case_sensitivity.sh" "" ;;
    3) execute_protocol "3" "Correção de Nomes de Arquivos .Rnw" "fix_filename_according_to_makefile.sh" "" ;;
    4) execute_protocol "4" "Normalização de Capas" "normalize_covers.sh" "" ;;
    5) execute_protocol "5" "Correção de Scripts .R" "fix_R_script_filenames_according_to_makefile.sh" "" ;;
    6) execute_protocol "6" "Alinhamento de Nomes dos Checks" "fix_checks_filenames.sh" "" ;;
    7) execute_protocol "7" "Reverter Datapackages para LOA 2025" "datapckgs_retorno_bases_ultima_ploa.sh" "Esta operação irá reverter arquivos para commits específicos. Faça backup se necessário." ;;
    8) execute_protocol "8" "Instalar Pacotes R do Bitbucket" "install_pacotes_bitbucket_ultima_ploa.sh" "Esta operação deve ser executada com a imagem Docker rodando. Execute 'make docker' antes de prosseguir." ;;
    9) execute_protocol "9" "Testes/Checagens Pós-Correção" "test_all_volumes.sh" "" ;;
  esac
fi

echo ""
echo "========================================================"
echo "Fluxo interativo concluído."
echo "Você pode reexecutar qualquer protocolo manualmente a partir de _temp/."
echo "========================================================"