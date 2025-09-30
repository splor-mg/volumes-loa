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
    
    # Saída minimalista: apenas linhas de arquivo atualizado por volume
    
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
    
    # Sem resumo verboso; retorna apenas status
    return success_count == total_volumes

def main():
    """Função principal"""
    # Não imprimir cabeçalho para manter logs concisos
    
    try:
        success = update_volume_covers()
        if not success:
            print(f"{Colors.YELLOW}⚠️  Nem todas as capas foram atualizadas{Colors.END}")
            exit(1)
    except Exception as e:
        print(f"\n{Colors.RED}❌ Erro inesperado: {e}{Colors.END}")
        exit(1)

if __name__ == "__main__":
    main()
