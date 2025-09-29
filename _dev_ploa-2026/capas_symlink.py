#!/usr/bin/env python3

"""
Cria symlinks de capa para volumes (exceto volume1), apontando para capas/capaLOA.pdf.

Padrão:
- Detecta volumes automaticamente: volume2..volume9 (existentes no repo)
- Para cada volume, garante link em volumeX/Rnw/capaLOA.pdf -> ../../capas/capaLOA.pdf
- Se existir arquivo regular, faz backup com sufixo .backup-YYYYmmdd-HHMMSS antes de substituir.

Opções:
--force           Força recriação do link mesmo se já existir
--volumes 2,3,5   Limita aos volumes informados (números)
--dry-run         Apenas mostra o que faria

Saída clara com ações por volume.
"""

from __future__ import annotations

import argparse
import datetime as dt
from pathlib import Path
import sys


REPO_ROOT = Path(__file__).resolve().parents[1]
CAPA_SRC = REPO_ROOT / "capas" / "capaLOA.pdf"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Cria symlinks de capaLOA.pdf nos volumes 2..N")
    parser.add_argument(
        "--force",
        action="store_true",
        help="Força recriação do link mesmo se já existir",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Mostra as ações sem aplicar mudanças",
    )
    parser.add_argument(
        "--volumes",
        type=str,
        default="",
        help="Lista de volumes (ex.: 2,3,5). Vazio = auto-detectar volumes >=2",
    )
    return parser.parse_args()


def discover_volumes(explicit: list[int] | None) -> list[int]:
    if explicit:
        return sorted({v for v in explicit if v >= 2})
    vols: list[int] = []
    for p in REPO_ROOT.glob("volume*/Rnw"):
        try:
            num = int(p.parent.name.replace("volume", ""))
        except ValueError:
            continue
        if num >= 2:
            vols.append(num)
    return sorted(set(vols))


def ensure_symlink(volume_num: int, force: bool, dry_run: bool) -> None:
    rnw_dir = REPO_ROOT / f"volume{volume_num}" / "Rnw"
    target = rnw_dir / "capaLOA.pdf"
    # caminho relativo a partir do Rnw até capas/capaLOA.pdf
    link_dest_rel = Path("..") / ".." / "capas" / "capaLOA.pdf"

    if not rnw_dir.exists():
        print(f"volume{volume_num}: diretório ausente: {rnw_dir}")
        return

    if not CAPA_SRC.exists():
        print(f"ERRO: arquivo fonte não encontrado: {CAPA_SRC}")
        sys.exit(1)

    if target.is_symlink():
        current = target.readlink()
        if current == link_dest_rel and not force:
            print(f"volume{volume_num}: OK (symlink já aponta para {link_dest_rel})")
            return
        else:
            print(f"volume{volume_num}: atualizar symlink -> {link_dest_rel}")
            if not dry_run:
                target.unlink(missing_ok=True)
                target.symlink_to(link_dest_rel)
            return

    if target.exists():
        ts = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
        backup = target.with_suffix(f".backup-{ts}.pdf")
        print(f"volume{volume_num}: backup {target.name} -> {backup.name} e criar symlink")
        if not dry_run:
            target.rename(backup)
            target.symlink_to(link_dest_rel)
        return

    # não existe: criar
    print(f"volume{volume_num}: criar symlink {target.name} -> {link_dest_rel}")
    if not dry_run:
        target.symlink_to(link_dest_rel)


def main() -> int:
    args = parse_args()
    explicit = None
    if args.volumes:
        try:
            explicit = [int(x.strip()) for x in args.volumes.split(",") if x.strip()]
        except ValueError:
            print("--volumes deve conter números separados por vírgula, ex.: 2,3,5")
            return 2

    volumes = discover_volumes(explicit)
    if not volumes:
        print("Nenhum volume >=2 detectado")
        return 0

    print(f"Fonte da capa: {CAPA_SRC}")
    for v in volumes:
        ensure_symlink(v, force=args.force, dry_run=args.dry_run)

    # Verificação pós-aplicação (apenas se não for dry-run)
    if not args.dry_run:
        print("\n=== VERIFICAÇÃO DOS SYMLINKS ===")
        all_ok = True
        for v in volumes:
            rnw_dir = REPO_ROOT / f"volume{v}" / "Rnw"
            target = rnw_dir / "capaLOA.pdf"
            link_dest_rel = Path("..") / ".." / "capas" / "capaLOA.pdf"
            
            if not target.is_symlink():
                print(f"volume{v}: ❌ NÃO é symlink")
                all_ok = False
                continue
            
            current = target.readlink()
            if current != link_dest_rel:
                print(f"volume{v}: ❌ aponta para {current} (esperado: {link_dest_rel})")
                all_ok = False
                continue
            
            print(f"volume{v}: ✅ OK (symlink -> {link_dest_rel})")
        
        if all_ok:
            print("✅ Todos os symlinks estão corretos!")
        else:
            print("❌ Alguns symlinks precisam de correção.")
            return 1
    
    # Limpeza de backups antigos (apenas se não for dry-run)
    if not args.dry_run:
        print("\n=== LIMPEZA DE BACKUPS ANTIGOS ===")
        backup_pattern = "capaLOA.pdf.backup-*.pdf"
        backups_found = 0
        for v in volumes:
            rnw_dir = REPO_ROOT / f"volume{v}" / "Rnw"
            for backup_file in rnw_dir.glob(backup_pattern):
                backups_found += 1
                print(f"volume{v}: removendo backup {backup_file.name}")
                backup_file.unlink(missing_ok=True)
        
        if backups_found == 0:
            print("Nenhum backup antigo encontrado.")
        else:
            print(f"✅ {backups_found} backup(s) removido(s).")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())


