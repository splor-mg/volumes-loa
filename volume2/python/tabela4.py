"""
Tabela 4: DEMONSTRATIVO DOS RECURSOS FINANCEIROS
"""
import sys
import pandas as pd

from utils.python.funcoes import escreve_tabela, formatar_num_tabela

NIVEIS = ['categoria_cod', 'origem_cod', 'especie_cod', 'rubrica_cod', 'alinea_cod', 'subalinea_cod', 'receita_tipo_cod', 'item_cod']
VALORES = ['valor_desdobramento', 'valor_especie', 'valor_categoria']


def gera_tabela4(receita, classificacao, caminho):
    # UO sem receita própria: a tabela sai zerada, porque a UO tem a tabela 5
    if receita.empty:
        tabela = pd.DataFrame({'cod_texto': '', 'fonte_cod': '', 'receita_desc': ['', 'SUBTOTAL 1'],
                               'valor_desdobramento': '0', 'valor_especie': '0', 'valor_categoria': '0'})
        escreve_tabela(tabela, caminho)
        return

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
        print(f'Warning: V2 T4: UO {receita["uo_cod"].iloc[0]}: código de receita sem descrição em '
              f'desc_classificacao_receita.xlsx: {list(detalhes)}', file=sys.stderr)
    tabela = tabela[~sem_descricao]
    if tabela.duplicated(['cod_texto', 'fonte_cod', 'receita_desc']).any():
        print(f'Warning: V2 T4: UO {receita["uo_cod"].iloc[0]}: código repetido, a especificação sai '
              'duplicada na tabela', file=sys.stderr)

    total = {'receita_desc': 'SUBTOTAL 1', 'valor_categoria': receita['vlr_loa_rec'].sum()}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)
    tabela[VALORES] = tabela[VALORES].apply(formatar_num_tabela)

    escreve_tabela(tabela[['cod_texto', 'fonte_cod', 'receita_desc'] + VALORES], caminho)
