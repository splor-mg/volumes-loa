"""
Gera os dados do volume 2 em volume2/data a partir de datapackages/ppo:
- sumario.txt: UOs do orçamento fiscal, em ordem de poder, órgão e UO
- tabela1/ a tabela5/: uma tabela por UO, e tabela3/funfip.txt
"""
import sys
from pathlib import Path

from utils.python.funcoes import escreve_tabela
from utils.python.trata_bancos import (trata_classificacao_receita, trata_orcamento_despesa,
                                       trata_orcamento_pessoal, trata_orcamento_receita,
                                       trata_orcamento_repasse, trata_planejamento_acao)
from volume2.python.tabela1 import gera_tabela1
from volume2.python.tabela2 import gera_tabela2
from volume2.python.tabela3 import ACOES_INATIVOS, UOS_DESCONSIDERAR, gera_funfip, gera_tabela3
from volume2.python.tabela4 import gera_tabela4
from volume2.python.tabela5 import ajusta_despesa, gera_tabela5

DADOS = Path('volume2/data')
UOS_SEM_RECURSOS = ['9901']


# Prepara as bases -------------------------------------------------------------
despesa = trata_orcamento_despesa('datapackages/ppo/data/orcamento_despesa.csv')
codigos = ['funcao_cod', 'subfuncao_cod', 'programa_cod', 'acao_cod', 'identificador_cod',
           'projeto_atividade_cod', 'subprojeto_cod', 'categoria_cod', 'grupo_cod', 'modalidade_cod',
           'elemento_cod', 'iag_cod', 'fonte_cod', 'ipu_cod']
despesa[codigos] = despesa[codigos].astype(int)

acoes = trata_planejamento_acao('datapackages/ppo/data/planejamento_acao.csv')
codigos = ['funcao_cod', 'subfuncao_cod', 'programa_cod', 'acao_cod', 'iag_cod']
acoes[codigos] = acoes[codigos].astype(int)
acoes['identificador_cod'], acoes['projeto_atividade_cod'] = divmod(acoes['acao_cod'], 1000)

pessoal = trata_orcamento_pessoal('datapackages/ppo/data/orcamento_pessoal.csv')
terceirizado = pessoal['pessoal_classificacao'].str.contains('TERCEIRI')
pessoal.loc[terceirizado, 'pessoal_classificacao'] = 'PESSOAL ATIVO'
niveis = {'ATIVO': 1, 'TEMPORÁRI': 2, 'PENSIONISTA': 3, 'INATIVO': 4}
nivel = pessoal['pessoal_classificacao'].str.extract(f'({"|".join(niveis)})')[0]
pessoal['nivel'] = nivel.map(niveis)
sem_nivel = pessoal.loc[pessoal['nivel'].isna(), 'pessoal_classificacao'].unique()
if len(sem_nivel):
    print(f'Warning: V2 T3: classificação de orcamento_pessoal.csv sem nível: {", ".join(sem_nivel)}. '
          'Definir no código em que ordem ela sai na tabela', file=sys.stderr)

receita = trata_orcamento_receita('datapackages/ppo/data/orcamento_receita.csv')
classificacao = trata_classificacao_receita('datapackages/ppo/data/classificacao_receita.csv')
repasse = trata_orcamento_repasse('datapackages/ppo/data/orcamento_repasse.csv')

# Sumário ----------------------------------------------------------------------
sumario = despesa.drop_duplicates('uo_cod')
sumario = sumario.sort_values(['poder_cod', 'orgao_cod', 'uo_cod'], key=lambda coluna: coluna.astype(int))
for nivel in ['orgao', 'uo']:
    sumario[nivel] = (sumario[f'{nivel}_cod'].str.replace(r'(.)(..)(.)', r'\1.\2.\3', regex=True)
                      + ' - ' + sumario[f'{nivel}_nome'] + ' - ' + sumario['uo_sigla'])
sumario = sumario.rename(columns={'poder_desc': 'poder'})
escreve_tabela(sumario[['poder', 'orgao_cod', 'orgao', 'uo_cod', 'uo']], DADOS / 'sumario.txt')

# Tabelas 1 e 2 ----------------------------------------------------------------
for uo_cod, uo in despesa.groupby('uo_cod'):
    gera_tabela1(uo, acoes, DADOS / 'tabela1' / f'{uo_cod}.txt')
    gera_tabela2(uo, DADOS / 'tabela2' / f'{uo_cod}.txt')

# Tabela 3 ---------------------------------------------------------------------
despesa_pessoal = despesa[((despesa['grupo_cod'] == 1) & (despesa['ipu_cod'] != 9))
                          | ((despesa['grupo_cod'] == 3) & (despesa['elemento_cod'] == 34))]
com_inativos = set(despesa.loc[despesa['acao_cod'].isin(ACOES_INATIVOS), 'uo_cod'])
for uo_cod, uo in pessoal[~pessoal['uo_cod'].isin(UOS_DESCONSIDERAR)].groupby('uo_cod', sort=False):
    gera_tabela3(uo, despesa_pessoal[despesa_pessoal['uo_cod'] == uo_cod], uo_cod in com_inativos,
                 DADOS / 'tabela3' / f'{uo_cod}.txt')
gera_funfip(despesa, pessoal, sumario, DADOS / 'tabela3' / 'funfip.txt')

# Tabelas 4 e 5 ----------------------------------------------------------------
ajustado = ajusta_despesa(despesa, repasse)
for uo_cod in sumario.loc[~sumario['uo_cod'].isin(UOS_SEM_RECURSOS), 'uo_cod']:
    receita_uo = receita[receita['uo_cod'] == uo_cod]
    gera_tabela4(receita_uo, classificacao, DADOS / 'tabela4' / f'{uo_cod}.txt')
    if not uo_cod.startswith('1'):
        gera_tabela5(uo_cod, receita_uo, ajustado[ajustado['uo_cod'] == uo_cod], repasse,
                     despesa.loc[despesa['uo_cod'] == uo_cod, 'vlr_loa_desp'].sum(),
                     DADOS / 'tabela5' / f'{uo_cod}.txt')
