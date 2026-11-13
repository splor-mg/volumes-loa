from pathlib import Path
import shutil

datapackages_dir = Path('datapackages/apoio/data-raw/')
sisor_dir = Path('bancos/SISOR/')
manual_dir = Path('bancos/manual/')
v1_data_dir = Path('volume1/data/')

items = [
 (datapackages_dir / 'exec_desp_realizada.xlsx', sisor_dir / 'exec_desp_realizada.xlsx'),
 (datapackages_dir / 'exec_rec.xlsx', sisor_dir / 'exec_rec.xlsx'),
 (datapackages_dir / 'FFP_acoes.xlsx', manual_dir / 'FFP_acoes.xlsx'),
 (datapackages_dir / 'memoria_calculo.xlsx', manual_dir / 'memoria_calculo.xlsx' ),
 (datapackages_dir / 'desc_base_legal_demonstrativos.xlsx', manual_dir / 'desc_base_legal_demonstrativos.xlsx' ),
 (datapackages_dir / 'demonstrativo_despesas_obrigatorias.csv', v1_data_dir / 'tabela40.txt' ),
 (Path('datapackages/fonte_stn/data/fonte_stn.csv'), manual_dir / 'fonte_stn.csv' ),
 ]

for item in items:
    shutil.copy(item[0], item[1])
