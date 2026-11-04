"""
Gera os dados do volume 2 em volume2/data a partir de bancos/PPO:
- sumario.txt: UOs do orçamento fiscal, em ordem de poder, órgão e UO
- tabela1/ a tabela5/: uma tabela por UO, e tabela3/funfip.txt
"""
import sys
import pandas as pd
from pathlib import Path

from utils.python.formata_texto import corrige_caracteres_especiais
from utils.python.funcoes import escreve_tabela
from utils.python.trata_bancos import (le_planilha, trata_orcamento_despesa, trata_orcamento_pessoal,
                                       trata_orcamento_receita, trata_orcamento_repasse, trata_planejamento_acao)
from volume2.python.tabela1 import gera_tabela1
from volume2.python.tabela2 import gera_tabela2
from volume2.python.tabela3 import ACOES_INATIVOS, UOS_DESCONSIDERAR, gera_funfip, gera_tabela3
from volume2.python.tabela4 import gera_tabela4
from volume2.python.tabela5 import ajusta_despesa, gera_tabela5

DADOS = Path('volume2/data')
UOS_SEM_RECURSOS = ['9901']


# Prepara as bases -------------------------------------------------------------
despesa = trata_orcamento_despesa('bancos/PPO/orcamento_despesa.csv')
codigos = ['funcao_cod', 'subfuncao_cod', 'programa_cod', 'acao_cod', 'identificador_cod',
           'projeto_atividade_cod', 'subprojeto_cod', 'categoria_cod', 'grupo_cod', 'modalidade_cod',
           'elemento_cod', 'iag_cod', 'fonte_cod', 'ipu_cod']
despesa[codigos] = despesa[codigos].astype(int)

acoes = trata_planejamento_acao('bancos/PPO/planejamento_acao.csv')
codigos = ['funcao_cod', 'subfuncao_cod', 'programa_cod', 'acao_cod', 'iag_cod']
acoes[codigos] = acoes[codigos].astype(int)
acoes['identificador_cod'], acoes['projeto_atividade_cod'] = divmod(acoes['acao_cod'], 1000)

grupos = le_planilha('bancos/manual/desc_grupos_de_despesa.xlsx')
grupos = dict(zip(grupos['CODIGO'], grupos['ESPECIFICACAO'].str.upper()))
fontes = le_planilha('bancos/manual/desc_fontes_de_recursos.xlsx').dropna(subset='CLASSIFICACAO')
fontes = fontes.set_index('CODIGO')['CLASSIFICACAO']

pessoal = trata_orcamento_pessoal('bancos/PPO/orcamento_pessoal.csv')
terceirizado = pessoal['pessoal_classificacao'].str.contains('TERCEIRI')
pessoal.loc[terceirizado, 'pessoal_classificacao'] = 'PESSOAL ATIVO'
niveis = {'ATIVO': 1, 'TEMPORÁRI': 2, 'PENSIONISTA': 3, 'INATIVO': 4}
nivel = pessoal['pessoal_classificacao'].str.extract(f'({"|".join(niveis)})')[0]
pessoal['nivel'] = nivel.map(niveis)
sem_nivel = pessoal.loc[pessoal['nivel'].isna(), 'pessoal_classificacao'].unique()
if len(sem_nivel):
    print(f'Warning: V2 T3: classificação de orcamento_pessoal.csv sem nível: {", ".join(sem_nivel)}. '
          'Definir no código em que ordem ela sai na tabela', file=sys.stderr)

receita = trata_orcamento_receita('bancos/PPO/orcamento_receita.csv')

classificacao = le_planilha('bancos/manual/desc_classificacao_receita.xlsx').dropna(subset='RECEITA_COD_2')
classificacao = pd.DataFrame({
    'cod_texto': classificacao['RECEITA_COD_2'].astype('int64').astype(str).str.replace(
        r'(.{4})(..)(.)(.)(..)(...)', r'\1.\2.\3.\4.\5.\6', regex=True),
    'receita_desc': corrige_caracteres_especiais(classificacao['RECEITA_DESC_2']),
})

repasse = trata_orcamento_repasse('bancos/PPO/orcamento_repasse.csv')

# Sumário ----------------------------------------------------------------------
sumario = despesa[['poder_cod', 'orgao_cod', 'orgao_nome', 'uo_cod', 'uo_nome', 'uo_sigla']].drop_duplicates()
poderes = le_planilha('bancos/manual/codigosPoder.xlsx').astype({'cod_poder': str})
sumario = sumario.merge(poderes, left_on='poder_cod', right_on='cod_poder', how='left')
sem_poder = sorted(sumario.loc[sumario['poder'].isna(), 'poder_cod'].unique())
if sem_poder:
    print(f'Warning: sumario_v2: O código de poder {", ".join(sem_poder)} não possui correspondência '
          'em codigosPoder.xlsx. Alterar esse banco de codigosPoder.xlsx', file=sys.stderr)
sem_uo = poderes.loc[~poderes['cod_poder'].isin(sumario['poder_cod']), 'poder']
if len(sem_uo):
    print(f'Warning: sumario_v2: O poder {", ".join(sem_uo)} não possui uma UO em '
          'orcamento_despesa.csv. Desconsiderar esse poder do banco.', file=sys.stderr)
sumario = sumario.sort_values(['poder_cod', 'orgao_cod', 'uo_cod'], key=lambda coluna: coluna.astype(int))
for nivel in ['orgao', 'uo']:
    sumario[nivel] = (sumario[f'{nivel}_cod'].str.replace(r'(.)(..)(.)', r'\1.\2.\3', regex=True)
                      + ' - ' + sumario[f'{nivel}_nome'] + ' - ' + sumario['uo_sigla'])
escreve_tabela(sumario[['poder', 'orgao_cod', 'orgao', 'uo_cod', 'uo']], DADOS / 'sumario.txt')

# Tabelas 1 e 2 ----------------------------------------------------------------
for uo_cod, uo in despesa.groupby('uo_cod'):
    gera_tabela1(uo, acoes, set(grupos), DADOS / 'tabela1' / f'{uo_cod}.txt')
    gera_tabela2(uo, fontes, grupos, DADOS / 'tabela2' / f'{uo_cod}.txt')

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
