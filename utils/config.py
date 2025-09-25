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
    BOLD = '\033[1m'
    END = '\033[0m'

def print_header():
    print(f"{Colors.BLUE}{Colors.BOLD}")
    print("Configurando variáveis Docker...")
    print("=" * 40)
    print(f"{Colors.END}")

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

def validate_git_status():
    """Valida o status do repositório Git com UX melhorada"""
    if not os.path.exists('.git'):
        print(f"{Colors.YELLOW}ℹ️  Aviso: Não é um repositório Git{Colors.END}")
        return True
    
    try:
        # Verifica se há mudanças não commitadas
        result = subprocess.run(
            ['git', 'status', '--porcelain'],
            capture_output=True,
            text=True
        )
        
        if result.stdout.strip():
            print(f"\n{Colors.YELLOW}⚠️  Atenção: Existem alterações não commitadas neste repositório{Colors.END}")
            print(f"{Colors.BLUE}Para prosseguir com a configuração, você precisa primeiro resolver essas alterações.{Colors.END}")
            print(f"\n{Colors.YELLOW}📋 Arquivos modificados:{Colors.END}")
            
            # Mostra as mudanças de forma organizada
            for line in result.stdout.strip().split('\n'):
                if len(line) < 3:
                    continue
                
                # Extrai status e arquivo corretamente
                if line.startswith(' M'):  # Modificado no working directory
                    file = line[3:].strip()
                    print(f"  📝 {file}")
                elif line.startswith('M '):  # Modificado no staging
                    file = line[2:].strip()
                    print(f"  📝 {file}")
                elif line.startswith('A '):  # Adicionado
                    file = line[2:].strip()
                    print(f"  ➕ {file}")
                elif line.startswith('D '):  # Deletado
                    file = line[2:].strip()
                    print(f"  🗑️  {file}")
                elif line.startswith('??'):  # Não rastreado
                    file = line[2:].strip()
                    print(f"  ❓ {file}")
                else:
                    # Para outros casos, tenta extrair a partir da posição 3
                    file = line[3:].strip()
                    print(f"  🔄 {file}")
            
            print(f"\n{Colors.BLUE}💡 Opções disponíveis:{Colors.END}")
            print(f"  {Colors.GREEN}• Fazer commit: git add . && git commit -m 'Sua mensagem'{Colors.END}")
            print(f"  {Colors.GREEN}• Descartar alterações: git checkout -- <arquivo>{Colors.END}")
            print(f"  {Colors.GREEN}• Salvar temporariamente: git stash{Colors.END}")
            print(f"\n{Colors.YELLOW}Depois execute 'make config' novamente.{Colors.END}")
            return False
        
        # Verifica se está na branch main/master
        branch_info = get_git_info()
        if branch_info['branch'] not in ['main', 'master']:
            print(f"\n{Colors.YELLOW}⚠️  Aviso: Você está na branch '{branch_info['branch']}'{Colors.END}")
            print(f"{Colors.BLUE}💡 Recomendado: Use a branch 'main' ou 'master' para configurações{Colors.END}")
            confirm = input(f"\n{Colors.YELLOW}Continuar mesmo assim? (y/N): {Colors.END}").strip().lower()
            if confirm not in ['y', 'yes', 's', 'sim']:
                print(f"{Colors.BLUE}💡 Para mudar de branch: git checkout main{Colors.END}")
                return False
        
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"\n{Colors.RED}❌ Erro ao verificar status do Git: {e}{Colors.END}")
        print(f"{Colors.BLUE}💡 Verifique se o Git está instalado e configurado corretamente{Colors.END}")
        return False

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
    print(f"\n{Colors.YELLOW}{Colors.BOLD}Preview das configurações Docker:{Colors.END}")
    print("-" * 40)
    for key, value in new_values.items():
        print(f"{key:20} = {value}")
    print("-" * 40)

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
            if next_line.startswith('# CONFIGURAÇÕES FLUIDAS'):
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

def get_commit_info():
    """Coleta informações para o commit"""
    print(f"\n{Colors.BLUE}{Colors.BOLD}Configuração de Commit{Colors.END}")
    print("-" * 30)
    
    # Git add
    add_confirm = input("git add config.mk (Y/n): ").strip().lower()
    if add_confirm in ['n', 'no']:
        return None
    
    # Issue information
    print(f"\n{Colors.YELLOW}qual issue?{Colors.END}")
    org = input('org: "splor-mg" [splor-mg]: ').strip() or 'splor-mg'
    repo = input('repo: "volumes-loa" [volumes-loa]: ').strip() or 'volumes-loa'
    number = input('number: [opcional]: ').strip()
    
    return {
        'org': org,
        'repo': repo,
        'number': number
    }

def build_commit_message(values, commit_info):
    """Constrói a mensagem de commit melhorada"""
    # Monta o link do issue se fornecido
    issue_link = ""
    if commit_info['number']:
        issue_link = f"\n\nSee https://github.com/{commit_info['org']}/{commit_info['repo']}/issues/{commit_info['number']}"
    
    # Obtém informações do Git
    git_info = get_git_info()
    
    # Monta os parâmetros Docker
    params = []
    param_order = ['DOCKER_TAG', 'DOCKER_USER', 'DOCKER_IMAGE']
    
    for param in param_order:
        if param in values:
            params.append(f"  {param.lower()}: {values[param]}")
    
    params_text = "\n".join(params)
    
    # Informações adicionais
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    git_info_text = ""
    if git_info['is_git_repo'] and git_info['commit']:
        git_info_text = f"\n\nGenerated by: {git_info['commit']} ({git_info['branch']})"
    
    commit_message = f"""chore(config): update docker variables

Updated Docker configuration:
{params_text}

Timestamp: {timestamp}{git_info_text}{issue_link}"""
    
    return commit_message

def show_commit_preview(commit_message):
    """Mostra preview da mensagem de commit"""
    print(f"\n{Colors.YELLOW}{Colors.BOLD}Preview da mensagem de commit:{Colors.END}")
    print("-" * 50)
    print(commit_message)
    print("-" * 50)

def make_commit(commit_message):
    """Executa o commit com validações"""
    try:
        # Git add
        print(f"{Colors.BLUE}Adicionando config.mk ao staging...{Colors.END}")
        subprocess.run(['git', 'add', 'config.mk'], check=True)
        
        # Git commit
        print(f"{Colors.BLUE}Executando commit...{Colors.END}")
        subprocess.run(['git', 'commit', '-m', commit_message], check=True)
        
        print(f"\n{Colors.GREEN}{Colors.BOLD}✅ Commit realizado com sucesso!{Colors.END}")
        
        # Ações pós-commit
        post_commit_actions()
        
        return True
    except subprocess.CalledProcessError as e:
        print(f"\n{Colors.RED}❌ Erro ao fazer commit: {e}{Colors.END}")
        return False

def post_commit_actions():
    """Executa ações pós-commit"""
    git_info = get_git_info()
    
    if not git_info['is_git_repo']:
        return
    
    # Pergunta se quer fazer push
    push_choice = input(f"\n{Colors.YELLOW}Quer fazer push para o repositório remoto? (Y/n): {Colors.END}").strip().lower()
    
    if push_choice not in ['n', 'no']:
        try:
            print(f"{Colors.BLUE}Fazendo push...{Colors.END}")
            subprocess.run(['git', 'push'], check=True)
            print(f"{Colors.GREEN}✅ Push realizado com sucesso!{Colors.END}")
        except subprocess.CalledProcessError as e:
            print(f"{Colors.RED}❌ Erro ao fazer push: {e}{Colors.END}")

def main():
    # Verifica se é modo commit-only
    commit_only = '--commit-only' in sys.argv
    
    if commit_only:
        print(f"{Colors.BLUE}{Colors.BOLD}Modo Commit-Only{Colors.END}")
        print("=" * 40)
        print(f"{Colors.END}")
    
    print_header()
    
    # Tratamento de erro mais elegante
    try:
        # Validações iniciais
        if not validate_git_status():
            print(f"\n{Colors.RED}❌ Validações falharam. Abortando...{Colors.END}")
            print(f"{Colors.BLUE}💡 Resolva os problemas acima e tente novamente.{Colors.END}")
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
        
        if not commit_only:
            # Coleta inputs do usuário
            new_values = {}
            
            print("Configure as variáveis Docker:")
            print(f"{Colors.YELLOW}(Pressione Enter para aceitar o valor padrão ou digite o valor correto){Colors.END}\n")
            
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
            confirm = input(f"\n{Colors.YELLOW}Salvar configurações? (y/N): {Colors.END}").strip().lower()
            
            if confirm in ['y', 'yes', 's', 'sim']:
                if update_config_mk(new_values):
                    print(f"\n{Colors.GREEN}{Colors.BOLD}Configuração salva em config.mk!{Colors.END}")
                else:
                    print(f"\n{Colors.RED}Falha ao salvar configuração.{Colors.END}")
                    sys.exit(1)
            else:
                print(f"\n{Colors.RED}Configuração cancelada.{Colors.END}")
                sys.exit(1)
        else:
            # Modo commit-only: usa valores atuais do config.mk
            new_values = {k: v for k, v in current_values.items() if k in ['DOCKER_TAG', 'DOCKER_USER', 'DOCKER_IMAGE']}
            print(f"{Colors.GREEN}Usando configurações atuais do config.mk{Colors.END}")
        
        # Pergunta se quer fazer commit
        commit_choice = input(f"\n{Colors.YELLOW}Quer fazer commit das alterações? (Y/n): {Colors.END}").strip().lower()
        
        if commit_choice not in ['n', 'no']:
            commit_info = get_commit_info()
            if commit_info:
                commit_message = build_commit_message(new_values, commit_info)
                show_commit_preview(commit_message)
                
                commit_confirm = input(f"\n{Colors.YELLOW}Fazer commit? (Y/n): {Colors.END}").strip().lower()
                if commit_confirm not in ['n', 'no']:
                    success = make_commit(commit_message)
                    if success:
                        print(f"\n{Colors.GREEN}{Colors.BOLD}🎉 Configuração atualizada e commitada com sucesso!{Colors.END}")
                    else:
                        print(f"\n{Colors.RED}❌ Falha no processo de commit.{Colors.END}")
                else:
                    print(f"\n{Colors.RED}Commit cancelado.{Colors.END}")
            else:
                print(f"\n{Colors.RED}Commit cancelado.{Colors.END}")
        else:
            print(f"\n{Colors.BLUE}Commit não solicitado.{Colors.END}")
            print(f"{Colors.GREEN}✅ Configuração salva em config.mk!{Colors.END}")
        
        # Mensagem informativa sobre próximos passos
        print(f"\n{Colors.BLUE}{Colors.BOLD}Próximos passos:{Colors.END}")
        print(f"1. {Colors.GREEN}make docker{Colors.END} - Baixa a imagem Docker configurada")
        print(f"2. {Colors.GREEN}make info{Colors.END} - Extrai versões da imagem e atualiza config.mk")
        print(f"\n{Colors.YELLOW}ℹ️  As informações de ANO_LOA e versões dos pacotes são extraídas automaticamente da imagem Docker.{Colors.END}")
    
    except KeyboardInterrupt:
        print(f"\n\n{Colors.YELLOW}⚠️  Operação cancelada pelo usuário{Colors.END}")
        print(f"{Colors.BLUE}💡 Nenhuma alteração foi feita.{Colors.END}")
        sys.exit(0)
    except Exception as e:
        print(f"\n{Colors.RED}❌ Erro inesperado: {e}{Colors.END}")
        print(f"{Colors.BLUE}💡 Verifique os logs e tente novamente.{Colors.END}")
        sys.exit(1)

if __name__ == "__main__":
    main()
