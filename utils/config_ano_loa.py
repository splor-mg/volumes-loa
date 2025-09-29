#!/usr/bin/env python3
"""
Script para atualizar utils/ano.txt com o valor de ANO_LOA do config.mk
"""

import sys
from pathlib import Path

# Cores para output
class Colors:
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    END = '\033[0m'

def update_ano_txt(config_path="config.mk", ano_txt_path="utils/ano.txt"):
    """Atualiza utils/ano.txt com o valor de ANO_LOA do config.mk"""
    try:
        # Lê ANO_LOA do config.mk (seção "Parâmetros informados pelo usuário")
        ano_loa = None
        with open(config_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line.startswith('ANO_LOA='):
                    ano_loa = line.split('=', 1)[1].strip()
                    if '#' in ano_loa:
                        ano_loa = ano_loa.split('#')[0].strip()
                    break
        
        if not ano_loa:
            print(f"{Colors.YELLOW}Aviso: ANO_LOA não encontrado em {config_path}{Colors.END}")
            return False
        
        # Escreve no utils/ano.txt
        with open(ano_txt_path, 'w') as f:
            f.write(f"{ano_loa}\n")
        
        print(f"{Colors.GREEN}✓ Atualizado `{ano_txt_path}` com ANO_LOA={ano_loa}{Colors.END}")
        return True
        
    except Exception as e:
        print(f"{Colors.RED}Erro ao atualizar {ano_txt_path}: {e}{Colors.END}")
        return False

def main():
    """Função principal"""
    try:
        success = update_ano_txt()
        if not success:
            sys.exit(1)
    except Exception as e:
        print(f"{Colors.RED}❌ Erro: {e}{Colors.END}")
        sys.exit(1)

if __name__ == "__main__":
    main()
