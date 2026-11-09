"""
Quadro da receita por categoria, origem, espécie, rubrica, alínea, subalínea, tipo,
item e subitem com a fonte, usado na tabela 4 do volume 2 e nas tabelas 7 e 9 do volume 1.
"""
import sys
import pandas as pd

NIVEIS = ['categoria_cod', 'origem_cod', 'especie_cod', 'rubrica_cod', 'alinea_cod', 'subalinea_cod', 'receita_tipo_cod', 'item_cod']
VALORES = ['valor_desdobramento', 'valor_especie', 'valor_categoria']


def gera_quadro_receita(receita, classificacao, aviso):
    # Um nível de agregação por vez, até o subitem com a fonte.
    niveis = [NIVEIS[:nivel] for nivel in range(1, 9)] + [NIVEIS + ['subitem_cod', 'fonte_cod']]
    tabela = pd.concat([receita.groupby(nivel, as_index=False)['vlr_loa_rec'].sum() for nivel in niveis])
    tabela['cod_texto'] = tabela[NIVEIS + ['subitem_cod']].fillna(0).astype(int).apply(
        lambda codigos: '{}{}{}{}.{:02}.{}.{}.{:02}.{:03}'.format(*codigos), axis=1)
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
