import ntpath

import pandas as pd
from pathlib import Path
from glob import glob

df_dict = {}
map_bancos = {}


data_path = Path.joinpath(Path(__file__).parents[1], 'bancos/SISOR/*.xlsx').as_posix()
print(data_path)

bancos_filenames = [Path(x).as_posix() for x in (glob(data_path))]


for filename in bancos_filenames:
    print(filename)

datapackage_path = Path.joinpath(Path(__file__).parents[1], 'datapackages/sisor-dados-2024/data/*.csv').as_posix()
datapackage_filenames = [Path(x).as_posix() for x in (glob(datapackage_path))]
print(datapackage_filenames)

for filename in datapackage_filenames:
    print(filename)

for filename in datapackage_filenames:
    df =  pd.read_csv(filename)
    df_dict[Path(str.upper(filename)).stem] = df

print(df_dict)