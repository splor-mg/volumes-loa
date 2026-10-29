"""
Relatórios por empresa do volume 3, um arquivo por UO:
- tabela1/: PROGRAMA DE INVESTIMENTO
- tabela2/: ORIGENS DE RECURSOS PARA INVESTIMENTOS
- tabela3/: RECURSOS FINANCEIROS FONTE DE RECURSOS E APLICAÇÃO - INVESTIMENTO
- tabela4/: DETALHAMENTO DOS INVESTIMENTOS
- tabela5/: QUADRO DE DETALHAMENTO DE INVESTIMENTO
"""
import sys
import pandas as pd

from utils.python.funcoes import escreve_tabela, formatar_num

CHAVE = ['funcao_cod', 'subfuncao_cod', 'programa_cod', 'identificador_cod', 'projeto_atividade_cod', 'iag_cod']

# Fontes da tabela 2 na ordem em que aparecem: início do código, nível e especificação
ORIGENS = [('1', 1, 'AUMENTO DE CAPITAL'),
           ('11', 2, 'RECURSOS DO ESTADO'),
           ('111', 3, 'TESOURO ORDINÁRIO'),
           ('11101', 4, 'APLICAÇÃO LIVRE'),
           ('112', 3, 'TESOURO VINCULADO'),
           ('12', 2, 'OUTRAS ENTIDADES'),
           ('121', 3, 'CEMIG'),
           ('122', 3, 'MGI'),
           ('123', 3, 'CODEMIG'),
           ('124', 3, 'BDMG'),
           ('125', 3, 'COPASA'),
           ('129', 3, 'OUTRAS'),
           (('2', '3', '4', '5', '6'), 1, 'OUTROS'),
           ('2', 2, 'OPERAÇÃO DE CRÉDITO'),
           ('21', 3, 'CONTRATADA'),
           ('211', 4, 'CONTRATADA - INTERNA'),
           ('212', 4, 'CONTRATADA - EXTERNA'),
           ('22', 3, 'A CONTRATAR'),
           ('221', 4, 'A CONTRATAR - INTERNA'),
           ('222', 4, 'A CONTRATAR - EXTERNA'),
           ('3', 2, 'ALIENAÇÃO DE BENS E DIREITOS'),
           ('4', 2, 'CONVÊNIOS'),
           ('5', 2, 'RECURSOS PRÓPRIOS'),
           ('6', 2, 'OUTRAS ORIGENS')]


def gera_tabela1(uo, caminho):
    niveis = [(CHAVE[:1], 'funcao_desc'),
              (CHAVE[:2], 'subfuncao_desc'),
              (CHAVE[:3], 'programa_desc'),
              (CHAVE, 'acao_desc')]
    partes = []
    for chave, descricao in niveis:
        soma = uo.groupby(chave + [descricao], as_index=False, dropna=False)['vlr_loa_desp'].sum()
        partes.append(soma.rename(columns={descricao: 'especificacao'}).assign(tipo='acao'))

    planejada = uo[uo['produto_desc'].notna()]
    finalidade = planejada[CHAVE + ['acao_finalidade']].drop_duplicates()
    finalidade = finalidade.rename(columns={'acao_finalidade': 'especificacao'})
    partes.append(finalidade.assign(tipo='finalidade'))

    colunas = CHAVE + ['produto_desc', 'unidade_medida_desc', 'vlr_meta_fisica_ano0']
    produto = planejada[colunas].drop_duplicates()
    produto = produto.rename(columns={'produto_desc': 'especificacao'})
    partes.append(produto.assign(tipo='produto'))

    palavras = produto['unidade_medida_desc'].str.split(' ').explode()
    if (palavras.str.len() > 14).any():
        print(f'Warning: UO {uo["uo_cod"].iloc[0]}: unidade de medida do produto com palavra '
              'de mais de 14 caracteres pode quebrar o layout: '
              f'{", ".join(produto["unidade_medida_desc"].unique())}', file=sys.stderr)

    # Cada ação seguida da finalidade e do produto
    tabela = pd.concat(partes).sort_values(CHAVE + ['tipo'], na_position='first', ignore_index=True)
    programa = tabela['programa_cod'].notna() & tabela['identificador_cod'].isna()
    tabela['vlr_loa_desp'] = tabela['vlr_loa_desp'].mask(programa)
    tabela[CHAVE] = tabela[CHAVE].where(tabela['tipo'] == 'acao')

    total = {'tipo': 'total',
             'especificacao': 'TOTAL GERAL',
             'vlr_loa_desp': uo['vlr_loa_desp'].sum()}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)
    for coluna in CHAVE + ['vlr_loa_desp', 'vlr_meta_fisica_ano0']:
        tabela[coluna] = formatar_num(tabela[coluna])

    colunas = CHAVE + ['tipo', 'especificacao', 'vlr_loa_desp', 'unidade_medida_desc', 'vlr_meta_fisica_ano0']
    escreve_tabela(tabela[colunas], caminho)


def gera_tabela2(uo, caminho):
    linhas = []
    for prefixo, nivel, especificacao in ORIGENS:
        fonte = uo['fonte_invest_cod'].str.startswith(prefixo)
        if fonte.any():
            coluna = 'total' if nivel <= 2 else 'valor'
            linhas.append({'especificacao': especificacao,
                           'nivel': nivel,
                           coluna: uo.loc[fonte, 'vlr_loa_desp'].sum()})
    linhas.append({'especificacao': 'TOTAL', 'nivel': 1, 'total': uo['vlr_loa_desp'].sum()})

    tabela = pd.DataFrame(linhas, columns=['especificacao', 'total', 'nivel', 'valor'])
    for coluna in ['total', 'valor']:
        tabela[coluna] = formatar_num(tabela[coluna])

    escreve_tabela(tabela, caminho)


def gera_tabela3(uo, caminho):
    tabela = uo.groupby(['natureza_invest_desc', 'fonte_invest_desc'])['vlr_loa_desp'].sum()
    tabela = tabela.unstack(0, fill_value=0)

    if len(tabela.columns) > 7:
        print(f'Warning: UO {uo["uo_cod"].iloc[0]}: {len(tabela.columns)} naturezas na tabela 3, '
              'que foi testada com no máximo 7. Verificar se houve quebra no layout!',
              file=sys.stderr)

    tabela.loc['TOTAL'] = tabela.sum()
    tabela['total'] = tabela.sum(axis=1)

    escreve_tabela(tabela.apply(formatar_num).reset_index(), caminho)


def gera_tabela4(uo, caminho):
    # Cada categoria, pelo código, seguida das suas naturezas, pelo nome
    categoria = uo.groupby(['categoria_invest_cod', 'categoria_invest_desc'], as_index=False)
    categoria = categoria['vlr_loa_desp'].sum()
    categoria.columns = ['categoria_invest_cod', 'especificacao', 'total']

    natureza = uo.groupby(['categoria_invest_cod', 'natureza_invest_desc'], as_index=False)
    natureza = natureza['vlr_loa_desp'].sum()
    natureza.columns = ['categoria_invest_cod', 'especificacao', 'valor']

    tabela = pd.concat([categoria.assign(nivel=1), natureza.assign(nivel=2)])
    tabela = tabela.sort_values(['categoria_invest_cod', 'nivel', 'especificacao'])

    total = {'especificacao': 'TOTAL', 'total': uo['vlr_loa_desp'].sum(), 'nivel': 1}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)
    for coluna in ['total', 'valor']:
        tabela[coluna] = formatar_num(tabela[coluna])

    escreve_tabela(tabela[['especificacao', 'total', 'valor', 'nivel']], caminho)


def gera_tabela5(uo, caminho):
    acao = uo.groupby(CHAVE + ['acao_desc'], as_index=False)['vlr_loa_desp'].sum()
    natureza = uo.groupby(CHAVE + ['natureza_invest_desc'], as_index=False)['vlr_loa_desp'].sum()
    fonte = uo.groupby(CHAVE + ['natureza_invest_desc', 'fonte_invest_desc'], as_index=False)
    fonte = fonte['vlr_loa_desp'].sum().rename(columns={'vlr_loa_desp': 'valor'})

    tabela = pd.concat([acao, natureza, fonte]).rename(columns={'vlr_loa_desp': 'total'})
    tabela = tabela.sort_values(CHAVE + ['natureza_invest_desc', 'fonte_invest_desc'],
                                na_position='first', ignore_index=True)
    tabela[CHAVE] = tabela[CHAVE].where(tabela['acao_desc'].notna())
    natureza = tabela['natureza_invest_desc']
    tabela['natureza_invest_desc'] = natureza.where(tabela['fonte_invest_desc'].isna())

    total = {'acao_desc': 'TOTAL', 'total': uo['vlr_loa_desp'].sum()}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)
    for coluna in CHAVE + ['valor', 'total']:
        tabela[coluna] = formatar_num(tabela[coluna])

    colunas = CHAVE + ['acao_desc', 'natureza_invest_desc', 'fonte_invest_desc', 'valor', 'total']
    escreve_tabela(tabela[colunas], caminho)
