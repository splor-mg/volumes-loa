#!/usr/bin/env python3
"""
Script para converter lógica condicional LaTeX (\ifwindows) para FONT_CONFIG_PLACEHOLDER
"""

import os
import sys
import glob
import re

def convert_font_conditionals_in_file(file_path):
    """Converte lógica condicional de fontes em um arquivo"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Padrão para encontrar blocos \ifwindows...\fi
        pattern = r'\\usepackage\{ifplatform\}\s*\\ifwindows\s*\\usepackage\{uarial\}\s*\\else\s*\\usepackage\{helvet\}\s*\\renewcommand\{\\familydefault\}\{\\sfdefault\}\s*\\fi'
        
        # Substitui por placeholder
        new_content = re.sub(pattern, 'FONT_CONFIG_PLACEHOLDER', content, flags=re.MULTILINE | re.DOTALL)
        
        # Se houve mudança, salva o arquivo
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
    """Função principal"""
    print("🔄 Convertendo lógica condicional LaTeX para FONT_CONFIG_PLACEHOLDER...")
    
    # Padrões de arquivos para processar
    patterns = [
        '**/*.tex',
        '**/*.Rnw'
    ]
    
    # Lista de arquivos para processar
    files_to_process = []
    for pattern in patterns:
        files_to_process.extend(glob.glob(pattern, recursive=True))
    
    if not files_to_process:
        print("⚠️  Nenhum arquivo encontrado")
        return
    
    # Processar arquivos
    converted_count = 0
    for file_path in files_to_process:
        if convert_font_conditionals_in_file(file_path):
            converted_count += 1
    
    print(f"\n🎉 Conversão concluída! {converted_count} arquivo(s) convertido(s)")

if __name__ == "__main__":
    main()
