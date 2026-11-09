"""
Tabelas do volume 1 a partir de orcamento_despesa.csv:
- T4: DEMONSTRATIVO DA DESPESA POR UNIDADE ORÇAMENTÁRIA SEGUNDO OS GRUPOS DE DESPESA
- T5: DEMONSTRATIVO CONSOLIDADO DA CATEGORIA DE PESSOAL POR UNIDADE ORÇAMENTÁRIA
- T13: DEMONSTRATIVO CONSOLIDADO DA DESPESA
- T14: DEMONSTRATIVO DA DESPESA POR FUNÇÃO, SUBFUNÇÃO E PROGRAMA CONFORME O VÍNCULO COM OS RECURSOS
- T15: PROGRAMA DE TRABALHO DO GOVERNO
- T17: DEMONSTRATIVO DA APLICAÇÃO DE RECURSOS EM PROGRAMAS DE SAÚDE E INVESTIMENTO EM TRANSPORTE
- T23: DEMONSTRATIVO DO SERVIÇO DA DÍVIDA PÚBLICA
- T28D: DESPESA PREVISTA NA LOA DOS PROGRAMAS FINANCIADOS COM RECURSOS DA UNIÃO
"""
import sys
import unicodedata
import pandas as pd

from utils.python.funcoes import escreve_tabela, formatar_num, formatar_num_contabil

GRUPOS = {1: 'pessoal', 2: 'juros', 3: 'outras', 4: 'investimentos', 5: 'inversoes', 6: 'amort', 9: 'reserva'}
CATEGORIAS = {3: 'DESPESAS CORRENTES', 4: 'DESPESAS DE CAPITAL', 9: 'RESERVA DE CONTIGÊNCIA'}
NIVEIS = ['funcao_cod', 'subfuncao_cod', 'programa_cod']

# Parâmetros do T14
REC_ORDINARIOS = [10, 11, 12, 15, 18, 19]
REC_DIRETAMENTE_ARRECADADOS = [60, 61]

# Parâmetros do T23
ACOES_DIVIDA_INTERNA = [7886, 7030, 7043, 7658, 7003]
ACOES_DIVIDA_EXTERNA = [7896]

# Parâmetros do T28, também em volume1/R/tabela28_comum.R
FONTES_UNIAO = [1, 2, 3, 4, 5, 6, 7, 8, 16, 17, 21, 22, 24, 36, 37, 38, 56, 57,
                62, 63, 64, 65, 73, 84, 85, 86, 87, 88, 92, 93, 97, 98]
FONTES_EXCLUIR = [22, 84, 85, 86, 87, 88]
FONTES_RELATORIO = [str(fonte) for fonte in FONTES_UNIAO if fonte not in FONTES_EXCLUIR]
FONTES_CONSIDERADAS = ', '.join(FONTES_RELATORIO[:-1]) + ' e ' + FONTES_RELATORIO[-1]


def sem_acento(texto):
    return unicodedata.normalize('NFKD', texto).encode('ascii', 'ignore').decode()


def gera_t4(despesa, grupos, caminho):
    sem_grupo = sorted(set(despesa['grupo_cod']) - set(grupos))
    if sem_grupo:
        print('Warning: T4_DEMONSTRATIVO_DESPESA_POR_ORGAOS_ENTIDADES_SEGUNDO_GRUPOS_DESPESA: Há códigos '
              'de grupo de despesa em orcamento_despesa.csv que não possuem uma correspondência em '
              f'desc_grupos_de_despesa.xlsx. Os codigos são {", ".join(map(str, sem_grupo))}',
              file=sys.stderr)

    tabela = despesa[despesa['grupo_cod'].isin(grupos)]
    tabela = tabela.groupby(['uo_cod', 'uo_nome', 'uo_sigla', 'grupo_cod'])['vlr_loa_desp'].sum()
    tabela = tabela.unstack(fill_value=0).reindex(columns=list(GRUPOS), fill_value=0)
    tabela = tabela.rename(columns=GRUPOS).reset_index().sort_values(['uo_nome', 'uo_sigla'], kind='stable')
    tabela['total'] = tabela[list(GRUPOS.values())].sum(axis=1)

    total = tabela[list(GRUPOS.values()) + ['total']].sum().to_dict() | {'uo_nome': 'TOTAL'}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)
    colunas = list(GRUPOS.values()) + ['total']
    tabela[colunas] = tabela[colunas].apply(formatar_num)

    escreve_tabela(tabela[['uo_nome', 'uo_sigla'] + colunas], caminho)


def gera_t5(despesa, pessoal, caminho):
    # Terceirizado sempre zerado, como no R
    classificacoes = {'PESSOAL ATIVO': 'ativo', 'PESSOAL INATIVO': 'inativo'}
    tabela = pessoal[pessoal['pessoal_classificacao'].isin(classificacoes)]
    tabela = tabela.groupby(['uo_cod', 'pessoal_classificacao'])['pessoal_quantidade'].sum()
    tabela = tabela.unstack(fill_value=0).reindex(columns=list(classificacoes), fill_value=0)
    tabela = tabela.rename(columns=classificacoes).assign(terceirizado=0)

    uos = despesa[['uo_cod', 'uo_nome', 'uo_sigla']].drop_duplicates()
    tabela = uos.merge(tabela, left_on='uo_cod', right_index=True)

    if (tabela['uo_cod'] == '4291').any():
        print('Warning: V1_Tabela5_DEMONSTRATIVO_CONSOLIDADO_CATEGORIA_PESSOAL: 4291 FUNDO ESTADUAL DE SAÚDE '
              '(UO) será considerado como 1.32.0 - SECRETARIA DE ESTADO DE SAÚDE - SES (Órgão)',
              file=sys.stderr)
        tabela.loc[tabela['uo_cod'] == '4291', ['uo_nome', 'uo_sigla']] = ['SECRETARIA DE ESTADO DE SAÚDE', 'SES']

    tabela = tabela.sort_values(['uo_nome', 'uo_sigla'], kind='stable')
    colunas = ['ativo', 'inativo', 'terceirizado']
    tabela['total'] = tabela[colunas].sum(axis=1)

    # O total geral fica vazio, como no R
    total = tabela[colunas].sum().to_dict() | {'uo_nome': 'TOTAL'}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)
    tabela[colunas + ['total']] = tabela[colunas + ['total']].apply(formatar_num)

    escreve_tabela(tabela[['uo_nome', 'uo_sigla'] + colunas + ['total']], caminho)


def gera_t13(despesa, grupos, caminho):
    base = despesa[despesa['modalidade_cod'] != 91].assign(recurso='outras')
    base.loc[base['fonte_cod'].isin([10, 11, 12, 15, 19]), 'recurso'] = 'tesouro'
    descricoes = {codigo: sem_acento(texto).upper() for codigo, texto in grupos.items()}

    categoria = base.groupby(['categoria_cod', 'recurso'], as_index=False)['vlr_loa_desp'].sum()
    categoria['ordem'] = categoria['categoria_cod'] * 10
    categoria['espec'] = categoria['categoria_cod'].map(CATEGORIAS).fillna('IGN')

    grupo = base.groupby(['categoria_cod', 'grupo_cod', 'recurso'], as_index=False)['vlr_loa_desp'].sum()
    grupo['ordem'] = (grupo['categoria_cod'].astype(str) + grupo['grupo_cod'].astype(str)).astype(int)
    grupo['espec'] = grupo['grupo_cod'].map(descricoes)

    total = base.groupby('recurso', as_index=False)['vlr_loa_desp'].sum().assign(ordem=100, espec='TOTAL')

    tabela = pd.concat([categoria, grupo, total])
    tabela = tabela.pivot_table(index=['ordem', 'espec'], columns='recurso', values='vlr_loa_desp',
                                aggfunc='sum', fill_value=0)
    tabela = tabela.reindex(columns=['tesouro', 'outras'], fill_value=0).reset_index()
    tabela = tabela[tabela['ordem'] != 99]
    tabela['total'] = tabela['outras'] + tabela['tesouro']
    for coluna in ['tesouro', 'outras', 'total']:
        tabela[coluna] = formatar_num_contabil(tabela[coluna])

    escreve_tabela(tabela[['ordem', 'espec', 'tesouro', 'outras', 'total']], caminho)


def soma_niveis(despesa, funcoes, subfuncoes, coluna, nome):
    """Soma por função, subfunção e programa, com os valores abertos pelas categorias de coluna"""
    for codigo, descricoes, arquivo in [('funcao_cod', funcoes, 'desc_funcao.xlsx'),
                                         ('subfuncao_cod', subfuncoes, 'desc_subfuncao.xlsx')]:
        sem_descricao = sorted(set(despesa[codigo]) - set(descricoes))
        if sem_descricao:
            print(f'Warning: {nome}: Há códigos de {codigo} em orcamento_despesa.csv que não possuem '
                  f'uma correspondência em {arquivo}. Os codigos são {", ".join(map(str, sem_descricao))}',
                  file=sys.stderr)

    funcao = despesa.groupby(['funcao_cod', coluna], as_index=False)['vlr_loa_desp'].sum()
    funcao['especificacao'] = funcao['funcao_cod'].map(funcoes)

    subfuncao = despesa.groupby(NIVEIS[:2] + [coluna], as_index=False)['vlr_loa_desp'].sum()
    subfuncao['especificacao'] = subfuncao['subfuncao_cod'].map(subfuncoes)

    programa = despesa.groupby(NIVEIS + ['programa_desc', coluna], as_index=False)['vlr_loa_desp'].sum()
    programa = programa.rename(columns={'programa_desc': 'especificacao'})

    tabela = pd.concat([funcao.dropna(subset='especificacao'), subfuncao.dropna(subset='especificacao'),
                        programa])
    tabela[NIVEIS] = tabela[NIVEIS].fillna(0)
    tabela = tabela.pivot_table(index=NIVEIS + ['especificacao'], columns=coluna, values='vlr_loa_desp',
                                aggfunc='sum', fill_value=0)
    return tabela.reset_index()


def finaliza_niveis(tabela, colunas, caminho):
    tabela['total'] = tabela[colunas].sum(axis=1)
    funcao = (tabela['subfuncao_cod'] == 0) & (tabela['programa_cod'] == 0)
    total = tabela.loc[funcao, colunas + ['total']].sum().to_dict()
    total |= {'funcao_cod': 100, 'subfuncao_cod': 0, 'programa_cod': 0, 'especificacao': 'TOTAL'}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)
    tabela = tabela.sort_values(NIVEIS, kind='stable')

    tabela[NIVEIS[1:]] = tabela[NIVEIS[1:]].where(tabela[NIVEIS[1:]] != 0)
    tabela[colunas + ['total']] = tabela[colunas + ['total']].apply(formatar_num)

    escreve_tabela(tabela[NIVEIS + ['especificacao'] + colunas + ['total']], caminho)


def gera_t14(despesa, funcoes, subfuncoes, caminho):
    base = despesa.assign(recurso='vinculados')
    base.loc[base['fonte_cod'].isin(REC_ORDINARIOS), 'recurso'] = 'ordinarios'
    base.loc[base['fonte_cod'].isin(REC_DIRETAMENTE_ARRECADADOS), 'recurso'] = 'arrecadados'

    colunas = ['ordinarios', 'vinculados', 'arrecadados']
    tabela = soma_niveis(base, funcoes, subfuncoes, 'recurso',
                         'T14_DEMONSTRATIVO_DESPESA_FUNCAO_SUBFUNCAO_PROGRAMA_CONFORME_VINCULO_COM_RECURSOS')
    finaliza_niveis(tabela.reindex(columns=NIVEIS + ['especificacao'] + colunas, fill_value=0),
                    colunas, caminho)


def gera_t15(despesa, funcoes, subfuncoes, grupos, caminho):
    sem_grupo = sorted(set(despesa['grupo_cod']) - set(grupos))
    if sem_grupo:
        print('Warning: T15_PROGRAMA_TRABALHO_GOVERNO: Há códigos de grupo de despesa em '
              'orcamento_despesa.csv que não possuem uma correspondência em desc_grupos_de_despesa.xlsx. '
              f'Os codigos são {", ".join(map(str, sem_grupo))}', file=sys.stderr)

    base = despesa[despesa['grupo_cod'].isin(grupos)].assign(grupo=lambda base: base['grupo_cod'].map(GRUPOS))
    colunas = list(GRUPOS.values())
    tabela = soma_niveis(base, funcoes, subfuncoes, 'grupo', 'T15_PROGRAMA_TRABALHO_GOVERNO')
    finaliza_niveis(tabela.reindex(columns=NIVEIS + ['especificacao'] + colunas, fill_value=0),
                    colunas, caminho)


def gera_t17(despesa, caminho):
    saude = despesa[despesa['funcao_cod'] == 10]
    saude = saude.groupby(saude['uo_cod'] + '.10').agg(
        uo_nome=('uo_nome', 'first'), uo_sigla=('uo_sigla', 'first'), valor=('vlr_loa_desp', 'sum'))

    transporte = despesa[(despesa['funcao_cod'] == 26) & despesa['grupo_cod'].isin([4, 5])]
    transporte = transporte.groupby(transporte['uo_cod'] + '.26').agg(
        uo_nome=('uo_nome', 'first'), uo_sigla=('uo_sigla', 'first'), valor=('vlr_loa_desp', 'sum'))

    parte_a = pd.DataFrame([{'espec': 'A. PROGRAMA DE SAÚDE', 'valor': saude['valor'].sum()}])
    parte_b = pd.DataFrame([{'espec': 'B. INVESTIMENTO EM TRANSPORTES E SISTEMA VIÁRIO',
                             'valor': transporte['valor'].sum()}])
    tabela = pd.concat([parte_a, saude.sort_index().reset_index(names='cod'),
                        parte_b, transporte.sort_index().reset_index(names='cod')], ignore_index=True)
    tabela['valor'] = formatar_num(tabela['valor'])

    aplicacao = round(parte_a['valor'].iloc[0] / parte_b['valor'].iloc[0], 2)
    parte_c = {'espec': 'C - APLICAÇÃO DOS RECURSOS EM PROGRAMAS DE SAÚDE EM RELAÇÃO AOS INVESTIMENTOS EM '
                        'TRANSPORTE E SISTEMA VIÁRIO (A/B)',
               'valor': format(aplicacao, ',.7g').replace(',', '_').replace('.', ',').replace('_', '.')}
    tabela = pd.concat([tabela, pd.DataFrame([parte_c])], ignore_index=True)

    escreve_tabela(tabela[['cod', 'espec', 'uo_nome', 'uo_sigla', 'valor']], caminho)


def gera_t23(despesa, caminho):
    linhas = []
    for espec, acoes in [('INTERNA', ACOES_DIVIDA_INTERNA), ('EXTERNA', ACOES_DIVIDA_EXTERNA)]:
        divida = despesa[despesa['acao_cod'].isin(acoes)]
        linhas.append({'espec': espec,
                       'principal': divida.loc[divida['grupo_cod'] == 6, 'vlr_loa_desp'].sum(),
                       'acessorio': divida.loc[divida['grupo_cod'] == 2, 'vlr_loa_desp'].sum()})
    tabela = pd.DataFrame(linhas)
    tabela.loc[len(tabela)] = ['TOTAL', tabela['principal'].sum(), tabela['acessorio'].sum()]
    tabela['total'] = tabela['principal'] + tabela['acessorio']
    tabela[['principal', 'acessorio', 'total']] = tabela[['principal', 'acessorio', 'total']].apply(formatar_num)

    escreve_tabela(tabela, caminho)


def gera_t28d(despesa, receita, caminho):
    # Sigla da UO vem da receita e o nome do programa fica sem acento, como no R
    tabela = despesa[despesa['fonte_cod'].isin(FONTES_UNIAO)]
    tabela = tabela.groupby(['uo_cod', 'programa_cod'], as_index=False)['vlr_loa_desp'].sum()
    siglas = receita[['uo_cod', 'uo_sigla']].drop_duplicates()
    programas = despesa[['uo_cod', 'programa_cod', 'programa_desc']].drop_duplicates()
    programas['programa_desc'] = programas['programa_desc'].map(sem_acento)
    tabela = tabela.merge(siglas, how='left').merge(programas, how='left')
    tabela = tabela.sort_values(['uo_cod', 'programa_cod'], key=lambda coluna: coluna.astype(int), kind='stable')

    total = {'uo_sigla': 'TOTAL', 'programa_desc': 'TOTAL', 'vlr_loa_desp': tabela['vlr_loa_desp'].sum()}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)
    tabela['vlr_loa_desp'] = formatar_num(tabela['vlr_loa_desp'])

    tabela['fonte_exec'] = ''
    tabela.loc[0, 'fonte_exec'] = FONTES_CONSIDERADAS

    escreve_tabela(tabela[['uo_cod', 'programa_cod', 'programa_desc', 'uo_sigla', 'vlr_loa_desp', 'fonte_exec']],
                   caminho)
