import pandas as pd
from pathlib import Path
from frictionless import Package, Resource
import shutil


bancos_names = ["acoes_planejamento"]
datapackage_path = Path.joinpath(Path(__file__).parents[1], 'datapackages/sigplan')
datapackage_dataraw_path = Path.joinpath(Path(__file__).parents[1], 'datapackages/sigplan/data-raw/')
bancos_sisor_path = Path.joinpath(Path(__file__).parents[1], 'bancos/SISOR/')

data_filenames = [Path.joinpath(datapackage_dataraw_path, y + '.txt') for x in ([datapackage_dataraw_path]) for y in map(str.lower, bancos_names)]

for filename in data_filenames:
  save_path = Path.joinpath(bancos_sisor_path, filename.stem + '.txt' )
  print("copiando base", filename)

  with open(filename, 'r', encoding='utf-8') as source:
    content = source.read()

  with open(save_path, 'w', encoding='utf-8') as destination:
    destination.write(content)
  print("Arquivo", filename.stem,".txt salvo em ", bancos_sisor_path)

