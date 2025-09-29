#!/usr/bin/env python3
"""
Instalador interativo de versões dos pacotes R: relatorios, execucao e reest.

Padrões são lidos de config.mk (RELATORIOS_VERSION, EXECUCAO_VERSION, REEST_VERSION).
Executa instalação via Rscript usando dotenv + remotes::install_github.
"""

import sys
import re
import subprocess
from pathlib import Path


class Colors:
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    END = '\033[0m'


def read_config_versions(config_path: Path) -> dict:
    defaults = {
        'RELATORIOS_VERSION': 'latest',
        'EXECUCAO_VERSION': 'latest',
        'REEST_VERSION': 'latest',
    }
    if not config_path.exists():
        return defaults
    with config_path.open('r') as f:
        for raw in f:
            line = raw.strip()
            if not line or line.startswith('#'):
                continue
            if '=' in line:
                key, value = line.split('=', 1)
                key = key.strip()
                value = value.strip()
                if '#' in value:
                    value = value.split('#')[0].strip()
                if key in defaults and value:
                    defaults[key] = value
    return defaults


def prompt_with_default(label: str, default_value: str) -> str:
    try:
        user_input = input(f"{label}: [{default_value}] ")
    except EOFError:
        user_input = ''
    value = user_input.strip()
    return default_value if value == '' else value


def validate_version(tag: str) -> bool:
    # Aceita padrões comuns de tag/branch/sha sem espaços
    return re.match(r'^[A-Za-z0-9._\-]+$', tag) is not None


def print_header():
    print(f"{Colors.BLUE}{Colors.BOLD}")
    print("📦 INSTALAÇÃO DE PACOTES DCAF (R)")
    print("=" * 50)
    print(f"{Colors.END}")


def show_preview(versions: dict):
    print(f"\n{Colors.YELLOW}{Colors.BOLD}📋 PREVIEW DAS VERSÕES{Colors.END}")
    print(f"{Colors.YELLOW}{'─' * 35}{Colors.END}")
    for k, v in versions.items():
        print(f"{Colors.BLUE}{k:20}{Colors.END} = {Colors.GREEN}{v}{Colors.END}")
    print(f"{Colors.YELLOW}{'─' * 35}{Colors.END}")


def run_r_install(pkg: str, version: str) -> int:
    # Monta expressão R para: carregar dotenv e instalar do github com token
    # Repositórios seguem padrão 'splor-mg/<pacote>'
    repo = f"splor-mg/{pkg}"
    r_expr = (
        "dotenv::load_dot_env('/run/secrets/secret'); "
        f"remotes::install_github('{repo}@{version}', auth_token = Sys.getenv('GITHUB_TOKEN'))"
    )
    cmd = ['Rscript', '-e', r_expr]
    try:
        proc = subprocess.run(cmd)
        return proc.returncode
    except FileNotFoundError:
        print(f"{Colors.RED}❌ Rscript não encontrado no PATH.{Colors.END}")
        return 127


def main():
    print_header()

    config_versions = read_config_versions(Path('config.mk'))

    # Coleta interativa
    print(f"{Colors.YELLOW}💡 Pressione Enter para aceitar a versão padrão (do config.mk){Colors.END}\n")

    relatorios_version = prompt_with_default('Versão do pacote relatorios', config_versions['RELATORIOS_VERSION'])
    while not validate_version(relatorios_version):
        print(f"{Colors.RED}Versão inválida. Use letras, números, '.', '-' ou '_' {Colors.END}")
        relatorios_version = prompt_with_default('Versão do pacote relatorios', config_versions['RELATORIOS_VERSION'])

    execucao_version = prompt_with_default('Versão do pacote execucao', config_versions['EXECUCAO_VERSION'])
    while not validate_version(execucao_version):
        print(f"{Colors.RED}Versão inválida. Use letras, números, '.', '-' ou '_' {Colors.END}")
        execucao_version = prompt_with_default('Versão do pacote execucao', config_versions['EXECUCAO_VERSION'])

    reest_version = prompt_with_default('Versão do pacote reest', config_versions['REEST_VERSION'])
    while not validate_version(reest_version):
        print(f"{Colors.RED}Versão inválida. Use letras, números, '.', '-' ou '_' {Colors.END}")
        reest_version = prompt_with_default('Versão do pacote reest', config_versions['REEST_VERSION'])

    new_versions = {
        'RELATORIOS_VERSION': relatorios_version,
        'EXECUCAO_VERSION': execucao_version,
        'REEST_VERSION': reest_version,
    }

    show_preview(new_versions)

    # Confirmação
    print(f"\n{Colors.BLUE}{Colors.BOLD}💾 CONFIRMAÇÃO{Colors.END}")
    print(f"{Colors.BLUE}{'─' * 15}{Colors.END}")
    try:
        confirm = input(f"{Colors.YELLOW}Instalar as versões acima? (y/N): {Colors.END}").strip().lower()
    except EOFError:
        confirm = 'n'
    if confirm not in ['y', 'yes', 's', 'sim']:
        print(f"\n{Colors.YELLOW}Operação cancelada.{Colors.END}")
        sys.exit(1)

    # Instalações
    print(f"\n{Colors.BLUE}Instalando pacotes no R (via remotes::install_github)...{Colors.END}")
    failures = []

    # relatorios
    print(f"- relatorios@{relatorios_version}")
    rc = run_r_install('relatorios', relatorios_version)
    if rc != 0:
        failures.append(('relatorios', rc))

    # execucao
    print(f"- execucao@{execucao_version}")
    rc = run_r_install('execucao', execucao_version)
    if rc != 0:
        failures.append(('execucao', rc))

    # reest
    print(f"- reest@{reest_version}")
    rc = run_r_install('reest', reest_version)
    if rc != 0:
        failures.append(('reest', rc))

    if failures:
        print(f"\n{Colors.RED}❌ Algumas instalações falharam:{Colors.END}")
        for name, code in failures:
            print(f"  {name}: código {code}")
        sys.exit(1)

    print(f"\n{Colors.GREEN}✅ Instalação concluída com sucesso!{Colors.END}")


if __name__ == '__main__':
    main()


