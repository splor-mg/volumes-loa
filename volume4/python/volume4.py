"""
Gera os dados do volume 4 em volume4/data a partir de datapackages/ppo:
- sumario.txt: UOs com obras, em ordem de poder, órgão e UO
- tabela1/<uo>.txt: OBRAS POR UNIDADE ORÇAMENTÁRIA SEGUNDO AS REGIÕES GEOGRÁFICAS INTERMEDIÁRIAS
- tabela2/<uo>.txt: DETALHAMENTO DOS INVESTIMENTOS POR REGIÕES GEOGRÁFICAS INTERMEDIÁRIAS E MUNICÍPIOS
"""
import pandas as pd
from pathlib import Path

from utils.python.funcoes import escreve_tabela, formatar_num_tabela
from utils.python.trata_bancos import trata_orcamento_obras, trata_planejamento_acao

DADOS = Path('volume4/data')

obras = trata_orcamento_obras('datapackages/ppo/data/orcamento_obras.csv')
acoes = trata_planejamento_acao('datapackages/ppo/data/planejamento_acao.csv')


# Gera o sumário ---------------------------------------------------------------
sumario = obras.drop_duplicates('uo_cod')
sumario = sumario.sort_values(['poder_cod', 'orgao_cod', 'uo_cod'], key=lambda coluna: coluna.astype(int))

sumario['orgao'] = (sumario['orgao_cod'].str.replace(r'(.)(..)(.)', r'\1.\2.\3', regex=True)
                    + ' - ' + sumario['orgao_nome']
                    + ' - ' + sumario['uo_sigla'])

sumario['uo'] = (sumario['uo_cod'].str.replace(r'(.)(..)(.)', r'\1.\2.\3', regex=True)
                 + ' - ' + sumario['uo_nome']
                 + ' - ' + sumario['uo_sigla'])

sumario = sumario.rename(columns={'poder_desc': 'poder'})
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
unidades = acoes.rename(columns={'uo_acao_cod': 'uo_cod'})[chave + ['unidade_medida']]
obras = obras.merge(unidades, on=chave, how='left', suffixes=('', '_acao'))
obras['unidade_medida'] = obras['unidade_medida'].mask(obras['unidade_medida'] == '',
                                                       obras['unidade_medida_acao'])

obras['obra'] = obras['obra_num'].astype(str) + ' - ' + obras['obra_desc']
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

    ordem = ['especificacao', 'cod_admin', 'total', 'regiao_geografica_intermediaria_desc', 'municipio_desc', 'obra']

    tabela = pd.concat([uo.assign(total=0), totais.assign(total=1)])
    tabela = tabela.sort_values(ordem, kind='stable', ignore_index=True)

    for coluna in ['obra_quantidade', 'vlr_tesouro', 'vlr_outros']:
        tabela[coluna] = formatar_num_tabela(tabela[coluna])

    colunas = ['regiao_geografica_intermediaria_desc',
               'municipio_desc',
               'obra',
               'obra_quantidade',
               'unidade_medida',
               'obra_status',
               'especificacao',
               'cod_admin',
               'acao_desc',
               'vlr_tesouro',
               'vlr_outros']

    escreve_tabela(tabela[colunas], DADOS / 'tabela2' / f'{uo_cod}.txt')
