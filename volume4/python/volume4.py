"""
Gera os dados do volume 4 em volume4/data a partir de bancos/PPO:
- sumario.txt: UOs com obras, em ordem de poder, órgão e UO
- tabela1/<uo>.txt: OBRAS POR UNIDADE ORÇAMENTÁRIA SEGUNDO AS REGIÕES GEOGRÁFICAS INTERMEDIÁRIAS
- tabela2/<uo>.txt: DETALHAMENTO DOS INVESTIMENTOS POR REGIÕES GEOGRÁFICAS INTERMEDIÁRIAS E MUNICÍPIOS
"""
import sys
import pandas as pd
from pathlib import Path

from utils.python.funcoes import escreve_tabela, formatar_num_tabela
from utils.python.trata_bancos import (le_planilha, trata_orcamento_despesa, trata_orcamento_despesa_investimento,
                                       trata_orcamento_obras, trata_planejamento_acao)

DADOS = Path('volume4/data')

obras = trata_orcamento_obras('bancos/PPO/orcamento_obras.csv')
acoes = trata_planejamento_acao('bancos/PPO/planejamento_acao.csv')
investimento = trata_orcamento_despesa_investimento('bancos/PPO/orcamento_despesa_investimento.csv')
despesa = trata_orcamento_despesa('bancos/PPO/orcamento_despesa.csv')


# Gera o sumário ---------------------------------------------------------------
colunas = ['poder_cod', 'orgao_cod', 'orgao_nome', 'uo_cod', 'uo_nome', 'uo_sigla']
sumario = pd.concat([investimento[colunas], despesa[colunas]]).drop_duplicates()

poderes = le_planilha('bancos/manual/codigosPoder.xlsx').astype({'cod_poder': str})
sumario = sumario.merge(poderes, left_on='poder_cod', right_on='cod_poder', how='left')
sumario = sumario.sort_values(['poder_cod', 'orgao_cod', 'uo_cod'], key=lambda coluna: coluna.astype(int))

sem_sumario = sorted(set(obras['uo_cod']) - set(sumario['uo_cod']))
if sem_sumario:
    print('Warning: Há códigos de UO em orcamento_obras.csv que não estão em '
          'orcamento_despesa_investimento.csv nem em orcamento_despesa.csv: '
          f'{", ".join(sem_sumario)}', file=sys.stderr)

sumario = sumario[sumario['uo_cod'].isin(obras['uo_cod'])]

sumario['orgao'] = (sumario['orgao_cod'].str.replace(r'(.)(..)(.)', r'\1.\2.\3', regex=True)
                    + ' - ' + sumario['orgao_nome']
                    + ' - ' + sumario['uo_sigla'])

sumario['uo'] = (sumario['uo_cod'].str.replace(r'(.)(..)(.)', r'\1.\2.\3', regex=True)
                 + ' - ' + sumario['uo_nome']
                 + ' - ' + sumario['uo_sigla'])

escreve_tabela(sumario[['poder', 'orgao_cod', 'orgao', 'uo_cod', 'uo']], DADOS / 'sumario.txt')

# Gera a tabela 1 --------------------------------------------------------------
for uo_cod in sumario['uo_cod']:
    uo = obras[obras['uo_cod'] == uo_cod]

    territorios = (uo['vlr_tesouro'] + uo['vlr_outros']).groupby(
        uo['regiao_geografica_intermediaria_desc']).sum()
    territorios = territorios.sort_index(key=lambda nomes: (
        nomes.str.normalize('NFKD').str.encode('ascii', 'ignore').str.decode('ascii')),
        kind='stable')

    total = territorios.sum()
    tabela = pd.DataFrame({'territorio': territorios.index, 'valor': territorios.to_numpy()})
    if total > 0:
        tabela['porcentagem'] = ((tabela['valor'] * 100 / total).round(2)
                                 .map(lambda porcentagem: f'{porcentagem:g}'.replace('.', ',')))
    else:
        tabela['porcentagem'] = '-'

    tabela.loc[len(tabela)] = ['TOTAL', total, '100']
    tabela['valor'] = formatar_num_tabela(tabela['valor'])

    escreve_tabela(tabela, DADOS / 'tabela1' / f'{uo_cod}.txt')

# Gera a tabela 2 --------------------------------------------------------------
chave = ['uo_cod', 'funcao_cod', 'subfuncao_cod', 'programa_cod', 'acao_cod', 'iag_cod']

unidades = acoes.rename(columns={'uo_acao_cod': 'uo_cod'})
unidades = unidades[chave + ['unidade_medida_desc']]

obras = obras.merge(unidades, on=chave, how='left', suffixes=('', '_acao'))
sem_unidade = obras['unidade_medida_desc'] == ''
obras.loc[sem_unidade, 'unidade_medida_desc'] = obras.loc[sem_unidade, 'unidade_medida_desc_acao']

titulos = acoes.drop_duplicates('acao_cod').set_index('acao_cod')['acao_desc']
obras['nome_acao'] = obras['acao_cod'].map(titulos)

for acao_cod in sorted(obras.loc[obras['nome_acao'].isna(), 'acao_cod'].unique()):
    print(f'Warning: O código da ação {acao_cod} não foi encontrado em planejamento_acao.csv',
          file=sys.stderr)

obras['obra'] = obras['obra_numero'].astype(str) + ' - ' + obras['obra_desc']
obras['especificacao'] = (obras['funcao_cod']
                          + '  ' + obras['subfuncao_cod']
                          + ' ' + obras['programa_cod']
                          + ' ' + obras['acao_cod'].str[0]
                          + ' ' + obras['acao_cod'].str[1:4])
obras['cod_admin'] = obras['subprojeto_cod'].astype(int)

for uo_cod in sumario['uo_cod']:
    uo = obras[obras['uo_cod'] == uo_cod]

    totais = uo.groupby(['especificacao', 'cod_admin'], as_index=False)
    totais = totais[['vlr_tesouro', 'vlr_outros']].sum().assign(obra='TOTAL')

    ordem = ['especificacao', 'cod_admin', 'total', 'regiao_geografica_intermediaria_desc',
             'municipio_desc', 'obra']

    tabela = pd.concat([uo.assign(total=0), totais.assign(total=1)])
    tabela = tabela.sort_values(ordem, kind='stable', ignore_index=True)

    for coluna in ['obra_quantidade', 'vlr_tesouro', 'vlr_outros']:
        tabela[coluna] = formatar_num_tabela(tabela[coluna])

    colunas = ['regiao_geografica_intermediaria_desc',
               'municipio_desc',
               'obra',
               'obra_quantidade',
               'unidade_medida_desc',
               'obra_status',
               'especificacao',
               'cod_admin',
               'nome_acao',
               'vlr_tesouro',
               'vlr_outros']

    escreve_tabela(tabela[colunas], DADOS / 'tabela2' / f'{uo_cod}.txt')
