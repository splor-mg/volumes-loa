"""
Apaga todos os arquivos gerados após rodar `dpm install` e `make volumes`,
deixando o projeto pronto para regeneração completa.
"""
import shutil
from pathlib import Path

PADROES = [
    f"volume{v}/data/**/*.{ext}" for v in range(1, 8) for ext in ("txt", "csv")
]

EXCECOES = {
    Path("logs/.gitkeep"),
}

PASTAS = [f"volume{v}/pdf/aux_files" for v in range(1, 8)] + [
    "pdf",
    "logs",
    "datapackages",
]

for padrao in PADROES:
    for arquivo in Path().glob(padrao):
        if arquivo.is_file() and arquivo not in EXCECOES:
            arquivo.unlink()

for pasta in PASTAS:
    for item in Path(pasta).glob("*"):
        if item.is_dir():
            shutil.rmtree(item)
        elif item not in EXCECOES:
            item.unlink()

print("reset ok")
