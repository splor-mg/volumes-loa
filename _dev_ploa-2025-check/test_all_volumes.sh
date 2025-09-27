#!/bin/bash

# Script para testar/checar todos os volumes após correções
# Modo informativo: mostra o que seria validado e o status atual

set -euo pipefail

mkdir -p _temp
LOG_FILE="_dev_ploa-2025-checkvolume7_test_output.log"
{
echo "=== TESTANDO/CHECANDO TODOS OS VOLUMES (MODO INFORMATIVO) ==="
echo ""

# Função para testar um volume específico
test_volume() {
    local vol=$1
    local vol_name=$2
    
    echo "Checando Volume $vol ($vol_name)..."
    
    # Verificar se o script principal do volume existe
    local script_path=""
    case $vol in
        1) script_path="volume1/R" ;;
        2) script_path="volume2/R" ;;
        3) script_path="volume3/R" ;;
        4) script_path="volume4/R" ;;
        5) script_path="volume5/R" ;;
        6) script_path="volume6/R" ;;
        7) script_path="volume7/R" ;;
    esac
    
    if [ -d "$script_path" ]; then
        echo "  ✅ Diretório encontrado: $script_path"
        
        # Contar quantos scripts .R existem
        local script_count=$(find "$script_path" -name "*.R" | wc -l)
        echo "  📊 Scripts .R encontrados: $script_count"
        
        # Verificar se há scripts que referenciam funcoes.r (minúsculo)
        local problem_count=$(find "$script_path" -name "*.R" -exec grep -l "funcoes\.r" {} \; 2>/dev/null | wc -l)
        if [ $problem_count -eq 0 ]; then
            echo "  ✅ Nenhum problema de case sensitivity encontrado"
        else
            echo "  ⚠️  Ainda existem $problem_count scripts com problema de case sensitivity"
        fi
        
    else
        echo "  ❌ Diretório NÃO encontrado: $script_path"
    fi
    
    echo ""
}

# Testar cada volume
test_volume 1 "Demonstrativos DCGF e PRODEMGE"
test_volume 2 "Programa de Trabalho e Recursos Financeiros"
test_volume 3 "Programa de Investimentos"
test_volume 4 "Detalhamento de Investimentos por Territórios"
test_volume 5 "Quadro de Detalhamento da Despesa"
test_volume 6 "Receita e Despesa por Fonte STN"
test_volume 7 "Quadro de Detalhamento da Despesa - Fonte 95"

echo "=== RESUMO DAS CHECAGENS ==="
echo ""

# Verificar se ainda existem problemas globais
echo "Verificando problemas globais restantes..."
echo ""

# Verificar se funcoes.R existe
if [ -f "utils/funcoes.R" ]; then
    echo "✅ utils/funcoes.R existe"
else
    echo "❌ utils/funcoes.R NÃO existe"
fi

# Contar problemas de case sensitivity restantes
total_problems=$(find . -name "*.R" -type f -exec grep -l "funcoes\.r" {} \; 2>/dev/null | wc -l)
if [ $total_problems -eq 0 ]; then
    echo "✅ Nenhum problema de case sensitivity restante"
else
    echo "⚠️  Ainda existem $total_problems arquivos com problema de case sensitivity"
    echo "Arquivos com problema:"
    find . -name "*.R" -type f -exec grep -l "funcoes\.r" {} \; 2>/dev/null | sed 's/^/  - /'
fi

echo ""
echo "=== FIM DAS CHECAGENS ==="
} | tee "$LOG_FILE"
