"""
Quadro da receita por categoria, origem, espécie, rubrica, alínea, subalínea, tipo,
item e subitem com a fonte, usado na tabela 4 do volume 2 e nas tabelas 7 e 9 do volume 1.
"""
import sys
import pandas as pd

NIVEIS = [1, 2, 3, 4, 6, 7, 8, 10] # categoria, origem, espécie, rubrica, alínea, subalínea, tipo e item
VALORES = ['valor_desdobramento', 'valor_especie', 'valor_categoria']


def gera_quadro_receita(receita, classificacao, aviso):
    # Um nível de agregação por vez, até o subitem com a fonte.
    codigo = receita['receita_cod']
    partes = [receita.groupby(codigo.str[:nivel].str.ljust(13, '0'))['vlr_loa_rec']
              .sum().reset_index() for nivel in NIVEIS]
    partes.append(receita.groupby(['receita_cod', 'fonte_cod'], as_index=False)['vlr_loa_rec'].sum())
    tabela = pd.concat(partes)
    tabela['cod_texto'] = tabela['receita_cod'].str.replace(
        r'(.{4})(..)(.)(.)(..)(...)', r'\1.\2.\3.\4.\5.\6', regex=True)
    tabela = tabela.sort_values(['cod_texto', 'fonte_cod'], kind='stable', ignore_index=True)
    repetido = (tabela['cod_texto'] == tabela['cod_texto'].shift()) & tabela['fonte_cod'].isna()

    categoria = tabela['cod_texto'].str.contains(r'\d{1,2}0{2,3}\.00\.0\.0\.00\.000')
    especie = tabela['cod_texto'].str.contains(r'\d{3}0\.00\.0\.0\.00\.000') & ~categoria
    valor = tabela['vlr_loa_rec'].where(tabela['vlr_loa_rec'] != 0)
    tabela['valor_categoria'] = valor.where(categoria)
    tabela['valor_especie'] = valor.where(especie)
    tabela['valor_desdobramento'] = valor.where(~categoria & ~especie)

    tabela = tabela[~repetido].merge(classificacao, how='left')
    sem_descricao = tabela['receita_desc'].isna()
    detalhes = tabela.loc[sem_descricao & tabela['fonte_cod'].notna(), 'cod_texto']
    if len(detalhes):
        print(aviso + 'código de receita sem descrição em desc_classificacao_receita.xlsx: '
              f'{list(detalhes)}', file=sys.stderr)
    tabela = tabela[~sem_descricao]
    if tabela.duplicated(['cod_texto', 'fonte_cod', 'receita_desc']).any():
        print(aviso + 'código repetido, a especificação sai duplicada na tabela', file=sys.stderr)

    return tabela[['cod_texto', 'fonte_cod', 'receita_desc'] + VALORES]
