#!/usr/bin/env python3
"""
Script para verificar consistência entre ANO_LOA e ANO_LOA_IMAGEM
"""

import os
import sys
from pathlib import Path

# Cores para output
class Colors:
    YELLOW = '\033[93m'
    CYAN = '\033[96m'
    BOLD = '\033[1m'
    END = '\033[0m'

def read_config_values():
    """Lê valores do config.mk"""
    config_path = Path("config.mk")
    if not config_path.exists():
        return None, None
    
    values = {}
    with open(config_path, 'r') as f:
        for line in f:
            line = line.strip()
            if '=' in line and not line.startswith('#'):
                key, value = line.split('=', 1)
                key = key.strip()
                value = value.strip()
                if '#' in value:
                    value = value.split('#')[0].strip()
                values[key] = value
    
    return values.get('ANO_LOA'), values.get('ANO_LOA_IMAGEM')

def main():
    ano_loa, ano_loa_imagem = read_config_values()
    
    if ano_loa is None or ano_loa_imagem is None:
        # Se não conseguir ler os valores, não exibe nada
        return
    
    if ano_loa != ano_loa_imagem:
        print(f"\n{Colors.YELLOW}{Colors.BOLD}⚠️  ALERTA: Inconsistência detectada!{Colors.END}")
        print(f"{Colors.YELLOW}O parâmetro ANO_LOA [{ano_loa}] está diferente do parâmetro ANO_LOA_IMAGEM [{ano_loa_imagem}]{Colors.END}")
        print(f"\nOpções para corrigir:")
        print(f"1. {Colors.CYAN}make config{Colors.END} - para ajustar a variável ANO_LOA")
        print(f"2. Ir no repositório {Colors.CYAN}volumes-docker{Colors.END} - para ajustar ANO_LOA_IMAGEM")
        print(f"\nApenas um alerta. O processo continuará normalmente...")
    else:
        # Quando não há inconsistência, exibe mensagem discreta
        print(f"ANO_LOA = {ano_loa}")

if __name__ == "__main__":
    main()
