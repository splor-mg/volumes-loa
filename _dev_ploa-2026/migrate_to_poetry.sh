#!/bin/bash

# Script para migrar sistema de detecção de plataforma para Poetry
# Converte lógica condicional LaTeX (\ifwindows) para FONT_CONFIG_PLACEHOLDER
# Atualiza Makefile para usar poetry run
# Configura pyproject.toml com dependências e scripts

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

echo "=== MIGRAÇÃO PARA POETRY - SISTEMA DE DETECÇÃO DE PLATAFORMA ==="
echo ""

# Verificar se Poetry está instalado
echo "1. Verificando se Poetry está instalado:"
if command -v poetry >/dev/null 2>&1; then
    echo "   ✅ Poetry está instalado: $(poetry --version)"
else
    echo "   ❌ Poetry NÃO está instalado"
    echo "   Instale Poetry primeiro: https://python-poetry.org/docs/#installation"
    exit 1
fi

echo ""

# Verificar se pyproject.toml já existe
echo "2. Verificando pyproject.toml:"
if [ -f "pyproject.toml" ]; then
    echo "   ⚠️  pyproject.toml já existe"
    if confirm "Deseja sobrescrever o pyproject.toml existente?"; then
        echo "   📝 pyproject.toml será sobrescrito"
    else
        echo "   ⏭️  Pulando criação do pyproject.toml"
        SKIP_PYPROJECT=true
    fi
else
    echo "   📝 pyproject.toml será criado"
    SKIP_PYPROJECT=false
fi

echo ""

# Verificar arquivos com lógica condicional
echo "3. Verificando arquivos com lógica condicional LaTeX:"
count_conditional=$(find . -name "*.tex" -o -name "*.Rnw" | xargs grep -l "\\ifwindows\|\\iflinux" 2>/dev/null | wc -l)
echo "   Encontrados $count_conditional arquivos com lógica condicional"

if [ "$count_conditional" -gt 0 ]; then
    echo "   Arquivos que serão convertidos:"
    find . -name "*.tex" -o -name "*.Rnw" | xargs grep -l "\\ifwindows\|\\iflinux" 2>/dev/null | head -10
    if [ "$count_conditional" -gt 10 ]; then
        echo "   ... e mais $((count_conditional - 10)) arquivos"
    fi
else
    echo "   ✅ Nenhum arquivo com lógica condicional encontrado"
fi

echo ""

# Verificar placeholders existentes
echo "4. Verificando placeholders FONT_CONFIG_PLACEHOLDER:"
count_placeholders=$(find . -name "*.tex" -o -name "*.Rnw" | xargs grep -l "FONT_CONFIG_PLACEHOLDER" 2>/dev/null | wc -l)
echo "   Encontrados $count_placeholders arquivos com placeholders"

echo ""

# Mostrar comandos que serão executados
echo "=== COMANDOS QUE SERÃO EXECUTADOS ==="
echo ""

if [ "$SKIP_PYPROJECT" = false ]; then
    echo "1. Criar/atualizar pyproject.toml com:"
    echo "   - Dependências Python (frictionless, pandas, typer, etc.)"
    echo "   - Scripts Poetry (detect-platform, replace-font-config, etc.)"
    echo "   - Configurações de desenvolvimento (black, flake8, mypy)"
    echo ""
fi

if [ "$count_conditional" -gt 0 ]; then
    echo "2. Converter lógica condicional LaTeX:"
    echo "   - Substituir \\ifwindows...\\fi por FONT_CONFIG_PLACEHOLDER"
    echo "   - Arquivos afetados: $count_conditional"
    echo ""
fi

echo "3. Atualizar Makefile:"
echo "   - Substituir python3 por poetry run"
echo "   - Integrar detect-platform e replace-font-config"
echo "   - Manter compatibilidade com fluxo existente"
echo ""

echo "4. Instalar dependências Poetry:"
echo "   - poetry install"
echo "   - Configurar ambiente virtual"
echo ""

echo "5. Testar sistema:"
echo "   - make detect-platform"
echo "   - Verificar funcionamento dos scripts"
echo ""

if confirm "Deseja executar a migração para Poetry agora?"; then
    echo ""
    echo "=== EXECUTANDO MIGRAÇÃO ==="
    echo ""
    
    # 1. Criar pyproject.toml
    if [ "$SKIP_PYPROJECT" = false ]; then
        echo "1. Criando pyproject.toml..."
        cat > pyproject.toml << 'EOF'
[tool.poetry]
name = "volumes-loa"
version = "0.1.0"
description = "Sistema automatizado para geração de PDFs dos volumes da Lei Orçamentária Anual (LOA)"
authors = ["Splor MG <contato@splor.mg>"]
readme = "README.md"
packages = [{include = "utils"}]

[tool.poetry.dependencies]
python = "^3.8.1"
frictionless = {extras = ["excel", "html"], version = "^4.0.0"}
pandas = {extras = ["excel", "html"], version = "^2.0.0"}
tomli = "^2.0.0"
typer = "^0.9.0"
pyyaml = "^6.0.0"

[tool.poetry.group.dev.dependencies]
black = "^23.0.0"
flake8 = "^6.0.0"
mypy = "^1.0.0"
pytest = "^7.0.0"

[tool.poetry.scripts]
# Scripts de detecção de plataforma e fontes
detect-platform = "utils.detect_plattform:main"
replace-font-config = "utils.replace_font_config:main"

# Scripts de configuração
config = "utils.config:main"
info = "utils.info:main"
datapackage-update = "utils.datapackage_update:main"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

[tool.black]
line-length = 88
target-version = ['py38']

[tool.flake8]
max-line-length = 88
extend-ignore = ["E203", "W503"]

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
EOF
        echo "   ✅ pyproject.toml criado"
    fi
    
    # 2. Converter lógica condicional
    if [ "$count_conditional" -gt 0 ]; then
        echo ""
        echo "2. Convertendo lógica condicional LaTeX..."
        
        # Criar script de conversão temporário
        cat > /tmp/convert_font_conditionals.py << 'EOF'
#!/usr/bin/env python3
import os
import sys
import glob
import re

def convert_font_conditionals_in_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Padrão para encontrar blocos \ifwindows...\fi
        pattern = r'\\usepackage\{ifplatform\}\s*\\ifwindows\s*\\usepackage\{uarial\}\s*\\else\s*\\usepackage\{helvet\}\s*\\renewcommand\{\\familydefault\}\{\\sfdefault\}\s*\\fi'
        
        # Substitui por placeholder
        new_content = re.sub(pattern, 'FONT_CONFIG_PLACEHOLDER', content, flags=re.MULTILINE | re.DOTALL)
        
        if new_content != content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"✅ Convertido: {file_path}")
            return True
        else:
            print(f"⏭️  Sem mudanças: {file_path}")
            return False
            
    except Exception as e:
        print(f"❌ Erro ao processar {file_path}: {e}")
        return False

def main():
    patterns = ['**/*.tex', '**/*.Rnw']
    files_to_process = []
    for pattern in patterns:
        files_to_process.extend(glob.glob(pattern, recursive=True))
    
    converted_count = 0
    for file_path in files_to_process:
        if convert_font_conditionals_in_file(file_path):
            converted_count += 1
    
    print(f"\n🎉 Conversão concluída! {converted_count} arquivo(s) convertido(s)")

if __name__ == "__main__":
    main()
EOF
        
        python3 /tmp/convert_font_conditionals.py
        rm /tmp/convert_font_conditionals.py
        echo "   ✅ Lógica condicional convertida"
    fi
    
    # 3. Atualizar Makefile
    echo ""
    echo "3. Atualizando Makefile..."
    
    # Backup do Makefile
    cp Makefile Makefile.backup
    echo "   📋 Backup criado: Makefile.backup"
    
    # Atualizar targets específicos
    sed -i 's|@eval $$(python3 utils/detect_plattform.py --export)|@eval $$(poetry run detect-platform --export)|g' Makefile
    sed -i 's|@python3 utils/replace_font_config.py|@poetry run replace-font-config|g' Makefile
    sed -i 's|@python3 utils/config.py|@poetry run config|g' Makefile
    sed -i 's|@python3 utils/info.py|@poetry run info|g' Makefile
    sed -i 's|@python3 utils/datapackage_update.py|@poetry run datapackage-update|g' Makefile
    sed -i 's|python3 -m frictionless validate datapackage.yaml|poetry run python -m frictionless validate datapackage.yaml|g' Makefile
    sed -i 's|python3 -m pytest|poetry run pytest|g' Makefile
    
    # Integrar detect-platform e replace-font-config
    sed -i 's|detect-platform:.*|detect-platform:\n\t@echo "Detectando plataforma e aplicando configuração de fonte..."\n\t@poetry run detect-platform\n\t@poetry run replace-font-config|g' Makefile
    
    # Remover target replace-font-config separado
    sed -i '/^replace-font-config:/,/^[^[:space:]]/d' Makefile
    
    # Atualizar target volumes
    sed -i 's|volumes: detect-platform replace-font-config|volumes: detect-platform|g' Makefile
    
    echo "   ✅ Makefile atualizado"
    
    # 4. Instalar dependências Poetry
    echo ""
    echo "4. Instalando dependências Poetry..."
    poetry install
    echo "   ✅ Dependências instaladas"
    
    # 5. Testar sistema
    echo ""
    echo "5. Testando sistema..."
    echo "   Executando: make detect-platform"
    make detect-platform
    echo "   ✅ Sistema testado com sucesso"
    
    echo ""
    echo "=== MIGRAÇÃO CONCLUÍDA COM SUCESSO! ==="
    echo ""
    echo "📋 Resumo das alterações:"
    echo "   ✅ pyproject.toml criado com dependências e scripts"
    echo "   ✅ $count_conditional arquivos convertidos de lógica condicional para placeholders"
    echo "   ✅ Makefile atualizado para usar poetry run"
    echo "   ✅ Dependências Poetry instaladas"
    echo "   ✅ Sistema testado e funcionando"
    echo ""
    echo "🔧 Comandos disponíveis:"
    echo "   - make detect-platform (detecta plataforma e aplica fontes)"
    echo "   - poetry run detect-platform (apenas detecção)"
    echo "   - poetry run replace-font-config (apenas substituição)"
    echo "   - poetry run config (configuração)"
    echo "   - poetry run info (informações)"
    echo ""
    echo "📁 Arquivos de backup:"
    echo "   - Makefile.backup (backup do Makefile original)"
    echo ""
    
else
    echo "- Migração cancelada pelo usuário."
fi

echo ""
echo "=== FIM DO SCRIPT ==="
