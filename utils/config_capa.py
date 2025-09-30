#!/usr/bin/env python3
"""
Script para atualizar capas dos volumes
"""

import shutil
from pathlib import Path

# Cores para output
class Colors:
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    CYAN = '\033[96m'
    BOLD = '\033[1m'
    END = '\033[0m'

def update_volume_covers():
    """Atualiza as capas dos volumes copiando de capas/capaLOA.pdf"""
    source_cover = Path('capas/capaLOA.pdf')
    
    if not source_cover.exists():
        print(f"{Colors.RED}❌ Arquivo `capas/capaLOA.pdf` não encontrado.{Colors.END}")
        print(f"{Colors.YELLOW}💡 Coloque a nova capa na pasta `capas/` e tente novamente.{Colors.END}")
        return False
    
    print(f"{Colors.BLUE}📄 Atualizando capas dos volumes...{Colors.END}")
    print(f"{Colors.CYAN}Origem: {source_cover.as_posix()}{Colors.END}")
    print()
    
    volumes = ['volume1', 'volume2', 'volume3', 'volume4', 'volume5', 'volume6', 'volume7']
    success_count = 0
    total_volumes = len(volumes)
    
    for vol in volumes:
        dest = Path(vol) / 'Rnw' / 'capaLOA.pdf'
        try:
            # Garante que o diretório existe
            dest.parent.mkdir(parents=True, exist_ok=True)
            
            # Copia o arquivo
            shutil.copyfile(source_cover, dest)
            print(f"{Colors.GREEN}✓ {dest.as_posix()} atualizado{Colors.END}")
            success_count += 1
            
        except Exception as e:
            print(f"{Colors.YELLOW}⚠️  Falha ao atualizar {dest.as_posix()}: {e}{Colors.END}")
    
    print()
    if success_count == total_volumes:
        print(f"{Colors.GREEN}✅ Capas atualizadas em todos os volumes disponíveis ({success_count}/{total_volumes}){Colors.END}")
        return True
    else:
        print(f"{Colors.YELLOW}⚠️  Capas atualizadas em {success_count}/{total_volumes} volumes{Colors.END}")
        return success_count > 0

def main():
    """Função principal"""
    print(f"{Colors.BLUE}{Colors.BOLD}📄 ATUALIZAÇÃO DE CAPAS DOS VOLUMES{Colors.END}")
    print(f"{Colors.BLUE}{'─' * 35}{Colors.END}")
    print(f"{Colors.CYAN}A nova capa enviada pela DCPPN deve estar em `capas/capaLOA.pdf`{Colors.END}")
    print()
    
    try:
        success = update_volume_covers()
        if success:
            print(f"\n{Colors.GREEN}🎉 Atualização de capas concluída!{Colors.END}")
        else:
            print(f"\n{Colors.RED}❌ Falha na atualização de capas{Colors.END}")
            exit(1)
    except Exception as e:
        print(f"\n{Colors.RED}❌ Erro inesperado: {e}{Colors.END}")
        exit(1)

if __name__ == "__main__":
    main()
