"""
Gera os dados do volume 7 em volume7/data a partir de bancos/SISOR/BASE_QDD_FISCAL_FONTE_95.xlsx:
- consolidado.txt: DEMONSTRATIVO CONSOLIDADO DA DESPESA
- QUADRO_DETALHAMENTO_DESPESA_porUO.txt: QUADRO DE DETALHAMENTO DA DESPESA - FISCAL
"""
import sys
import pandas as pd

from utils.python.formata_texto import corrige_caracteres_especiais
from utils.python.funcoes import escreve_tabela, formatar_num, texto_r
from utils.python.trata_bancos import le_planilha, trata_qdd_fiscal_fonte_95

CHAVE_UO = ['ANO', 'COD_ORGAO', 'ORGAO', 'COD_UO', 'UO']
CHAVE_ACAO = ['FUNCAO', 'SUB_FUNCAO', 'PROGRAMA', 'IDENT_PROJATIV', 'PROJ_ATIV', 'SUB_PROJETO']
CHAVE_ELEMENTO = ['CATEGORIA', 'GRUPO_DESPESA', 'MODALIDADE', 'ELEMENTO_DESPESA', 'IAG', 'FONTE', 'IPU']


def gera_consolidado(banco):
    tesouro = banco['FONTE'].isin([10, 11, 12, 15])
    valores = pd.DataFrame({
        'codigo_numerico': banco['codigo_numerico'],
        'recurso_tesouro': banco['valor'].where(tesouro, 0),
        'outras_fontes': banco['valor'].where(~tesouro, 0),
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
            'Warning: Os códigos de despesa em BASE_QDD_FISCAL.xlsx não possuem correspondência em '
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
    escreve_tabela(consolidado[colunas], 'volume7/data/consolidado.txt')


def gera_quadro(banco):
    # Cada valor entra na linha do elemento, na linha da ação e no total da UO
    elementos = banco.copy()
    elementos[['NOME_ACAO'] + CHAVE_ACAO] = float('nan')
    acoes = banco.assign(cod_detalhe=banco['codigo_acao'] + '0000000000')
    acoes[CHAVE_ELEMENTO] = float('nan')
    totais = banco.assign(cod_detalhe='Z99999999999999990000000000', NOME_ACAO='Total')
    totais[CHAVE_ACAO + CHAVE_ELEMENTO + ['SEQUENCIAL_INICIATIVA']] = float('nan')

    colunas = CHAVE_UO + ['NOME_ACAO'] + CHAVE_ACAO + CHAVE_ELEMENTO + ['SEQUENCIAL_INICIATIVA']
    quadro = pd.concat([elementos, acoes, totais]).groupby(
        colunas + ['PODER', 'cod_detalhe'], sort=False, dropna=False, as_index=False
    )['valor'].sum()

    poderes = le_planilha('bancos/manual/codigosPoder.xlsx')
    quadro = quadro.merge(poderes, left_on='PODER', right_on='cod_poder', how='left', indicator=True)
    sem_poder = sorted(quadro.loc[quadro['_merge'] == 'left_only', 'PODER'].unique())
    if sem_poder:
        codigos = '\n'.join(map(texto_r, sem_poder))
        print(
            'Warning: Há um código de Poder que aparece no banco, que não está presente no banco de apoio codigosPoder.xlsx. '
            f'Trata-se de {codigos} . Alterar em codigosPoder.xlsx \n',
            file=sys.stderr,
        )
    quadro['merge'] = quadro['_merge'].map({'both': 'Em ambos os bancos', 'left_only': 'Apenas no Banco X'})

    quadro = quadro.sort_values(['PODER', 'COD_ORGAO', 'COD_UO', 'cod_detalhe'], kind='stable')
    quadro = quadro[quadro['valor'] > 0].copy()
    quadro['valor'] = formatar_num(quadro['valor'])
    for coluna in ['NOME_ACAO', 'ORGAO', 'UO', 'poder']:
        quadro[coluna] = corrige_caracteres_especiais(quadro[coluna])

    colunas_poder = [coluna for coluna in poderes.columns if coluna != 'cod_poder']
    colunas = colunas + ['valor'] + colunas_poder + ['merge']
    escreve_tabela(quadro[colunas], 'volume7/data/QUADRO_DETALHAMENTO_DESPESA_porUO.txt')


banco = trata_qdd_fiscal_fonte_95('bancos/SISOR/BASE_QDD_FISCAL_FONTE_95.xlsx')

# Gera o consolidado
gera_consolidado(banco)

# Gera o QDD
gera_quadro(banco)
