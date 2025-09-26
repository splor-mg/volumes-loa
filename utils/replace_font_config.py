#!/usr/bin/env python3
"""
Script para substituir FONT_CONFIG_PLACEHOLDER pela configuração de fonte apropriada
"""

import os
import sys
import glob
import subprocess

def get_font_config():
    """Obtém a configuração de fonte do script de detecção"""
    try:
        result = subprocess.run(['python3', 'utils/detect_plattform.py'], 
                              capture_output=True, text=True, cwd=os.getcwd())
        if result.returncode == 0:
            return result.stdout.strip()
        else:
            print(f"Erro ao obter configuração de fonte: {result.stderr}", file=sys.stderr)
            return None
    except Exception as e:
        print(f"Erro ao executar detect_plattform.py: {e}", file=sys.stderr)
        return None

def replace_font_config_in_file(file_path, font_config):
    """Substitui FONT_CONFIG_PLACEHOLDER pela configuração de fonte no arquivo"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if 'FONT_CONFIG_PLACEHOLDER' in content:
            new_content = content.replace('FONT_CONFIG_PLACEHOLDER', font_config)
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            print(f"✅ Atualizado: {file_path}")
            return True
        else:
            print(f"⏭️  Sem placeholder: {file_path}")
            return False
            
    except Exception as e:
        print(f"❌ Erro ao processar {file_path}: {e}", file=sys.stderr)
        return False

def main():
    """Função principal"""
    print("🔍 Procurando arquivos .tex com FONT_CONFIG_PLACEHOLDER...")
    
    # Obter configuração de fonte
    font_config = get_font_config()
    if not font_config:
        print("❌ Não foi possível obter configuração de fonte", file=sys.stderr)
        sys.exit(1)
    
    print(f"📝 Configuração de fonte: {font_config}")
    
    # Procurar arquivos .tex
    tex_files = []
    for pattern in ['**/*.tex', '**/*.Rnw']:
        tex_files.extend(glob.glob(pattern, recursive=True))
    
    if not tex_files:
        print("⚠️  Nenhum arquivo .tex encontrado")
        return
    
    # Processar arquivos
    updated_count = 0
    for file_path in tex_files:
        if replace_font_config_in_file(file_path, font_config):
            updated_count += 1
    
    print(f"\n🎉 Processamento concluído! {updated_count} arquivo(s) atualizado(s)")

if __name__ == "__main__":
    main()
