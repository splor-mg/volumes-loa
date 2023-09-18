from pathlib import Path

filename = Path('datapackages/sigplan/data-raw/acoes_planejamento.txt')
save_path = Path('bancos/SISOR/acoes_planejamento.txt')

with open(filename, 'r', encoding='latin1') as source:
  content = source.read()

with open(save_path, 'w', encoding='utf-8') as destination:
  destination.write(content)
