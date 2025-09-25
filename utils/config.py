#!/usr/bin/env python3
"""
Script para extrair informações de versões da imagem Docker
"""

import os
import shutil
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
        # Verifica disponibilidade do docker no ambiente
        if shutil.which('docker') is None:
            raise FileNotFoundError("docker CLI não encontrado no PATH")
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
    except FileNotFoundError as e:
        print(f"{Colors.YELLOW}Docker indisponível ou execução dentro do container (docker CLI não encontrado no PATH). Detalhe: {e}{Colors.END}")
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

def get_versions_from_env():
    """Lê versões do ambiente, retorna dicionário apenas com chaves presentes."""
    env_keys = ['RELATORIOS_VERSION', 'EXECUCAO_VERSION', 'REEST_VERSION', 'ANO_LOA']
    env_values = {}
    for key in env_keys:
        val = os.environ.get(key)
        if val is not None and str(val).strip() != "":
            env_values[key] = str(val).strip()
    return env_values

def update_config_mk(versions, config_path="config.mk"):
    """Atualiza ANO_LOA e versões na seção 'CONFIGURAÇÕES FLUIDAS' do config.mk."""
    
    if not Path(config_path).exists():
        print(f"{Colors.RED}Arquivo {config_path} não encontrado!{Colors.END}")
        return False
    
    with open(config_path, 'r') as f:
        lines = f.readlines()
    
    # Identificar limites da seção CONFIGURAÇÕES FLUIDAS
    start_idx = None
    end_idx = len(lines)
    for idx, line in enumerate(lines):
        if line.strip().startswith('# ====================================================================') and idx + 1 < len(lines):
            next_line = lines[idx + 1].strip()
            if next_line.startswith('# CONFIGURAÇÕES FLUIDAS'):
                start_idx = idx
                continue
        if start_idx is not None and line.strip().startswith('# CONFIGURAÇÕES ESTRUTURAIS'):
            end_idx = idx
            break

    if start_idx is None:
        print(f"{Colors.RED}Seção 'CONFIGURAÇÕES FLUIDAS' não encontrada em {config_path}!{Colors.END}")
        return False
    
    # Mapear posições existentes das chaves dentro do intervalo
    keys = ['ANO_LOA', 'RELATORIOS_VERSION', 'EXECUCAO_VERSION', 'REEST_VERSION']
    key_to_idx = {k: None for k in keys}
    for idx in range(start_idx, end_idx):
        line = lines[idx]
        for k in keys:
            if line.startswith(f"{k}="):
                key_to_idx[k] = idx

    # Atualizar ou inserir valores
    def ensure_kv(key, value, anchor_comment):
        line_value = f"{key}={value}\n"
        if key_to_idx[key] is not None:
            lines[key_to_idx[key]] = line_value
        else:
            # Inserir após o comentário de versões extraídas ou após o cabeçalho da seção
            insert_pos = start_idx + 1
            # procurar bloco "# Versões extraídas da imagem Docker"
            for idx in range(start_idx, end_idx):
                if lines[idx].strip().startswith(anchor_comment):
                    insert_pos = idx + 1
                    break
            lines.insert(insert_pos, line_value)
            # Ajustar índices seguintes
            for k2 in keys:
                if key_to_idx[k2] is not None and key_to_idx[k2] >= insert_pos:
                    key_to_idx[k2] += 1

    # Garantir presença do cabeçalho de versões
    header_present = False
    header_line = '# Versões extraídas da imagem Docker\n'
    for idx in range(start_idx, end_idx):
        if lines[idx].strip().startswith('# Versões extraídas da imagem Docker'):
            header_present = True
            break
    if not header_present:
        # Inserir header logo após a sub-seção de parâmetros (se existir) ou após o título da seção
        insert_pos = start_idx + 1
        for idx in range(start_idx, min(end_idx, start_idx + 15)):
            if lines[idx].strip().startswith('# Versões extraídas'):
                header_present = True
                break
            if lines[idx].strip().startswith('# Parâmetros da imagem Docker'):
                insert_pos = idx + 1
        lines.insert(insert_pos, header_line)
        # Ajustar end_idx
        end_idx += 1

    # Atualizar os quatro valores
    ensure_kv('ANO_LOA', versions.get('ANO_LOA', 'unknown'), '# Versões extraídas')
    ensure_kv('RELATORIOS_VERSION', versions.get('RELATORIOS_VERSION', 'unknown'), '# Versões extraídas')
    ensure_kv('EXECUCAO_VERSION', versions.get('EXECUCAO_VERSION', 'unknown'), '# Versões extraídas')
    ensure_kv('REEST_VERSION', versions.get('REEST_VERSION', 'unknown'), '# Versões extraídas')

    with open(config_path, 'w') as f:
        f.writelines(lines)
    
    return True

def show_versions(versions, source="desconhecida"):
    """Mostra as versões extraídas"""
    print(f"\n{Colors.GREEN}{Colors.BOLD}Versões de referência ({source}):{Colors.END}")
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
    
    # Fonte 1: Docker (preferencial)
    versions = None
    source = "docker inspect"
    labels = get_docker_image_info(docker_user, docker_image, docker_tag)
    if labels:
        versions = extract_versions(labels)
    else:
        # Fonte 2: Ambiente
        env_vals = get_versions_from_env()
        if env_vals:
            # Completa com valores atuais, sobrescrevendo pelas variáveis de ambiente presentes
            versions = {
                'ANO_LOA': env_vals.get('ANO_LOA', current_values.get('ANO_LOA', 'unknown')),
                'RELATORIOS_VERSION': env_vals.get('RELATORIOS_VERSION', current_values.get('RELATORIOS_VERSION', 'unknown')),
                'EXECUCAO_VERSION': env_vals.get('EXECUCAO_VERSION', current_values.get('EXECUCAO_VERSION', 'unknown')),
                'REEST_VERSION': env_vals.get('REEST_VERSION', current_values.get('REEST_VERSION', 'unknown')),
            }
            source = "variáveis de ambiente"
        else:
            # Fonte 3: config.mk (atual)
            versions = {
                'ANO_LOA': current_values.get('ANO_LOA', 'unknown'),
                'RELATORIOS_VERSION': current_values.get('RELATORIOS_VERSION', 'unknown'),
                'EXECUCAO_VERSION': current_values.get('EXECUCAO_VERSION', 'unknown'),
                'REEST_VERSION': current_values.get('REEST_VERSION', 'unknown'),
            }
            source = "config.mk (valores atuais)"

    # Mostra versões e fonte
    show_versions(versions, source)
    
    # Atualiza config.mk
    if update_config_mk(versions):
        print(f"\n{Colors.GREEN}{Colors.BOLD}Configurações atualizadas em config.mk!{Colors.END}")
    else:
        print(f"\n{Colors.RED}Falha ao atualizar config.mk!{Colors.END}")
        sys.exit(1)

if __name__ == "__main__":
    main()
