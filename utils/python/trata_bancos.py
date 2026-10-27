"""
Leitura dos bancos usados na geração dos volumes.
"""
import sys
import pandas as pd


def le_planilha(caminho):
    """
    Lê a primeira aba e tira os espaços das pontas dos textos.
    """
    planilha = pd.ExcelFile(caminho)
    if len(planilha.sheet_names) > 1:
        print(
            f'  Aviso: o banco {caminho} possui mais de 1 aba. '
            f'A aba que será aberta é a {planilha.sheet_names[0]}',
            file=sys.stderr,
        )
        
    return planilha.parse(0).map(lambda valor: valor.strip() if isinstance(valor, str) else valor)


def trata_orcamento_despesa_fonte_80_95(caminho):
    """
    Função para abrir o banco orcamento_despesa_fonte_80_95.csv, usado no volume 7
    """
    qdd = pd.read_csv(caminho, dtype=str)
    qdd = qdd.map(lambda valor: valor.strip() if isinstance(valor, str) else valor)

    qdd['vlr_loa_desp'] = qdd['vlr_loa_desp'].str.replace(',', '.').astype(float)

    for coluna, largura in [('funcao_cod', 2), ('subfuncao_cod', 3), ('elemento_cod', 2)]:
        qdd[coluna] = qdd[coluna].str.zfill(largura)

    qdd = qdd.sort_values('fonte_cod', kind='stable')

    valores = qdd['vlr_loa_desp']
    for descricao, linhas in [('negativos', valores < 0), ('iguais a zero', valores == 0)]:
        if linhas.any():
            numeros = ', '.join(str(i + 2) for i in qdd.index[linhas])
            print(
                f'orcamento_despesa: há valores {descricao} nas linhas {numeros}',
                file=sys.stderr,
            )

    qdd['codigo_numerico'] = (
        qdd['categoria_cod']
        + qdd['grupo_cod']
        + qdd['modalidade_cod']
        + qdd['elemento_cod']
    )

    qdd['sequencial_iniciativa'] = qdd.groupby(
        ['orgao_cod', 'uo_cod', 'funcao_cod', 'subfuncao_cod', 'programa_cod', 'acao_cod'],
        sort=False,
    )['especificacao'].transform(lambda nomes: nomes.ne(nomes.shift()).cumsum())

    qdd['codigo_acao'] = (
        qdd['sequencial_iniciativa'].astype(str)
        + qdd['funcao_cod']
        + qdd['subfuncao_cod']
        + qdd['programa_cod']
        + qdd['identificador_cod']
        + qdd['projeto_atividade_cod']
        + qdd['subprojeto_cod']
    )

    qdd['cod_detalhe'] = (
        qdd['codigo_acao']
        + qdd['codigo_numerico']
        + qdd['iag_cod']
        + qdd['fonte_cod']
        + qdd['ipu_cod']
    )

    return qdd
