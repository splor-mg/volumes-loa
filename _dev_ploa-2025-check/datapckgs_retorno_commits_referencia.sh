#!/bin/bash

# =============================================================================
# Script para reverter datapackages conforme _dev_ploa-2025-checkdatapckgs_commits_referencia.yml
# =============================================================================

set -e  # Para o script em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se estamos no diretório correto
if [ ! -d "datapackages" ]; then
    print_error "Diretório 'datapackages' não encontrado. Execute este script na raiz do projeto."
    exit 1
fi

# Verificar se o git está inicializado e contornar 'dubious ownership'
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    # Tenta detectar se é o erro de ownership dúbio
    if git rev-parse --is-inside-work-tree 2>&1 | grep -qi 'dubious ownership'; then
        print_warning "Repositório com 'dubious ownership'. Configurando como safe.directory..."
        git config --global --add safe.directory "$(pwd)" || true
        # Tenta novamente
        if ! git rev-parse --git-dir > /dev/null 2>&1; then
            print_error "Este não é um repositório Git válido."
            exit 1
        fi
    else
        print_error "Este não é um repositório Git válido."
        exit 1
    fi
fi

print_info "=== REVERTENDO DATAPACKAGES PARA VERSÕES LOA 2025 ==="
echo

# Ler commits do YAML
COMMITS_FILE="_dev_ploa-2025-checkdatapckgs_commits_referencia.yml"
[ -n "$1" ] && COMMITS_FILE="$1"
if [ ! -f "$COMMITS_FILE" ]; then
    print_error "Arquivo de commits não encontrado: $COMMITS_FILE"
    exit 1
fi

print_info "Lendo commits de: $COMMITS_FILE"

declare -A commits
in_section=0
while IFS= read -r line; do
    line=$(echo "$line" | sed 's/\t/    /g')
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^# ]] && continue
    if echo "$line" | grep -q "^datapackages:"; then in_section=1; continue; fi
    if [ $in_section -eq 1 ]; then
        if echo "$line" | grep -q "^[^[:space:]]"; then in_section=0; continue; fi
        if echo "$line" | grep -q "^[[:space:]]\{2,\}[A-Za-z0-9_.-]\+:\s*[0-9a-f]\{7,40\}\s*$"; then
            name=$(echo "$line" | sed -E 's/^[[:space:]]+([^:]+):.*/\1/' | xargs)
            sha=$(echo  "$line" | sed -E 's/^[^:]+:\s*([0-9a-f]{7,40}).*/\1/' | xargs)
            [ -n "$name" ] && [ -n "$sha" ] && commits["$name"]="$sha"
        fi
    fi
done < "$COMMITS_FILE"

# Verificar se os commits existem
print_info "Verificando se os commits existem..."
for datapackage in "${!commits[@]}"; do
    commit="${commits[$datapackage]}"
    if ! git cat-file -e "$commit^{commit}" 2>/dev/null; then
        print_error "Commit $commit para $datapackage não encontrado no repositório."
        exit 1
    fi
done
print_success "Todos os commits foram encontrados."
echo

# Mostrar status atual
print_info "Status atual do repositório:"
git status --porcelain | head -10
if [ $(git status --porcelain | wc -l) -gt 10 ]; then
    print_warning "... e mais $(($(git status --porcelain | wc -l) - 10)) arquivos modificados"
fi
echo

# Perguntar confirmação
print_warning "ATENÇÃO: Este script irá reverter os seguintes datapackages:"
for datapackage in "${!commits[@]}"; do
    commit="${commits[$datapackage]}"
    echo "  - $datapackage -> $commit"
done
echo

read -r -p "Deseja continuar? (y/n): " REPLY
if [[ ! $REPLY =~ ^([Yy]|[Yy][Ee][Ss])$ ]]; then
    print_info "Operação cancelada pelo usuário."
    exit 0
fi

# Fazer backup opcional
read -r -p "Deseja fazer backup dos arquivos atuais antes de reverter? (y/n): " REPLY
if [[ $REPLY =~ ^([Yy]|[Yy][Ee][Ss])$ ]]; then
    backup_dir="_backup_$(date +%Y%m%d_%H%M%S)"
    print_info "Criando backup em $backup_dir..."
    mkdir -p "$backup_dir"
    cp -r datapackages "$backup_dir/"
    print_success "Backup criado em $backup_dir/"
    echo
fi

# Reverter cada datapackage
print_info "Iniciando reversão dos datapackages..."
echo

for datapackage in "${!commits[@]}"; do
    commit="${commits[$datapackage]}"
    
    print_info "Revertendo $datapackage para commit $commit..."
    
    # Verificar se a pasta existe
    if [ ! -d "datapackages/$datapackage" ]; then
        print_warning "Pasta datapackages/$datapackage não existe. Pulando..."
        continue
    fi
    
    # Fazer checkout dos arquivos
    if git checkout "$commit" -- "datapackages/$datapackage/"; then
        print_success "✓ $datapackage revertido com sucesso"
    else
        print_error "✗ Falha ao reverter $datapackage"
        exit 1
    fi
done

echo
print_success "Reversão concluída!"

# Mostrar status final
print_info "Status após reversão:"
git status --porcelain | head -20
if [ $(git status --porcelain | wc -l) -gt 20 ]; then
    print_warning "... e mais $(($(git status --porcelain | wc -l) - 20)) arquivos modificados"
fi
echo

# Não fazer commit automaticamente - deixar para o usuário decidir
print_info "Alterações não foram commitadas. Use 'git add' e 'git commit' quando desejar."

echo
print_success "=== SCRIPT CONCLUÍDO ==="
print_info "Para desfazer as alterações, use: git checkout HEAD -- datapackages/"