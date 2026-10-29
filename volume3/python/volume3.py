"""
Gera os dados do volume 3 em volume3/data a partir de bancos/PPO:
- sumario.txt: UOs com investimento, em ordem de código, com o órgão e a UO usados nas tabelas
- consolidado/: quadros consolidados (volume3/python/consolidados.py)
- tabela1/<uo>.txt a tabela5/<uo>.txt: relatórios por empresa (volume3/python/tabelas.py)
"""
import sys
import pandas as pd
from pathlib import Path

from utils.python.funcoes import escreve_tabela
from utils.python.trata_bancos import trata_orcamento_despesa_investimento, trata_planejamento_acao
from volume3.python.consolidados import gera_consolidado1, gera_consolidado2, gera_consolidado3
from volume3.python.tabelas import (CHAVE, gera_tabela1, gera_tabela2, gera_tabela3, gera_tabela4,
                                    gera_tabela5)

DADOS = Path('volume3/data')

qdd = trata_orcamento_despesa_investimento('bancos/PPO/orcamento_despesa_investimento.csv')
for coluna in CHAVE:
    qdd[coluna] = qdd[coluna].astype(int)

qdd['empresa'] = qdd['uo_nome'] + ' - ' + qdd['uo_sigla']

qdd['uo'] = (qdd['uo_cod'].str.replace(r'(.)(..)(.)', r'\1.\2.\3', regex=True)
             + ' - ' + qdd['empresa'])

qdd['orgao'] = (qdd['orgao_cod'].str.replace(r'(.)(..)(.)', r'\1.\2.\3', regex=True)
                + ' - ' + qdd['orgao_nome']
                + ' - ' + qdd['uo_sigla'])

# Descrições, finalidade e produto de cada ação
acoes = trata_planejamento_acao('bancos/PPO/planejamento_acao.csv')
acoes = acoes.rename(columns={'uo_acao_cod': 'uo_cod'})
acoes['vlr_meta_fisica_ano0'] = pd.to_numeric(acoes['vlr_meta_fisica_ano0'].str.replace(',', '.'))

colunas = ['uo_cod',
           'acao_cod',
           'funcao_desc',
           'subfuncao_desc',
           'acao_finalidade',
           'produto_desc',
           'unidade_medida_desc',
           'vlr_meta_fisica_ano0']

qdd = qdd.merge(acoes[colunas], how='left', validate='many_to_one')

sem_acao = qdd.loc[qdd['funcao_desc'].isna(), ['uo_cod', 'acao_cod']].drop_duplicates()
if len(sem_acao):
    print('Warning: Ações (UO/ação) sem correspondência em planejamento_acao.csv: '
          f'{", ".join(sem_acao["uo_cod"] + "/" + sem_acao["acao_cod"])}', file=sys.stderr)

# Gera o sumário ---------------------------------------------------------------
sumario = qdd[['uo_cod', 'orgao', 'uo', 'empresa']].drop_duplicates()
escreve_tabela(sumario.sort_values('uo_cod'), DADOS / 'sumario.txt')

# Gera os consolidados ---------------------------------------------------------
gera_consolidado1(qdd, DADOS / 'consolidado' / 't1_investimentos_empresa.txt')
gera_consolidado2(qdd, DADOS / 'consolidado' / 't2_investimentos_empresa_detalhamento.txt')
gera_consolidado3(qdd, DADOS / 'consolidado' / 't3_investimentos_projeto_atividade.txt')

# Gera as tabelas por UO -------------------------------------------------------
for uo_cod, uo in qdd.groupby('uo_cod'):
    gera_tabela1(uo, DADOS / 'tabela1' / f'{uo_cod}.txt')
    gera_tabela2(uo, DADOS / 'tabela2' / f'{uo_cod}.txt')
    gera_tabela3(uo, DADOS / 'tabela3' / f'{uo_cod}.txt')
    gera_tabela4(uo, DADOS / 'tabela4' / f'{uo_cod}.txt')
    gera_tabela5(uo, DADOS / 'tabela5' / f'{uo_cod}.txt')
