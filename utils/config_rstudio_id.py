#!/usr/bin/env python3
"""
Remove a ProjectId line from an RStudio .Rproj file.

Usage:
  poetry run config-project-id               # operates on ./LOA.Rproj
  poetry run config-project-id --path path   # operates on given file
  poetry run config-project-id --quiet       # suppress non-error output

Behavior:
  - Idempotent: running multiple times produces the same file after first run.
  - If the file does not exist, returns exit code 0 and prints a hint unless --quiet.
  - Only removes lines that start with "ProjectId" (case-sensitive) at column 1.
"""

from __future__ import annotations

import argparse
from pathlib import Path
import sys


def remove_project_id(target_path: Path, quiet: bool) -> int:
    if not target_path.exists():
        if not quiet:
            print(f"⚠️  Arquivo não encontrado: {target_path.as_posix()} (nada a fazer)")
        return 0

    original = target_path.read_text(encoding="utf-8").splitlines(keepends=True)

    changed = False
    filtered: list[str] = []
    for line in original:
        if line.startswith("ProjectId"):
            changed = True
            continue
        filtered.append(line)

    if not changed:
        if not quiet:
            print("✅ Nada a remover: ProjectId não encontrado.")
        return 0

    # Write back preserving newline endings from original content
    target_path.write_text("".join(filtered), encoding="utf-8")
    if not quiet:
        print("✅ ProjectId removido de", target_path.name)
    return 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description="Remove ProjectId de um arquivo .Rproj")
    p.add_argument(
        "--path",
        dest="path",
        default="LOA.Rproj",
        help="Caminho do arquivo .Rproj (padrão: LOA.Rproj)",
    )
    p.add_argument(
        "--quiet",
        action="store_true",
        help="Não imprimir mensagens em caso de sucesso",
    )
    return p


def main() -> None:
    args = build_parser().parse_args()
    try:
        code = remove_project_id(Path(args.path), args.quiet)
        sys.exit(code)
    except Exception as exc:  # pragma: no cover
        if not args.quiet:
            print(f"❌ Erro: {exc}")
        sys.exit(1)


if __name__ == "__main__":
    main()


