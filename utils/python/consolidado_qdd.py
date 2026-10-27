"""
Gera os dados do consolidado e do QDD dos volumes 5 e 7 a partir do banco de despesa tratado.
"""
import sys
import pandas as pd

from utils.python.formata_texto import corrige_caracteres_especiais
from utils.python.funcoes import escreve_tabela, formatar_num
from utils.python.trata_bancos import le_planilha

CHAVE_UO = ['ano', 'poder_cod', 'orgao_cod', 'orgao_nome', 'uo_cod', 'uo_nome', 'uo_sigla']
CHAVE_ACAO = ['funcao_cod', 'subfuncao_cod', 'programa_cod', 'identificador_cod', 'projeto_atividade_cod', 'subprojeto_cod']
CHAVE_ELEMENTO = ['categoria_cod', 'grupo_cod', 'modalidade_cod', 'elemento_cod', 'iag_cod', 'fonte_cod', 'ipu_cod']


def gera_consolidado(banco, caminho):
    tesouro = banco['fonte_cod'].isin(['10', '11', '12', '15'])
    valores = pd.DataFrame({
        'codigo_numerico': banco['codigo_numerico'],
        'recurso_tesouro': banco['vlr_loa_desp'].where(tesouro, 0),
        'outras_fontes': banco['vlr_loa_desp'].where(~tesouro, 0),
    })

    agregados = valores[valores['codigo_numerico'].str[0] != '9']
    consolidado = pd.concat([
        valores,
        agregados.assign(codigo_numerico=agregados['codigo_numerico'].str[:2] + '0000'),
        agregados.assign(codigo_numerico=agregados['codigo_numerico'].str[:1] + '00000'),
    ]).groupby('codigo_numerico', as_index=False).sum()
    codigo = consolidado['codigo_numerico']
    consolidado['codigo_texto'] = codigo.str[0] + '.' + codigo.str[1] + '.' + codigo.str[2:4] + '.' + codigo.str[4:6]

    classificacao = le_planilha('bancos/manual/desc_classificacao_economica_despesa.xlsx')
    descricoes = dict(zip(classificacao['codigo'].str.replace(r'\s', '.', regex=True), classificacao['especificacao']))
    consolidado['especificacao'] = consolidado['codigo_texto'].map(descricoes)
    sem_descricao = consolidado.loc[consolidado['especificacao'].isna(), 'codigo_texto']
    if len(sem_descricao):
        print(
            'Warning: Os códigos de despesa não possuem correspondência em '
            f'desc_classificacao_economica_despesa.xlsx: {", ".join(sem_descricao)}',
            file=sys.stderr,
        )

    total = {
        'codigo_texto': 'TOTAL',
        'recurso_tesouro': valores['recurso_tesouro'].sum(),
        'outras_fontes': valores['outras_fontes'].sum(),
    }
    consolidado = pd.concat([consolidado, pd.DataFrame([total])], ignore_index=True)
    consolidado['total'] = consolidado['recurso_tesouro'] + consolidado['outras_fontes']
    for coluna in ['recurso_tesouro', 'outras_fontes', 'total']:
        consolidado[coluna] = formatar_num(consolidado[coluna])
    consolidado['especificacao'] = corrige_caracteres_especiais(consolidado['especificacao'])

    colunas = ['codigo_texto', 'especificacao', 'recurso_tesouro', 'outras_fontes', 'total']
    escreve_tabela(consolidado[colunas], caminho)


def gera_qdd(banco, caminho, chave_extra):
    # Cada valor entra na linha do elemento, na linha da ação e no total da UO
    elementos = banco.copy()
    elementos[['especificacao'] + CHAVE_ACAO] = float('nan')
    acoes = banco.assign(cod_detalhe=banco['codigo_acao'] + '0000000000')
    acoes[CHAVE_ELEMENTO] = float('nan')
    totais = banco.assign(cod_detalhe='Z99999999999999990000000000', especificacao='TOTAL')
    totais[CHAVE_ACAO + CHAVE_ELEMENTO + chave_extra] = float('nan')

    colunas = CHAVE_UO + ['especificacao'] + CHAVE_ACAO + CHAVE_ELEMENTO + chave_extra
    quadro = pd.concat([elementos, acoes, totais]).groupby(
        colunas + ['cod_detalhe'], sort=False, dropna=False, as_index=False
    )['vlr_loa_desp'].sum()

    poderes = le_planilha('bancos/manual/codigosPoder.xlsx').astype({'cod_poder': str})
    quadro = quadro.merge(poderes, left_on='poder_cod', right_on='cod_poder', how='left')
    sem_poder = sorted(quadro.loc[quadro['poder'].isna(), 'poder_cod'].unique())
    if sem_poder:
        print(
            'Warning: Há um código de Poder que não está presente em codigosPoder.xlsx. '
            f'Trata-se de {", ".join(sem_poder)} . Alterar em codigosPoder.xlsx \n',
            file=sys.stderr,
        )

    quadro = quadro.sort_values(['poder_cod', 'orgao_cod', 'uo_cod', 'cod_detalhe'], kind='stable')
    quadro = quadro[quadro['vlr_loa_desp'] > 0].copy()
    quadro['vlr_loa_desp'] = formatar_num(quadro['vlr_loa_desp'])
    for coluna in ['especificacao', 'orgao_nome', 'uo_nome', 'uo_sigla', 'poder']:
        quadro[coluna] = corrige_caracteres_especiais(quadro[coluna])

    colunas = colunas + ['vlr_loa_desp', 'poder']
    escreve_tabela(quadro[colunas], caminho)
