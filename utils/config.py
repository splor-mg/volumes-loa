#!/usr/bin/env python3
"""
Script para extrair informações de versões da imagem Docker
"""

import subprocess
import sys
import json
from pathlib import Path

# Cores para output
class Colors:
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    END = '\033[0m'

def print_header():
    print(f"{Colors.BLUE}{Colors.BOLD}")
    print("Extraindo informações da imagem Docker...")
    print("=" * 50)
    print(f"{Colors.END}")

def get_docker_image_info(docker_user, docker_image, docker_tag):
    """Extrai informações da imagem Docker usando labels"""
    image_name = f"{docker_user}/{docker_image}:{docker_tag}"
    
    try:
        # Comando para extrair labels da imagem
        cmd = [
            'docker', 'inspect', image_name,
            '--format={{json .Config.Labels}}'
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        labels = json.loads(result.stdout)
        
        return labels
        
    except subprocess.CalledProcessError as e:
        print(f"{Colors.RED}Erro ao extrair informações da imagem {image_name}:{Colors.END}")
        print(f"{Colors.RED}{e.stderr}{Colors.END}")
        return None
    except json.JSONDecodeError as e:
        print(f"{Colors.RED}Erro ao decodificar JSON: {e}{Colors.END}")
        return None

def extract_versions(labels):
    """Extrai versões dos labels da imagem"""
    versions = {}
    
    # Mapeamento dos labels para variáveis
    label_mapping = {
        'relatorios.version': 'RELATORIOS_VERSION',
        'execucao.version': 'EXECUCAO_VERSION', 
        'reest.version': 'REEST_VERSION',
        'ano.loa': 'ANO_LOA'
    }
    
    for label_key, var_name in label_mapping.items():
        if label_key in labels and labels[label_key]:
            versions[var_name] = labels[label_key]
        else:
            versions[var_name] = 'unknown'
            print(f"{Colors.YELLOW}Aviso: Label '{label_key}' não encontrado{Colors.END}")
    
    return versions

def update_config_mk(versions, config_path="config.mk"):
    """Atualiza as versões extraídas da imagem Docker na segunda linha do config.mk"""
    
    # Lê o arquivo atual
    if not Path(config_path).exists():
        print(f"{Colors.RED}Arquivo {config_path} não encontrado!{Colors.END}")
        return False
    
    with open(config_path, 'r') as f:
        lines = f.readlines()
    
    if len(lines) < 2:
        print(f"{Colors.RED}Arquivo {config_path} muito pequeno!{Colors.END}")
        return False
    
    # Constrói as novas linhas com as versões
    versions_lines = [
        f"# Versões extraídas da imagem Docker - {versions.get('ANO_LOA', 'unknown')}\n",
        f"RELATORIOS_VERSION={versions.get('RELATORIOS_VERSION', 'unknown')}\n",
        f"EXECUCAO_VERSION={versions.get('EXECUCAO_VERSION', 'unknown')}\n",
        f"REEST_VERSION={versions.get('REEST_VERSION', 'unknown')}\n",
        "\n"
    ]
    
    # Insere as versões na segunda linha (índice 1)
    # Remove a primeira linha existente se for um comentário de versões antigo
    if lines[1].startswith("# Versões extraídas da imagem Docker"):
        # Remove linhas antigas de versões até encontrar uma linha vazia ou próxima seção
        i = 1
        while i < len(lines) and (lines[i].startswith("# Versões extraídas") or 
                                 lines[i].startswith("RELATORIOS_VERSION") or 
                                 lines[i].startswith("EXECUCAO_VERSION") or 
                                 lines[i].startswith("REEST_VERSION") or 
                                 lines[i].strip() == ""):
            lines.pop(i)
            if i >= len(lines):
                break
    else:
        # Insere após a primeira linha
        i = 1
    
    # Insere as novas linhas
    for j, version_line in enumerate(versions_lines):
        lines.insert(i + j, version_line)
    
    # Salva o arquivo
    with open(config_path, 'w') as f:
        f.writelines(lines)
    
    return True

def show_versions(versions):
    """Mostra as versões extraídas"""
    print(f"\n{Colors.GREEN}{Colors.BOLD}Versões extraídas da imagem Docker:{Colors.END}")
    print("-" * 50)
    for key, value in versions.items():
        status = f"{Colors.GREEN}✓{Colors.END}" if value != 'unknown' else f"{Colors.RED}✗{Colors.END}"
        print(f"{status} {key:20} = {value}")
    print("-" * 50)

def main():
    print_header()
    
    # Lê configurações do config.mk atual
    config_path = Path("config.mk")
    if not config_path.exists():
        print(f"{Colors.RED}Arquivo config.mk não encontrado!{Colors.END}")
        sys.exit(1)
    
    # Lê valores atuais do config.mk
    current_values = {}
    with open(config_path, 'r') as f:
        for line in f:
            line = line.strip()
            if '=' in line and not line.startswith('#'):
                key, value = line.split('=', 1)
                key = key.strip()
                value = value.strip()
                if '#' in value:
                    value = value.split('#')[0].strip()
                current_values[key] = value
    
    # Usa valores atuais ou padrões
    docker_user = current_values.get('DOCKER_USER', 'aidsplormg')
    docker_image = current_values.get('DOCKER_IMAGE', 'volumes')
    docker_tag = current_values.get('DOCKER_TAG', 'ploa2025')
    
    print(f"Extraindo informações de: {docker_user}/{docker_image}:{docker_tag}")
    
    # Extrai informações da imagem
    labels = get_docker_image_info(docker_user, docker_image, docker_tag)
    if not labels:
        print(f"{Colors.RED}Falha ao extrair informações da imagem.{Colors.END}")
        sys.exit(1)
    
    # Extrai versões
    versions = extract_versions(labels)
    
    # Mostra versões
    show_versions(versions)
    
    # Atualiza config.mk
    if update_config_mk(versions):
        print(f"\n{Colors.GREEN}{Colors.BOLD}Configurações atualizadas em config.mk!{Colors.END}")
    else:
        print(f"\n{Colors.RED}Falha ao atualizar config.mk!{Colors.END}")
        sys.exit(1)

if __name__ == "__main__":
    main()
