"""
Gera os dados do volume 5 em volume5/data a partir de bancos/PPO/orcamento_despesa.csv:
- consolidado.txt: DEMONSTRATIVO CONSOLIDADO DA DESPESA
- qdd.txt: QUADRO DE DETALHAMENTO DA DESPESA - FISCAL
"""
from utils.python.consolidado_qdd import gera_consolidado, gera_qdd
from utils.python.trata_bancos import trata_orcamento_despesa

banco = trata_orcamento_despesa('bancos/PPO/orcamento_despesa.csv')

# Gera o consolidado
gera_consolidado(banco, 'volume5/data/consolidado.txt')

# Gera o QDD
gera_qdd(banco, 'volume5/data/qdd.txt', chave_extra=[])
