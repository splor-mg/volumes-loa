#!/usr/bin/env python3
"""
Script interativo para configurar as variáveis Docker no config.mk
"""

import os
import re
import sys
import subprocess
from pathlib import Path
from datetime import datetime

# Cores para output
class Colors:
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    CYAN = '\033[96m'
    BOLD = '\033[1m'
    END = '\033[0m'

def print_header():
    print(f"{Colors.BLUE}{Colors.BOLD}")
    print("🔧 CONFIGURAÇÃO DE VARIÁVEIS DOCKER")
    print("=" * 50)
    print(f"{Colors.END}")

import hashlib

def get_file_hash(file_path):
    """Calcula hash MD5 de um arquivo"""
    try:
        with open(file_path, 'rb') as f:
            return hashlib.md5(f.read()).hexdigest()
    except FileNotFoundError:
        return None

def create_backup():
    """Cria backup do config.mk e retorna o caminho do backup"""
    config_path = Path("config.mk")
    backup_path = Path("config.mk.backup")
    
    if not config_path.exists():
        return None
    
    # Lê o arquivo original
    with open(config_path, 'r') as f:
        content = f.read()
    
    # Salva backup
    backup_path.write_text(content)
    return backup_path

def prepare_config_mk():
    """Prepara o config.mk comentando linhas que usam R"""
    config_path = Path("config.mk")
    
    if not config_path.exists():
        return True
    
    # Lê o arquivo atual
    with open(config_path, 'r') as f:
        content = f.read()
    
    # Comenta as linhas problemáticas usando sed
    import subprocess
    
    try:
        # Comenta linhas DEP_ e DEPENDENCIAS_
        subprocess.run(['sed', '-i', 's/^DEP_/#DEP_/g', str(config_path)], check=True)
        subprocess.run(['sed', '-i', 's/^DEPENDENCIAS_/#DEPENDENCIAS_/g', str(config_path)], check=True)
        # Comenta linha acoes_planejamento
        subprocess.run(['sed', '-i', 's/^acoes_planejamento/#acoes_planejamento/g', str(config_path)], check=True)
        return True
    except subprocess.CalledProcessError:
        return False

def restore_config_mk_lines():
    """Restaura as linhas R comentadas (descomenta)"""
    config_path = Path("config.mk")
    
    if not config_path.exists():
        return True
    
    import subprocess
    
    try:
        # Descomenta linhas DEP_ e DEPENDENCIAS_
        subprocess.run(['sed', '-i', 's/^#DEP_/DEP_/g', str(config_path)], check=True)
        subprocess.run(['sed', '-i', 's/^#DEPENDENCIAS_/DEPENDENCIAS_/g', str(config_path)], check=True)
        # Descomenta linha acoes_planejamento
        subprocess.run(['sed', '-i', 's/^#acoes_planejamento/acoes_planejamento/g', str(config_path)], check=True)
        return True
    except subprocess.CalledProcessError:
        return False

def validate_config_integrity(backup_path, original_hash):
    """Valida se apenas as configurações fluidas foram alteradas usando git diff config.mk"""
    try:
        # Executa git diff config.mk
        result = subprocess.run(
            ['git', 'diff', 'config.mk'],
            capture_output=True,
            text=True
        )
        
        # git diff retorna 1 quando há diferenças (normal), 0 quando são iguais
        if result.returncode not in [0, 1]:
            print(f"{Colors.RED}❌ Erro no git diff: {result.stderr}{Colors.END}")
            return False
        
        diff_output = result.stdout
        
        # Padrões esperados de mudança (usando regex com .* para qualquer texto)
        expected_patterns = [
            r'^-DOCKER_TAG=.*',
            r'^\+DOCKER_TAG=.*',
            r'^-DOCKER_USER=.*',
            r'^\+DOCKER_USER=.*',
            r'^-DOCKER_IMAGE=.*',
            r'^\+DOCKER_IMAGE=.*'
        ]
        
        # Compila os padrões regex
        compiled_patterns = [re.compile(pattern) for pattern in expected_patterns]
        
        # Verifica se todas as mudanças são esperadas
        lines = diff_output.split('\n')
        unexpected_changes = []
        
        for line in lines:
            # Pula linhas de contexto do diff e linhas vazias
            if (line.startswith('+++') or line.startswith('---') or 
                line.startswith('@@') or line.startswith('\\') or
                line.strip() == ''):
                continue
            
            # Verifica apenas linhas que começam com + ou -
            if line.startswith('+') or line.startswith('-'):
                # Verifica se a linha corresponde a algum padrão esperado
                is_expected = False
                for pattern in compiled_patterns:
                    if pattern.match(line):
                        is_expected = True
                        break
                
                if not is_expected:
                    unexpected_changes.append(line)
        
        # Se há mudanças inesperadas, falha na validação
        if unexpected_changes:
            print(f"{Colors.RED}❌ Mudanças inesperadas detectadas:{Colors.END}")
            for change in unexpected_changes:
                print(f"  {Colors.YELLOW}{change}{Colors.END}")
            return False
        
        return True
        
    except Exception as e:
        print(f"{Colors.RED}❌ Erro na validação: {e}{Colors.END}")
        return False

def cleanup_backup(backup_path):
    """Remove o arquivo de backup"""
    if backup_path and backup_path.exists():
        backup_path.unlink()
        return True
    return False

def restore_from_backup(backup_path):
    """Restaura o config.mk a partir do backup"""
    if not backup_path or not backup_path.exists():
        return False
    
    config_path = Path("config.mk")
    with open(backup_path, 'r') as f:
        content = f.read()
    
    config_path.write_text(content)
    return True

def safe_config_update():
    """Implementa o protocolo de conferência completo"""
    # 1. Backup (ANTES de comentar as linhas R)
    backup_path = create_backup()
    if not backup_path:
        print(f"{Colors.RED}❌ Erro: config.mk não encontrado{Colors.END}")
        return False, None, None
    
    original_hash = get_file_hash("config.mk")
    
    try:
        # 2. Preparação (comenta linhas R)
        if not prepare_config_mk():
            print(f"{Colors.RED}❌ Erro ao preparar config.mk{Colors.END}")
            return False, None, None
        
        # 3. Coleta de dados (será feita na função main)
        # Esta função apenas prepara o ambiente
        
        return True, backup_path, original_hash
        
    except Exception as e:
        print(f"{Colors.RED}❌ Erro durante preparação: {e}{Colors.END}")
        restore_from_backup(backup_path)
        return False, None, None

def finalize_config_update(new_values, backup_path, original_hash):
    """Finaliza o protocolo de conferência após coleta dos dados"""
    try:
        # 4. Persistência
        if not update_config_mk(new_values):
            print(f"{Colors.RED}❌ Erro ao salvar configurações{Colors.END}")
            return False
        
        # 5. Restauração das linhas R
        if not restore_config_mk_lines():
            print(f"{Colors.RED}❌ Erro ao restaurar linhas R{Colors.END}")
            return False
        
        # 6. Validação
        if validate_config_integrity(backup_path, original_hash):
            # 7a. Sucesso - remove backup
            cleanup_backup(backup_path)
            return True
        else:
            # 7b. Falha - restaura backup
            print(f"{Colors.RED}❌ Validação falhou - restaurando backup{Colors.END}")
            restore_from_backup(backup_path)
            cleanup_backup(backup_path)
            return False
            
    except Exception as e:
        # 7c. Erro - restaura backup
        print(f"{Colors.RED}❌ Erro durante finalização: {e}{Colors.END}")
        restore_from_backup(backup_path)
        cleanup_backup(backup_path)
        return False

def read_config_file():
    """Lê o arquivo config.mk atual e extrai os valores"""
    config_path = Path("config.mk")
    values = {}
    
    if config_path.exists():
        with open(config_path, 'r') as f:
            for line in f:
                line = line.strip()
                if '=' in line and not line.startswith('#'):
                    key, value = line.split('=', 1)
                    key = key.strip()
                    value = value.strip()
                    # Remove comentários inline
                    if '#' in value:
                        value = value.split('#')[0].strip()
                    values[key] = value
    
    return values

def validate_docker_tag(tag):
    """Valida se a tag do Docker é válida"""
    # Tag deve conter apenas letras, números, pontos, hífens e underscores
    return re.match(r'^[a-zA-Z0-9._-]+$', tag) is not None

def get_git_info():
    """Obtém informações do Git (commit hash, branch, etc.)"""
    try:
        commit_hash = subprocess.check_output(
            ['git', 'rev-parse', '--short', 'HEAD'],
            stderr=subprocess.DEVNULL
        ).decode().strip()
        
        branch = subprocess.check_output(
            ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
            stderr=subprocess.DEVNULL
        ).decode().strip()
        
        return {
            'commit': commit_hash,
            'branch': branch if branch != 'HEAD' else 'detached',
            'is_git_repo': True
        }
    except (subprocess.CalledProcessError, FileNotFoundError):
        return {
            'commit': None,
            'branch': None,
            'is_git_repo': False
        }


def get_last_update_info():
    """Gera informação de última atualização com commit hash"""
    current_date = datetime.now().strftime("%Y-%m-%d")
    git_info = get_git_info()
    
    if git_info['is_git_repo'] and git_info['commit']:
        return f"{current_date} (commit: {git_info['commit']})"
    else:
        return current_date

def get_user_input(prompt, current_value, validator=None):
    """Pede input do usuário com valor padrão e validação"""
    while True:
        if current_value:
            user_input = input(f"{prompt}: [{current_value}] ").strip()
            if not user_input:
                user_input = current_value
        else:
            user_input = input(f"{prompt}: ").strip()
        
        if not user_input:
            print(f"{Colors.RED}Este campo é obrigatório!{Colors.END}")
            continue
            
        if validator and not validator(user_input):
            print(f"{Colors.RED}Formato inválido!{Colors.END}")
            continue
            
        return user_input

def show_preview(new_values):
    """Mostra preview das configurações antes de salvar"""
    print(f"\n{Colors.YELLOW}{Colors.BOLD}📋 PREVIEW DAS CONFIGURAÇÕES{Colors.END}")
    print(f"{Colors.YELLOW}{'─' * 35}{Colors.END}")
    for key, value in new_values.items():
        print(f"{Colors.CYAN}{key:20}{Colors.END} = {Colors.GREEN}{value}{Colors.END}")
    print(f"{Colors.YELLOW}{'─' * 35}{Colors.END}")

def update_config_mk(values):
    """Atualiza apenas as variáveis Docker no config.mk"""
    config_path = Path("config.mk")
    
    if not config_path.exists():
        print(f"{Colors.RED}Arquivo config.mk não encontrado!{Colors.END}")
        return False
    
    with open(config_path, 'r') as f:
        lines = f.readlines()
    
    # Identificar limites da seção CONFIGURAÇÕES FLUIDAS
    start_idx = None
    end_idx = len(lines)
    for idx, line in enumerate(lines):
        if line.strip().startswith('# ====================================================================') and idx + 1 < len(lines):
            next_line = lines[idx + 1].strip()
            if next_line.startswith('# CONFIGURAÇÕES FLUIDAS') or next_line.startswith('# CONFIGURAÇÕES FLIDAS'):
                start_idx = idx
                continue
        if start_idx is not None and line.strip().startswith('# CONFIGURAÇÕES ESTRUTURAIS'):
            end_idx = idx
            break

    if start_idx is None:
        print(f"{Colors.RED}Seção 'CONFIGURAÇÕES FLUIDAS' não encontrada em config.mk!{Colors.END}")
        return False
    
    # Mapear posições existentes das chaves Docker dentro do intervalo
    docker_keys = ['DOCKER_TAG', 'DOCKER_USER', 'DOCKER_IMAGE']
    key_to_idx = {k: None for k in docker_keys}
    for idx in range(start_idx, end_idx):
        line = lines[idx]
        for k in docker_keys:
            if line.startswith(f"{k}="):
                key_to_idx[k] = idx

    # Atualizar valores Docker
    for key, value in values.items():
        if key in key_to_idx and key_to_idx[key] is not None:
            lines[key_to_idx[key]] = f"{key}={value}\n"

    with open(config_path, 'w') as f:
        f.writelines(lines)
    
    return True


def main():
    # Verifica se é modo não-interativo
    non_interactive = '--non-interactive' in sys.argv or not sys.stdin.isatty()
    
    print_header()
    
    # Variáveis para o protocolo de conferência
    backup_path = None
    original_hash = None
    
    # Tratamento de erro mais elegante
    try:
        # PROTOCOLO DE CONFERÊNCIA: Inicia preparação
        success, backup_path, original_hash = safe_config_update()
        if not success:
            print(f"{Colors.RED}❌ Falha no protocolo de conferência{Colors.END}")
            sys.exit(1)
        
        # Lê valores atuais
        current_values = read_config_file()
        
        # Define valores padrão se não existirem
        defaults = {
            'DOCKER_TAG': 'ploa2026',
            'DOCKER_USER': 'aidsplormg',
            'DOCKER_IMAGE': 'volumes'
        }
        
        # Mescla valores atuais com padrões
        for key, default_value in defaults.items():
            if key not in current_values:
                current_values[key] = default_value
        
        if not non_interactive:
            # Coleta inputs do usuário (modo interativo)
            new_values = {}
            
            print(f"{Colors.YELLOW}💡 Pressione Enter para aceitar o valor padrão ou digite o valor correto{Colors.END}\n")
            
            new_values['DOCKER_TAG'] = get_user_input(
                "Tag da imagem Docker", 
                current_values.get('DOCKER_TAG'), 
                validate_docker_tag
            )
            
            new_values['DOCKER_USER'] = get_user_input(
                "Usuário do Docker Hub", 
                current_values.get('DOCKER_USER')
            )
            
            new_values['DOCKER_IMAGE'] = get_user_input(
                "Nome da imagem Docker", 
                current_values.get('DOCKER_IMAGE')
            )
            
            # Mostra preview
            show_preview(new_values)
            
            # Confirmação
            print(f"\n{Colors.BLUE}{Colors.BOLD}💾 CONFIRMAÇÃO{Colors.END}")
            print(f"{Colors.BLUE}{'─' * 15}{Colors.END}")
            confirm = input(f"{Colors.YELLOW}Salvar configurações? (y/N): {Colors.END}").strip().lower()
            
            if confirm not in ['y', 'yes', 's', 'sim']:
                print(f"\n{Colors.RED}Configuração cancelada.{Colors.END}")
                # Restaura backup e limpa
                if backup_path and backup_path.exists():
                    restore_from_backup(backup_path)
                    cleanup_backup(backup_path)
                sys.exit(1)
        else:
            # Modo não-interativo: usa valores atuais do config.mk
            new_values = {k: v for k, v in current_values.items() if k in ['DOCKER_TAG', 'DOCKER_USER', 'DOCKER_IMAGE']}
            print(f"{Colors.BLUE}{Colors.BOLD}⚡ MODO NÃO-INTERATIVO{Colors.END}")
            print(f"{Colors.BLUE}{'─' * 20}{Colors.END}")
            print(f"{Colors.GREEN}Usando configurações atuais do config.mk{Colors.END}\n")
        
        # PROTOCOLO DE CONFERÊNCIA: Finaliza com validação
        if finalize_config_update(new_values, backup_path, original_hash):
            print(f"\n{Colors.GREEN}🎉 Configuração atualizada com sucesso!{Colors.END}")
        else:
            print(f"\n{Colors.RED}❌ Falha na validação - configuração não foi salva{Colors.END}")
            sys.exit(1)
        
        # Pergunta se quer atualizar o data.toml
        if not non_interactive:
            print(f"\n{Colors.YELLOW}{Colors.BOLD}📄 ATUALIZAR DATA.TOML{Colors.END}")
            print(f"{Colors.YELLOW}{'─' * 25}{Colors.END}")
            print(f"{Colors.BLUE}Deseja processar o arquivo data.toml e substituir variáveis?{Colors.END}")
            print(f"{Colors.BLUE}Isso substituirá ${Colors.BOLD}ANO_LOA${Colors.END}{Colors.BLUE} e outras variáveis do config.mk{Colors.END}")
            print(f"\n{Colors.YELLOW}Atualizar data.toml? (y/N): {Colors.END}", end="")
            try:
                response = input().strip().lower()
                if response in ['y', 'yes', 's', 'sim']:
                    print(f"\n{Colors.BLUE}Processando data.toml...{Colors.END}")
                    import subprocess
                    result = subprocess.run(['poetry', 'run', 'data-toml-update'], capture_output=True, text=True)
                    if result.returncode == 0:
                        print(f"{Colors.GREEN}✅ data.toml atualizado com sucesso!{Colors.END}")
                        if result.stdout:
                            print(result.stdout)
                    else:
                        print(f"{Colors.RED}❌ Erro ao processar data.toml{Colors.END}")
                        if result.stderr:
                            print(result.stderr)
                else:
                    print(f"{Colors.BLUE}data.toml não foi atualizado.{Colors.END}")
            except KeyboardInterrupt:
                print(f"\n{Colors.YELLOW}Operação cancelada.{Colors.END}")
        else:
            print(f"\n{Colors.BLUE}💡 Execute 'make data-toml-update' para processar o data.toml{Colors.END}")
        
        # Mensagem informativa sobre próximo passo
        print(f"\n{Colors.BLUE}{Colors.BOLD}🚀 PRÓXIMO PASSO{Colors.END}")
        print(f"{Colors.BLUE}{'─' * 20}{Colors.END}")
        print(f"{Colors.GREEN}make docker{Colors.END} - Baixa a imagem Docker configurada")
        
        # Pergunta se quer executar
        if not non_interactive:
            print(f"\n{Colors.YELLOW}Executar make docker agora? (y/N): {Colors.END}", end="")
            try:
                response = input().strip().lower()
                if response in ['y', 'yes', 's', 'sim']:
                    print(f"\n{Colors.BLUE}Executando make docker...{Colors.END}")
                    import subprocess
                    result = subprocess.run(['make', 'docker'], capture_output=False)
                    if result.returncode == 0:
                        print(f"{Colors.GREEN}✅ make docker executado com sucesso!{Colors.END}")
                    else:
                        print(f"{Colors.RED}❌ Erro ao executar make docker{Colors.END}")
                else:
                    print(f"{Colors.BLUE}make docker não executado.{Colors.END}")
            except KeyboardInterrupt:
                print(f"\n{Colors.YELLOW}Operação cancelada.{Colors.END}")
        else:
            print(f"\n{Colors.BLUE}💡 Execute 'make docker' para baixar a imagem Docker configurada{Colors.END}")
    
    except KeyboardInterrupt:
        print(f"\n\n{Colors.YELLOW}⚠️  Operação cancelada pelo usuário{Colors.END}")
        print(f"{Colors.BLUE}💡 Restaurando estado original...{Colors.END}")
        if backup_path and backup_path.exists():
            restore_from_backup(backup_path)
            cleanup_backup(backup_path)
        sys.exit(0)
    except Exception as e:
        print(f"\n{Colors.RED}❌ Erro inesperado: {e}{Colors.END}")
        print(f"{Colors.BLUE}💡 Restaurando estado original...{Colors.END}")
        if backup_path and backup_path.exists():
            restore_from_backup(backup_path)
            cleanup_backup(backup_path)
        sys.exit(1)

if __name__ == "__main__":
    main()
