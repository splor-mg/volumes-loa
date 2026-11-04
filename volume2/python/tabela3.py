"""
Tabela 3: DETALHAMENTO DA CATEGORIA DE PESSOAL
funfip.txt: DETALHAMENTO DE PESSOAL INATIVO CIVIL
"""
import sys
import pandas as pd
from pathlib import Path

from utils.python.formata_texto import corrige_caracteres_especiais
from utils.python.funcoes import escreve_tabela, formatar_num_tabela
from utils.python.trata_bancos import le_planilha

ACOES_INATIVOS = [7006, 7007]
UOS_MILITARES = ['1251', '1401']
UOS_DESCONSIDERAR = ['1111', '1461', '2391', '2401', '2451', '9207']
FUNFIP = '4711'
ACOES_DESCONSIDERAR_FUNFIP = [7008, 7016, 7023]


def gera_tabela3(pessoal, despesa, com_inativos, caminho):
    uo_cod = pessoal['uo_cod'].iloc[0]
    aviso = f'Warning: V2 T3: UO {uo_cod}: '

    # Os inativos das UOs sem ação de inativos entram na tabela do FUNFIP
    if not com_inativos:
        pessoal = pessoal[~pessoal['pessoal_classificacao'].str.contains('INATIVO')]
    elif uo_cod in UOS_MILITARES:
        pessoal = pessoal[pessoal['pessoal_categoria'] != 'INATIVO CIVIL']

    classificacao = pessoal.groupby(['pessoal_classificacao', 'nivel'], as_index=False)['pessoal_quantidade']
    classificacao = classificacao.sum().rename(columns={'pessoal_quantidade': 'total'})
    categoria = pessoal.groupby(['pessoal_classificacao', 'pessoal_categoria'], as_index=False)
    tabela = categoria['pessoal_quantidade'].sum().merge(classificacao, how='outer')
    total_geral = classificacao['total'].sum()
    total = {'pessoal_classificacao': 'TOTAL', 'nivel': 99, 'total': total_geral}

    # Valor de pessoal ativo e, se houver ação e servidores inativos, de pessoal inativo
    inativos = classificacao['pessoal_classificacao'].str.contains('INATIVO').any()
    acao_inativos = despesa['acao_cod'].isin(ACOES_INATIVOS)
    if acao_inativos.any() != inativos:
        print(aviso + f'{"há" if inativos else "não há"} servidores inativos, mas '
              f'{"não há" if inativos else "há"} valores nas ações 7006 e 7007', file=sys.stderr)
    valor = {'PESSOAL ATIVO': despesa.loc[~acao_inativos, 'vlr_loa_desp'].sum()}
    sem_ativos = classificacao['pessoal_classificacao'].str.contains('INATIVO').all()
    if valor['PESSOAL ATIVO'] and sem_ativos and uo_cod != FUNFIP:
        print(aviso + 'há valores para pessoal ativo, mas não há servidores ativos em '
              'orcamento_pessoal.csv', file=sys.stderr)
    if acao_inativos.any() and inativos:
        valor['PESSOAL INATIVO'] = despesa.loc[acao_inativos, 'vlr_loa_desp'].sum()
    valor = pd.DataFrame({'pessoal_classificacao': list(valor), 'vlr_loa_desp': list(valor.values())})
    valor['participacao'] = (valor['vlr_loa_desp'] / valor['vlr_loa_desp'].sum() * 100).round(2)
    valor.loc[2] = ['TOTAL', valor['vlr_loa_desp'].sum(), valor['participacao'].sum()]

    tabela = pd.concat([tabela, pd.DataFrame([total])]).merge(valor, how='outer')
    tabela['perc_total_pessoal'] = (tabela['total'] / total_geral * 100).round(1)
    tabela['perc_categoria_pessoal'] = (tabela['pessoal_quantidade'] / total_geral * 100).round(1)
    tabela = tabela.sort_values(['nivel', 'pessoal_categoria'], kind='stable', ignore_index=True)

    # Os valores da classificação ficam só na primeira linha
    colunas = ['pessoal_classificacao', 'total', 'vlr_loa_desp', 'perc_total_pessoal', 'participacao']
    repete = tabela['pessoal_classificacao'] == tabela['pessoal_classificacao'].shift()
    tabela[colunas] = tabela[colunas].mask(repete, axis=0)

    if despesa.empty:
        print(aviso + 'sem nome da UO e do órgão em orcamento_despesa.csv', file=sys.stderr)

    for coluna in ['pessoal_quantidade', 'total', 'vlr_loa_desp']:
        tabela[coluna] = formatar_num_tabela(tabela[coluna])
    for coluna in ['perc_total_pessoal', 'perc_categoria_pessoal', 'participacao']:
        tabela[coluna] = tabela[coluna].map(lambda valor: '' if pd.isna(valor)
                                            else f'{valor:.15g}'.replace('.', ','))

    escreve_tabela(tabela.drop(columns='nivel'), caminho)


def gera_funfip(despesa, pessoal, sumario, caminho):
    aviso = 'Warning: V2 T3 FUNFIP: '

    # Valores das ações do FUNFIP, com a UO de cada ação em FFP_acoes.xlsx
    funfip = despesa[(despesa['uo_cod'] == FUNFIP)
                     & (despesa['grupo_cod'] == 1)
                     & (despesa['ipu_cod'] != 9)
                     & ~despesa['acao_cod'].isin(ACOES_DESCONSIDERAR_FUNFIP)]
    valores = funfip.groupby(['acao_cod', 'especificacao'], as_index=False)['vlr_loa_desp'].sum()
    acoes = le_planilha('bancos/manual/FFP_acoes.xlsx').astype({'COD_UO': str})
    valores = valores.merge(acoes.rename(columns={'COD_UO': 'uo_cod', 'ACAO': 'acao_cod'}),
                            how='outer', indicator=True)

    novas = valores[valores['_merge'] == 'left_only']
    if len(novas):
        print(aviso + f'ações sem correspondência em FFP_acoes.xlsx: {list(novas["acao_cod"])}. '
              'Atualizar FFP_acoes.xlsx com bancos/manual/novasAcoes_FUNFIP.csv e depois apagar esse '
              'arquivo', file=sys.stderr)
        novas = novas[['acao_cod', 'especificacao', 'uo_cod']]
        novas = novas.set_axis(['ACAO', 'DESCRITIVO_ACAO', 'COD_UO'], axis=1)
        novas.to_csv('bancos/manual/novasAcoes_FUNFIP.csv', sep=';', index=False)
    sem_valor = valores.loc[valores['_merge'] == 'right_only', 'acao_cod']
    if len(sem_valor):
        print(aviso + f'ações de FFP_acoes.xlsx sem valor em orcamento_despesa.csv: {list(sem_valor)}',
              file=sys.stderr)
    ambos = valores[valores['_merge'] == 'both']
    for atual, esperado in ambos.loc[ambos['especificacao'] != corrige_caracteres_especiais(
            ambos['DESCRITIVO_ACAO']), ['especificacao', 'DESCRITIVO_ACAO']].to_numpy():
        print(aviso + f'nome da ação diferente em FFP_acoes.xlsx: {atual} ---- {esperado}', file=sys.stderr)

    # Inativos civis das UOs que não pagam os inativos na própria folha
    folha = set(despesa.loc[despesa['acao_cod'].isin(ACOES_INATIVOS), 'uo_cod']) - set(UOS_MILITARES)
    pessoal = pessoal[pessoal['pessoal_categoria'].str.contains('INATIVO CIVIL')
                      & ~pessoal['uo_cod'].isin(folha | set(UOS_DESCONSIDERAR))]
    pessoal = pessoal.groupby('uo_cod', as_index=False)['pessoal_quantidade'].sum()
    ausentes = Path('bancos/manual/PESSOAL_INATIVO_AUSENTE_SISOR.xlsx')
    if ausentes.exists():
        ausentes = le_planilha(ausentes).astype({'cod_uo': str})
        pessoal = pd.concat([pessoal, ausentes.set_axis(['uo_cod', 'pessoal_quantidade'], axis=1)])

    tabela = pessoal.merge(valores[['uo_cod', 'vlr_loa_desp']], how='outer', indicator=True)
    sem_valor = tabela.loc[tabela['_merge'] == 'left_only', 'uo_cod']
    if len(sem_valor):
        print(aviso + f'UOs sem valores nas ações do FUNFIP: {list(sem_valor)}', file=sys.stderr)
    sem_pessoal = tabela.loc[(tabela['_merge'] == 'right_only') & (tabela['vlr_loa_desp'] > 1000), 'uo_cod']
    if len(sem_pessoal):
        print(aviso + f'UOs sem quantidade de inativos e com mais de R$ 1.000 nas ações do FUNFIP: '
              f'{list(sem_pessoal)}. Se preciso, criar bancos/manual/PESSOAL_INATIVO_AUSENTE_SISOR.xlsx, '
              'com as colunas cod_uo e quantidade', file=sys.stderr)

    # R$ 1.000 sem quantidade é só a abertura de uma conta: a quantidade fica "-"
    abertura = tabela['pessoal_quantidade'].isna() & (tabela['vlr_loa_desp'] == 1000)
    tabela.loc[abertura, 'pessoal_quantidade'] = 0
    total = {'poder': 'TOTAL',
             'quantidade_poder': tabela['pessoal_quantidade'].sum(),
             'valor_poder': tabela['vlr_loa_desp'].sum()}

    # O Fundo Estadual de Saúde entra como a Secretaria de Saúde
    tabela = tabela.drop(columns='_merge').merge(sumario[['uo_cod', 'uo', 'poder']], how='left')
    if (tabela['uo_cod'] == '4291').any():
        print(aviso + '4291 FUNDO ESTADUAL DE SAÚDE (UO) será considerado como 1.32.0 - SECRETARIA DE '
              'ESTADO DE SAÚDE - SES (Órgão)', file=sys.stderr)
        tabela.loc[tabela['uo_cod'] == '4291', ['uo_cod', 'uo']] = ['1320', float('nan')]
        tabela.loc[tabela['uo_cod'] == '1320', 'poder'] = 'PODER EXECUTIVO'

    antigas = le_planilha('bancos/manual/Nome_UO_antigas.xlsx').astype({'cod_uo': str})
    antigas = tabela['uo_cod'].map(antigas.set_index('cod_uo')['nome'])
    tabela['uo'] = tabela['uo'].fillna(corrige_caracteres_especiais(
        tabela['uo_cod'].str.replace(r'(.)(..)(.)', r'\1.\2.\3', regex=True) + ' - ' + antigas))
    if tabela['uo'].isna().any():
        print(aviso + f'UO {list(tabela.loc[tabela["uo"].isna(), "uo_cod"])} sem nome em '
              'orcamento_despesa.csv e em Nome_UO_antigas.xlsx', file=sys.stderr)
        tabela['uo'] = tabela['uo'].fillna(tabela['uo_cod'] + ' - NA')

    # Poder Executivo separado em administração direta e indireta
    valores = ['pessoal_quantidade', 'vlr_loa_desp']
    tabela['poder'] = tabela['poder'].where(tabela['poder'] == 'PODER EXECUTIVO', 'OUTROS PODERES')
    poderes = tabela.groupby('poder')[valores].sum()
    executivo = tabela[tabela['poder'] == 'PODER EXECUTIVO']
    administracao = executivo['uo'].str.contains(r'1\.\d{2}\.\d.+').map({True: '1000', False: '2000'})
    administracao = executivo.groupby(administracao)[valores].sum().rename_axis('uo_cod').reset_index()
    administracao['uo'] = administracao['uo_cod'].map({'1000': 'ADMINISTRAÇÃO DIRETA',
                                                       '2000': 'ADMINISTRAÇÃO INDIRETA'})
    tabela = pd.concat([tabela, administracao.assign(poder='PODER EXECUTIVO')])
    tabela = tabela.sort_values(['poder', 'uo_cod'], ascending=[False, True], ignore_index=True)

    # Poder e total do poder só na primeira linha do poder
    primeira = ~tabela['poder'].duplicated()
    tabela['quantidade_poder'] = tabela['poder'].map(poderes['pessoal_quantidade']).where(primeira)
    tabela['valor_poder'] = tabela['poder'].map(poderes['vlr_loa_desp']).where(primeira)
    tabela['poder'] = tabela['poder'].where(primeira)
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)

    zero = tabela['pessoal_quantidade'] == 0
    for coluna in valores + ['quantidade_poder', 'valor_poder']:
        tabela[coluna] = formatar_num_tabela(tabela[coluna])
    tabela.loc[zero, 'pessoal_quantidade'] = '-'

    escreve_tabela(tabela[['poder', 'quantidade_poder', 'valor_poder', 'uo'] + valores], caminho)
