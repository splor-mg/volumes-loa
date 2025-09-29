#!/usr/bin/env python3
"""
Script para atualizar utils/etapa_orcamento.txt com o valor de ETAPA_ORCAMENTO do config.mk
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

def update_etapa_orcamento_txt(config_path="config.mk", etapa_txt_path="utils/etapa_orcamento.txt"):
    """Atualiza utils/etapa_orcamento.txt com o valor de ETAPA_ORCAMENTO do config.mk"""
    try:
        # Lê ETAPA_ORCAMENTO do config.mk (seção "Parâmetros informados pelo usuário")
        etapa_orcamento = None
        with open(config_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line.startswith('ETAPA_ORCAMENTO='):
                    etapa_orcamento = line.split('=', 1)[1].strip()
                    # Remove aspas se existirem
                    if etapa_orcamento.startswith('"') and etapa_orcamento.endswith('"'):
                        etapa_orcamento = etapa_orcamento[1:-1]
                    elif etapa_orcamento.startswith("'") and etapa_orcamento.endswith("'"):
                        etapa_orcamento = etapa_orcamento[1:-1]
                    if '#' in etapa_orcamento:
                        etapa_orcamento = etapa_orcamento.split('#')[0].strip()
                    break
        
        if not etapa_orcamento:
            print(f"{Colors.YELLOW}Aviso: ETAPA_ORCAMENTO não encontrado em {config_path}{Colors.END}")
            return False
        
        # Escreve no utils/etapa_orcamento.txt
        with open(etapa_txt_path, 'w') as f:
            f.write(f"{etapa_orcamento}\n")
        
        print(f"{Colors.GREEN}✓ Atualizado `{etapa_txt_path}` com ETAPA_ORCAMENTO={etapa_orcamento}{Colors.END}")
        return True
        
    except Exception as e:
        print(f"{Colors.RED}Erro ao atualizar {etapa_txt_path}: {e}{Colors.END}")
        return False

def main():
    """Função principal"""
    try:
        success = update_etapa_orcamento_txt()
        if not success:
            sys.exit(1)
    except Exception as e:
        print(f"{Colors.RED}❌ Erro: {e}{Colors.END}")
        sys.exit(1)

if __name__ == "__main__":
    main()
