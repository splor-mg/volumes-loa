#!/usr/bin/env python3
"""
Script para validar e corrigir anos no datapackage.yaml baseado na variável ANO_LOA
"""

import re
from pathlib import Path

def load_env_vars():
    """Carrega variáveis do arquivo .env e config.mk"""
    env_vars = {}
    
    # Carrega do .env
    env_file = Path('.env')
    if env_file.exists():
        with open(env_file, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    env_vars[key.strip()] = value.strip()
    
    # Carrega do config.mk (sobrescreve valores do .env se existirem)
    config_file = Path('config.mk')
    if config_file.exists():
        with open(config_file, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    # Remove comentários inline
                    if '#' in value:
                        value = value.split('#')[0].strip()
                    env_vars[key.strip()] = value.strip()
    
    return env_vars

def calculate_expected_year(ano_loa, comment):
    """Calcula o ano esperado baseado no comentário"""
    if 'ANO_LOA-1' in comment:
        return ano_loa - 1
    elif 'ANO_LOA+1' in comment:
        return ano_loa + 1
    elif 'ANO_LOA+2' in comment:
        return ano_loa + 2
    elif 'ANO_LOA' in comment and 'ANO_LOA+' not in comment and 'ANO_LOA-' not in comment:
        return ano_loa
    return None

def process_datapackage():
    """Valida e corrige anos no datapackage.yaml baseado no ANO_LOA"""
    env_vars = load_env_vars()
    
    # Carrega ANO_LOA do ambiente ou usa padrão
    ano_loa = env_vars.get('ANO_LOA', '2025')
    
    # Valida se ANO_LOA é um ano válido
    if not ano_loa.isdigit() or len(ano_loa) != 4:
        print(f"❌ Erro: ANO_LOA deve ser um ano válido de 4 dígitos. Valor atual: {ano_loa}")
        return False
    
    ano_loa_int = int(ano_loa)
    
    # Carrega o datapackage.yaml
    datapackage_file = Path('datapackage.yaml')
    if not datapackage_file.exists():
        print("❌ Erro: datapackage.yaml não encontrado")
        return False
    
    with open(datapackage_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    changes_made = False
    lines_processed = 0
    
    # Processa cada linha
    for i, line in enumerate(lines):
        # Procura por linhas que contêm anos e comentários ANO_LOA
        if '# ANO_LOA' in line:
            # Extrai o ano atual da linha (procura por padrão de 4 dígitos)
            year_match = re.search(r'(\d{4})', line)
            if year_match:
                current_year = int(year_match.group(1))
                
                # Calcula o ano esperado baseado no comentário
                expected_year = calculate_expected_year(ano_loa_int, line)
                
                if expected_year is not None:
                    lines_processed += 1
                    
                    if current_year != expected_year:
                        # Substitui o ano na linha
                        new_line = re.sub(r'\d{4}', str(expected_year), line)
                        lines[i] = new_line
                        changes_made = True
    
    # Salva o arquivo se houve mudanças
    if changes_made:
        with open(datapackage_file, 'w', encoding='utf-8') as f:
            f.writelines(lines)
        print(f"✅ Datapackage atualizado com sucesso! (ANO_LOA={ano_loa})")
    else:
        print(f"✅ Datapackage validado com sucesso! (ANO_LOA={ano_loa})")
    
    return True

def main():
    """Função principal para execução via Poetry"""
    success = process_datapackage()
    exit(0 if success else 1)

if __name__ == '__main__':
    main()
