import ntpath

import pandas as pd
from pathlib import Path
from frictionless import Package, Resource

df_dict = {}
bancos_names = ["BASE_CATEGORIA_PESSOAL",
              "BASE_DETALHAMENTO_OBRAS",
              "BASE_ORCAM_DESPESA_ITEM_FISCAL",
              "BASE_ORCAM_RECEITA_FISCAL",
              "BASE_QDD_FISCAL",
              "BASE_QDD_INVESTIMENTO",
              "BASE_QDD_PLURIANUAL_INVEST",
              "BASE_REPASSE_RECURSOS",
            ]
datapackage_path = Path.joinpath(Path(__file__).parents[1], 'datapackages/sisor-dados-2024')
datapackage_dataraw_path = Path.joinpath(Path(__file__).parents[1], 'datapackages/sisor-dados-2024/data-raw/')
bancos_sisor_path = Path.joinpath(Path(__file__).parents[1], 'bancos/SISOR/')

data_filenames = [Path.joinpath(datapackage_dataraw_path, y + '.html') for x in ([datapackage_dataraw_path]) for y in map(str.lower, bancos_names)]

#source_descriptor = Path.joinpath(datapackage_path , 'datapackage.json')
#resource_name = bancos_names[0].lower()
#package = Package(source_descriptor)
#resource = package.get_resource(resource_name)
#resource.transform(transform_pipeline)
#table = resource.to_petl()
#for field in resource.schema.fields:
#    if field.custom.get('target'):
#        table = etl.rename(table, field.name, field.custom['target'])

for filename in data_filenames:
    print(filename)
    df = pd.read_html(filename, header=0, index_col=0, decimal=',', thousands='.')
    save_path = Path.joinpath(bancos_sisor_path, filename.stem + '.xlsx' )
    df[0].to_excel(save_path, sheet_name=filename.stem.upper())

# install-in.txt -> piptools compilte -> gera requirements.txt ->pip install requirements.txt (ver pacotes que ele não achou por não exisitrem para pthon 3.7 e colocar a ultima versão disponivel no requirements-in.txt
# os requirements-in fica no repo volumes-docker