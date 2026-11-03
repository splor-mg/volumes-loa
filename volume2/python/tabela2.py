"""
Tabela 2: FONTE DE RECURSOS E GRUPOS DE DESPESA - FISCAL
"""
import sys
import pandas as pd

from utils.python.formata_texto import corrige_caracteres_especiais
from utils.python.funcoes import escreve_tabela, formatar_num


def gera_tabela2(uo, fontes, grupos, caminho):
    fonte = uo.groupby(['fonte_cod', 'iag_cod', 'ipu_cod', 'grupo_cod'])['vlr_loa_desp'].sum()
    fonte = fonte.unstack(fill_value=0)
    fonte.columns = [grupos.get(grupo, grupo) for grupo in fonte.columns]
    valores = fonte.columns.tolist() + ['total']
    fonte['total'] = fonte.sum(axis=1)
    fonte = fonte.reset_index()

    # Total geral e total de cada fonte
    total = fonte.sum().to_dict() | {'fonte_desc': 'TOTAL'}
    fonte = pd.concat([fonte, fonte.groupby('fonte_cod', as_index=False).sum().assign(iag_cod=99)])

    fonte['fonte_desc'] = corrige_caracteres_especiais(fonte['fonte_cod'].astype(str) + ' - '
                                                       + fonte['fonte_cod'].map(fontes))
    if fonte['fonte_desc'].isna().any():
        print('Warning: V2 T2: fonte sem descrição em desc_fontes_de_recursos.xlsx: '
              f'{set(fonte.loc[fonte["fonte_desc"].isna(), "fonte_cod"])}', file=sys.stderr)
    fonte = fonte.dropna(subset='fonte_desc').sort_values(['fonte_desc', 'iag_cod', 'ipu_cod'],
                                                          kind='stable', ignore_index=True)

    # Células mescladas de fonte e de IAG: o número de linhas fica só na primeira
    fonte['celulas_mesclar_fonte'] = fonte.groupby('fonte_desc')['fonte_desc'].transform('size')
    fonte['celulas_mesclar_iag'] = fonte.groupby(['fonte_desc', 'iag_cod'])['iag_cod'].transform('size')
    for coluna, celulas in [('fonte_desc', 'celulas_mesclar_fonte'), ('iag_cod', 'celulas_mesclar_iag')]:
        repete = fonte[coluna] == fonte[coluna].shift()
        fonte[[coluna, celulas]] = fonte[[coluna, celulas]].mask(repete, axis=0)

    fonte = pd.concat([fonte, pd.DataFrame([total])], ignore_index=True)
    fonte['celulas_mesclar_iag'] = fonte['celulas_mesclar_iag'].where(fonte['celulas_mesclar_iag'] != 1)

    colunas = ['celulas_mesclar_fonte', 'celulas_mesclar_iag', 'iag_cod', 'ipu_cod'] + valores
    fonte[colunas] = fonte[colunas].apply(formatar_num)
    fonte['iag_cod'] = fonte['iag_cod'].replace('99', 'Total')

    escreve_tabela(fonte[['fonte_desc'] + colunas], caminho)
