"""
Leitura dos bancos do SISOR, equivalente a utils/trataBancos/trataQDD_Fiscal.R.
"""
import sys
import unicodedata
import pandas as pd

from utils.python.funcoes import formata_c, texto_r

COLUNAS_QDD_FISCAL = [
    'ANO', 'COD_ORGAO', 'ORGAO', 'PODER', 'COD_UO', 'UO', 'CATEGORIA', 'GRUPO_DESPESA', 'MODALIDADE',
    'ELEMENTO_DESPESA', 'FONTE', 'IPU', 'SEQ_PROGTRAB', 'FUNCAO', 'SUB_FUNCAO', 'PROGRAMA', 'IDENT_PROJATIV',
    'PROJ_ATIV', 'ACAO', 'SUB_PROJETO', 'valor', 'IAG', 'NOME_ACAO', 'NOME_PROGRAMA',
]


def sem_acento(texto):
    return unicodedata.normalize('NFKD', texto).encode('ascii', 'ignore').decode()


def le_planilha(caminho):
    # Lê a primeira aba e tira os espaços das pontas dos textos
    planilha = pd.ExcelFile(caminho)
    if len(planilha.sheet_names) > 1:
        print(f'  Aviso: o banco {caminho} possui mais de 1 aba. A aba que será aberta é a {planilha.sheet_names[0]}',
              file=sys.stderr)
    return planilha.parse(0).map(lambda valor: valor.strip() if isinstance(valor, str) else valor)


def trata_qdd_fiscal(caminho):
    # Função para abir o banco BASE_QDD_FISCAL.xlsx
    qdd = le_planilha(caminho).rename(columns={'VALOR FINAL (R$)': 'valor'})
    qdd.columns = [sem_acento(nome) for nome in qdd.columns]

    faltantes = [nome for nome in COLUNAS_QDD_FISCAL if nome not in qdd.columns]
    if faltantes:
        print(f'BASE_QDD_FISCAL: os seguintes campos não estão no banco atual: {", ".join(faltantes)}',
              file=sys.stderr)

    for descricao, linhas in [('negativos', qdd['valor'] < 0), ('iguais a zero', qdd['valor'] == 0)]:
        if linhas.any():
            print(f'BASE_QDD_FISCAL: há valores {descricao} nas linhas {", ".join(str(i + 2) for i in qdd.index[linhas])}',
                  file=sys.stderr)
    return qdd


def trata_qdd_fiscal_fonte_95(caminho):
    # Função para abrir o banco BASE_QDD_FISCAL_FONTE_95.xlsx, usado no volume 7
    qdd = trata_qdd_fiscal(caminho)

    qdd['codigo_numerico'] = (
        qdd['CATEGORIA'].map(texto_r)
        + qdd['GRUPO_DESPESA'].map(texto_r)
        + qdd['MODALIDADE'].map(texto_r)
        + formata_c(qdd['ELEMENTO_DESPESA'], 2)
    )
    
    qdd['NOME_ACAO'] = qdd['ESPECIFICACAO']

    qdd['SEQUENCIAL_INICIATIVA'] = qdd.groupby(
        ['COD_ORGAO', 'COD_UO', 'FUNCAO', 'SUB_FUNCAO', 'PROGRAMA', 'ACAO'], sort=False, dropna=False
    )['NOME_ACAO'].transform(lambda nomes: nomes.fillna('').ne(nomes.fillna('').shift()).cumsum())

    qdd['codigo_acao'] = (
        qdd['SEQUENCIAL_INICIATIVA'].map(texto_r)
        + formata_c(qdd['FUNCAO'], 2)
        + formata_c(qdd['SUB_FUNCAO'], 3)
        + qdd['PROGRAMA'].map(texto_r)
        + qdd['IDENT_PROJATIV'].map(texto_r)
        + formata_c(qdd['PROJ_ATIV'], 3)
        + formata_c(qdd['SUB_PROJETO'], 4)
    )

    qdd['cod_detalhe'] = (
        qdd['codigo_acao']
        + qdd['codigo_numerico']
        + qdd['IAG'].map(texto_r)
        + qdd['FONTE'].map(texto_r)
        + qdd['IPU'].map(texto_r)
    )

    return qdd
