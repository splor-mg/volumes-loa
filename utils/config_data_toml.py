#!/usr/bin/env python3
"""
Script para processar data.toml e substituir variáveis baseadas no config.mk
"""

import re
from pathlib import Path
import tomli

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

def load_ano_loa():
    """Carrega apenas o ANO_LOA do config.mk"""
    env_vars = load_env_vars()
    ano_loa = env_vars.get('ANO_LOA', '2026')
    
    # Valida se ANO_LOA é um ano válido
    if not ano_loa.isdigit() or len(ano_loa) != 4:
        print(f"❌ Erro: ANO_LOA deve ser um ano válido de 4 dígitos. Valor atual: {ano_loa}")
        return None
    
    return ano_loa

def validate_toml_structure(file_path):
    """Valida se o arquivo TOML tem estrutura válida"""
    try:
        with open(file_path, 'rb') as f:
            tomli.load(f)
        return True, None
    except tomli.TOMLDecodeError as e:
        return False, str(e)
    except Exception as e:
        return False, f"Erro inesperado: {e}"

def process_data_toml():
    """Processa data.toml e substitui anos baseados no ANO_LOA"""
    ano_loa = load_ano_loa()
    if not ano_loa:
        return False
    
    # Carrega o data.toml
    data_toml_file = Path('data.toml')
    if not data_toml_file.exists():
        print("❌ Erro: data.toml não encontrado")
        return False
    
    with open(data_toml_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    original_lines = lines.copy()
    changes_made = False
    
    # Atualiza linha 5: dados-sisor-{ANO_LOA}
    if len(lines) >= 5:
        line_5 = lines[4]  # Índice 4 = linha 5
        if 'dados-sisor-' in line_5 and 'datapackage.yaml' in line_5:
            # Extrai o ano atual da linha
            year_match = re.search(r'dados-sisor-(\d{4})', line_5)
            if year_match:
                current_year = year_match.group(1)
                if current_year != ano_loa:
                    # Substitui o ano na linha
                    new_line = re.sub(r'dados-sisor-\d{4}', f'dados-sisor-{ano_loa}', line_5)
                    lines[4] = new_line
                    changes_made = True
                    print(f"📝 Linha 5: dados-sisor-{current_year} → dados-sisor-{ano_loa}")
    
    # Atualiza linha 9: dados-sigplan-planejamento-{ANO_LOA}
    if len(lines) >= 9:
        line_9 = lines[8]  # Índice 8 = linha 9
        if 'dados-sigplan-planejamento-' in line_9 and 'datapackage.yaml' in line_9:
            # Extrai o ano atual da linha
            year_match = re.search(r'dados-sigplan-planejamento-(\d{4})', line_9)
            if year_match:
                current_year = year_match.group(1)
                if current_year != ano_loa:
                    # Substitui o ano na linha
                    new_line = re.sub(r'dados-sigplan-planejamento-\d{4}', f'dados-sigplan-planejamento-{ano_loa}', line_9)
                    lines[8] = new_line
                    changes_made = True
                    print(f"📝 Linha 9: dados-sigplan-planejamento-{current_year} → dados-sigplan-planejamento-{ano_loa}")
    
    # Verifica se houve mudanças
    if changes_made:
        # Salva o arquivo atualizado
        with open(data_toml_file, 'w', encoding='utf-8') as f:
            f.writelines(lines)
        
        # Valida a estrutura TOML após a atualização
        print("🔍 Validando estrutura TOML...")
        is_valid, error_msg = validate_toml_structure(data_toml_file)
        
        if not is_valid:
            print(f"❌ ERRO: Arquivo TOML inválido após atualização!")
            print(f"❌ Detalhes do erro: {error_msg}")
            print(f"❌ Atualização abortada - estrutura TOML inválida")
            return False
        
        print(f"✅ Estrutura TOML válida")
        print(f"✅ data.toml atualizado com sucesso! (ANO_LOA={ano_loa})")
        return True
    else:
        print(f"✅ data.toml já está atualizado (ANO_LOA={ano_loa})")
        return True

def main():
    """Função principal"""
    try:
        success = process_data_toml()
        if not success:
            exit(1)
    except Exception as e:
        print(f"❌ Erro: {e}")
        exit(1)

if __name__ == "__main__":
    main()
