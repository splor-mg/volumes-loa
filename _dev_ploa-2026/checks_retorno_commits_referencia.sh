#!/bin/bash

# =============================================================================
# Script para reverter checks conforme _temp/checks_commits_referencia.yml
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
if [ ! -d "checks" ]; then
    print_error "Diretório 'checks' não encontrado. Execute este script na raiz do projeto."
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

print_info "=== REVERTENDO CHECKS PARA VERSÃO LOA 2025 ==="
echo

# Ler commit do YAML
COMMITS_FILE="_temp/checks_commits_referencia.yml"
[ -n "$1" ] && COMMITS_FILE="$1"
if [ ! -f "$COMMITS_FILE" ]; then
    print_error "Arquivo de commits não encontrado: $COMMITS_FILE"
    exit 1
fi

print_info "Lendo commit de: $COMMITS_FILE"

# Extrair o commit da seção checks
commit=""
while IFS= read -r line; do
    line=$(echo "$line" | sed 's/\t/    /g')
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^# ]] && continue
    if echo "$line" | grep -q "^checks:"; then
        commit=$(echo "$line" | sed -E 's/^checks:\s*([0-9a-f]{7,40}).*/\1/' | xargs)
        break
    fi
done < "$COMMITS_FILE"

if [ -z "$commit" ]; then
    print_error "Commit não encontrado na seção 'checks:' do arquivo $COMMITS_FILE"
    exit 1
fi

print_info "Commit encontrado: $commit"

# Verificar se o commit existe
print_info "Verificando se o commit existe..."
if ! git cat-file -e "$commit^{commit}" 2>/dev/null; then
    print_error "Commit $commit não encontrado no repositório."
    exit 1
fi
print_success "Commit foi encontrado."
echo

# Mostrar status atual
print_info "Status atual do repositório:"
git status --porcelain | head -10
if [ $(git status --porcelain | wc -l) -gt 10 ]; then
    print_warning "... e mais $(($(git status --porcelain | wc -l) - 10)) arquivos modificados"
fi
echo

# Perguntar confirmação
print_warning "ATENÇÃO: Este script irá reverter a pasta 'checks/' para o commit: $commit"
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
    cp -r checks "$backup_dir/"
    print_success "Backup criado em $backup_dir/"
    echo
fi

# Reverter pasta checks
print_info "Revertendo pasta 'checks/' para commit $commit..."

# Fazer checkout dos arquivos
if git checkout "$commit" -- "checks/"; then
    print_success "✓ Pasta 'checks/' revertida com sucesso"
else
    print_error "✗ Falha ao reverter pasta 'checks/'"
    exit 1
fi

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
print_info "Para desfazer as alterações, use: git checkout HEAD -- checks/"
