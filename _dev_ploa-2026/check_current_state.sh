#!/bin/bash

set -euo pipefail

# Script para verificar o estado atual do projeto
# Mostra quais arquivos têm o problema de case sensitivity

echo "=== VERIFICAÇÃO DO ESTADO ATUAL ==="
echo ""

# Verificar se o arquivo funcoes.R existe
echo "1. Verificando arquivo utils/funcoes.R:"
if [ -f "utils/funcoes.R" ]; then
    echo "   ✅ Arquivo existe: utils/funcoes.R"
    ls -la utils/funcoes.R
else
    echo "   ❌ Arquivo NÃO existe: utils/funcoes.R"
fi

echo ""

# Verificar se existe funcoes.r (minúsculo)
echo "2. Verificando se existe utils/funcoes.r (minúsculo):"
if [ -f "utils/funcoes.r" ]; then
    echo "   ⚠️  Arquivo existe: utils/funcoes.r (minúsculo)"
    ls -la utils/funcoes.r
else
    echo "   ✅ Arquivo NÃO existe: utils/funcoes.r (minúsculo)"
fi

echo ""

# Contar quantos arquivos .R referenciam funcoes.r (minúsculo)
echo "3. Arquivos .R que referenciam 'funcoes.r' (minúsculo):"
count=$(find . -name "*.R" -type f -exec grep -l "funcoes\.r" {} \; 2>/dev/null | wc -l)
echo "   Encontrados: $count arquivos"

if [ $count -gt 0 ]; then
    echo ""
    echo "   Lista dos arquivos:"
    find . -name "*.R" -type f -exec grep -l "funcoes\.r" {} \; 2>/dev/null | while read file; do
        echo "   - $file"
        # Mostrar a linha específica
        grep -n "funcoes\.r" "$file" | head -1 | sed 's/^/     /'
    done
fi

echo ""

# Verificar estrutura geral dos volumes
echo "4. Verificando estrutura dos volumes:"
for vol in 1 2 3 4 5 6 7; do
    if [ -d "volume$vol/R" ]; then
        script_count=$(find "volume$vol/R" -name "*.R" | wc -l)
        echo "   ✅ Volume $vol: $script_count scripts .R"
    else
        echo "   ❌ Volume $vol: diretório R não encontrado"
    fi
done

echo ""

# Verificar dependências principais
echo "5. Verificando dependências principais:"
deps=(
    "bancos/SISOR/BASE_QDD_FISCAL.xlsx"
    "bancos/SISOR/BASE_QDD_FISCAL_FONTE_95.xlsx"
    "bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx"
    "bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx"
    "bancos/manual/codigosPoder.xlsx"
    "bancos/manual/desc_classificacao_economica_despesa.xlsx"
    "bancos/manual/desc_grupos_de_despesa.xlsx"
)

for dep in "${deps[@]}"; do
    if [ -f "$dep" ]; then
        echo "   ✅ $dep"
    else
        echo "   ❌ $dep (FALTANDO)"
    fi
done

echo ""
echo "=== FIM DA VERIFICAÇÃO ==="
