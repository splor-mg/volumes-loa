#!/usr/bin/env python3
"""
Script para detectar plataforma e gerar configuração de fonte LaTeX
"""

import platform
import sys
import os

def detect_font_config():
    """Detecta a plataforma e retorna a configuração de fonte apropriada"""
    system = platform.system()
    
    if system == "Windows":
        return r"\usepackage{uarial}"
    else:
        # Linux, macOS, WSL, etc.
        return r"\usepackage{helvet}" + "\n" + r"\renewcommand{\familydefault}{\sfdefault}"

def main():
    """Função principal"""
    try:
        config = detect_font_config()
        
        # Se chamado com --export, exporta a variável
        if "--export" in sys.argv:
            print(f"export FONT_CONFIG='{config}'")
        else:
            # Se chamado sem argumentos, apenas retorna a configuração
            print(config)
            
    except Exception as e:
        print(f"Erro ao detectar plataforma: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
