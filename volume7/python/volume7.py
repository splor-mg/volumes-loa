"""
Gera os dados do volume 7 em volume7/data a partir de bancos/PPO/orcamento_despesa_fonte_80_95.csv:
- consolidado.txt: DEMONSTRATIVO CONSOLIDADO DA DESPESA
- qdd.txt: QUADRO DE DETALHAMENTO DA DESPESA - FISCAL
"""
from utils.python.consolidado_qdd import gera_consolidado, gera_qdd
from utils.python.trata_bancos import trata_orcamento_despesa_fonte_80_95

banco = trata_orcamento_despesa_fonte_80_95('bancos/PPO/orcamento_despesa_fonte_80_95.csv')

# Gera o consolidado
gera_consolidado(banco, 'volume7/data/consolidado.txt')

# Gera o QDD
gera_qdd(banco, 'volume7/data/qdd.txt', chave_extra=['sequencial_iniciativa'])
