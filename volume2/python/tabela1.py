"""
Tabela 1: PROGRAMA DE TRABALHO
"""
import sys
import pandas as pd

from utils.python.funcoes import escreve_tabela, formatar_num_tabela

CHAVE = ['funcao_cod', 'subfuncao_cod', 'programa_cod', 'identificador_cod', 'projeto_atividade_cod', 'subprojeto_cod']
CHAVE_IPU = CHAVE + ['modalidade_cod', 'iag_cod', 'fonte_cod', 'ipu_cod']
GRUPOS = {1: 'pessoal', 2: 'juros', 3: 'outras', 4: 'investimentos', 5: 'inversoes', 6: 'amortizacao'}
VALORES = list(GRUPOS.values()) + ['vlr_loa_desp']


def gera_tabela1(uo, acoes, grupos, caminho):
    aviso = f'Warning: V2 T1: UO {uo["uo_cod"].iloc[0]}: '
    acoes_uo = acoes[acoes['uo_acao_cod'] == uo['uo_cod'].iloc[0]]
    partes = []

    for nivel, coluna in [(1, 'funcao_desc'), (2, 'subfuncao_desc')]:
        codigo = CHAVE[nivel - 1]
        soma = uo.groupby(CHAVE[:nivel], as_index=False)['vlr_loa_desp'].sum()
        soma['especificacao'] = soma[codigo].map(acoes.drop_duplicates(codigo).set_index(codigo)[coluna])
        sem_descricao = soma.loc[soma['especificacao'].isna(), codigo]
        if len(sem_descricao):
            print(aviso + f'{codigo} sem descrição em planejamento_acao.csv: '
                  f'{", ".join(map(str, sem_descricao))}', file=sys.stderr)
        partes.append(soma.assign(tipo=1))

    programa = uo.groupby(CHAVE[:3] + ['programa_desc'], as_index=False)['vlr_loa_desp'].sum()
    partes.append(programa.rename(columns={'programa_desc': 'especificacao'}).assign(tipo=1))

    # Finalidade só quando a ação da UO tem exatamente um registro em planejamento_acao.csv.
    finalidade = uo.groupby(CHAVE[:5] + ['especificacao'], as_index=False)['vlr_loa_desp'].sum()
    textos = finalidade.join(acoes_uo.groupby(CHAVE[:5])['acao_finalidade'].agg(list), on=CHAVE[:5])
    unica = textos['acao_finalidade'].str.len() == 1
    for acao in textos[~unica].to_dict('records'):
        print(aviso + f'ação {acao["identificador_cod"]}{acao["projeto_atividade_cod"]:03} sem finalidade '
              f'ou com mais de uma: {acao["acao_finalidade"]}', file=sys.stderr)
    finalidade['especificacao'] = textos['acao_finalidade'].str[0].where(unica)
    partes.append(finalidade.assign(tipo=5))

    subprojeto = uo.groupby(CHAVE + ['especificacao'], as_index=False)['vlr_loa_desp'].sum()
    partes.append(subprojeto.assign(tipo=1))

    # Modalidade, IAG, fonte e IPU, com um grupo de despesa por coluna
    sem_grupo = set(uo['grupo_cod']) - grupos
    if sem_grupo:
        print(aviso + f'grupo de despesa sem descrição em desc_grupos_de_despesa.xlsx: {sem_grupo}',
              file=sys.stderr)
    ipu = uo[uo['grupo_cod'].isin(grupos)].groupby(CHAVE_IPU + ['grupo_cod'])['vlr_loa_desp'].sum()
    ipu = ipu.unstack()
    ipu['vlr_loa_desp'] = ipu.sum(axis=1)
    ipu = ipu.rename(columns=GRUPOS).reset_index()
    partes.append(ipu.assign(tipo=7))

    # Produto logo depois das linhas de IPU de cada subprojeto e IAG
    produto = ipu.groupby(CHAVE + ['iag_cod'], as_index=False)['modalidade_cod'].max()
    produto['modalidade_cod'] += 1
    colunas = CHAVE[:5] + ['iag_cod', 'produto_desc', 'unidade_medida_desc', 'vlr_meta_fisica_ano0',
                           'identificador_desc', 'acao_exclusao']
    produto = produto.merge(acoes_uo[colunas], how='outer', indicator=True)
    for acao in produto[produto['_merge'] == 'left_only'].to_dict('records'):
        print(aviso + f'ação {acao["identificador_cod"]}{acao["projeto_atividade_cod"]:03} sem produto em '
              'planejamento_acao.csv', file=sys.stderr)
    sobra = ((produto['_merge'] == 'right_only')
             & (produto['identificador_desc'] != 'NÃO ORÇAMENTÁRIO')
             & (produto['acao_exclusao'] != 'SIM'))
    for acao in produto[sobra].to_dict('records'):
        print(aviso + f'produto da ação {acao["identificador_cod"]}{acao["projeto_atividade_cod"]:03} sem '
              'correspondência em orcamento_despesa.csv', file=sys.stderr)
    produto = produto[produto['_merge'] == 'both'].rename(columns={'produto_desc': 'especificacao'})
    palavras = produto['unidade_medida_desc'].str.split(' ').explode()
    if (palavras.str.len() > 13).any():
        print(aviso + 'unidade de medida do produto com palavra de mais de 13 caracteres pode quebrar o '
              f'layout: {", ".join(palavras[palavras.str.len() > 13])}', file=sys.stderr)
    partes.append(produto.assign(tipo=8))

    colunas = CHAVE_IPU + ['tipo', 'especificacao'] + VALORES + ['unidade_medida_desc',
                                                                 'vlr_meta_fisica_ano0']
    tabela = pd.concat(partes).reindex(columns=colunas)
    tabela = tabela.sort_values(CHAVE_IPU, na_position='first', kind='stable', ignore_index=True)
    tabela['especificacao'] = tabela['especificacao'].str.replace('["¿]', '', regex=True)

    total = tabela[VALORES].sum()
    total['vlr_loa_desp'] = uo['vlr_loa_desp'].sum()
    total = total.where(total != 0).to_dict() | {'tipo': 9, 'especificacao': 'TOTAL'}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True).drop_duplicates()

    for coluna, largura in zip(CHAVE, [2, 3, 3, 1, 3, 4]):
        tabela[coluna] = tabela[coluna].map(lambda codigo: '' if pd.isna(codigo)
                                            else f'{codigo:0{largura}.0f}')
    for coluna in VALORES + ['vlr_meta_fisica_ano0']:
        tabela[coluna] = formatar_num_tabela(tabela[coluna])

    escreve_tabela(tabela, caminho)
