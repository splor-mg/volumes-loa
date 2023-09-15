import pandas as pd
from pathlib import Path
from frictionless import Package, Resource


bancos_names = ["BASE_CATEGORIA_PESSOAL",
              "BASE_DETALHAMENTO_OBRAS",
              "BASE_ORCAM_DESPESA_ITEM_FISCAL",
              "BASE_ORCAM_RECEITA_FISCAL",
              "BASE_QDD_FISCAL",
              "BASE_QDD_INVESTIMENTO",
              "BASE_QDD_PLURIANUAL_INVEST",
              "BASE_REPASSE_RECURSOS",
            ]
datapackage_path = Path.joinpath(Path(__file__).parents[1], 'datapackages/sisor')
datapackage_dataraw_path = Path.joinpath(Path(__file__).parents[1], 'datapackages/sisor/data-raw/')
bancos_sisor_path = Path.joinpath(Path(__file__).parents[1], 'bancos/SISOR/')

data_filenames = [Path.joinpath(datapackage_dataraw_path, y + '.html') for x in ([datapackage_dataraw_path]) for y in map(str.lower, bancos_names)]

for filename in data_filenames:
  print("Formata base", filename)
  df = pd.read_html(filename, header=0, index_col=0, decimal=',', thousands='.', encoding='latin1')
  save_path = Path.joinpath(bancos_sisor_path, filename.stem + '.xlsx' )
  df[0].to_excel(save_path, sheet_name=filename.stem.upper())
  print("Arquivo", filename.stem,".xlsx salvo em ", bancos_sisor_path)

