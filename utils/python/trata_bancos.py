"""
Leitura dos bancos usados na geração dos volumes.
"""
import sys
import pandas as pd

from utils.python.formata_texto import corrige_caracteres_especiais


def le_planilha(caminho):
    """
    Lê a primeira aba e tira os espaços das pontas dos textos.
    """
    planilha = pd.ExcelFile(caminho)
    if len(planilha.sheet_names) > 1:
        print(f'Warning: o banco {caminho} possui mais de 1 aba. '
              f'A aba que será aberta é a {planilha.sheet_names[0]}',
              file=sys.stderr)

    return planilha.parse(0).map(lambda valor: valor.strip() if isinstance(valor, str) else valor)


def avisa_valores(banco, descricao, linhas):
    if linhas.any():
        numeros = ', '.join(str(i + 2) for i in linhas.index[linhas])
        print(f'{banco}: há valores {descricao} nas linhas {numeros}', file=sys.stderr)


def trata_orcamento_despesa_fonte_80_95(caminho):
    """
    Função para abrir o banco orcamento_despesa_fonte_80_95.csv, usado no volume 7.
    """
    qdd = pd.read_csv(caminho, dtype=str)
    qdd = qdd.map(lambda valor: valor.strip() if isinstance(valor, str) else valor)
    qdd = qdd.apply(corrige_caracteres_especiais)

    qdd['vlr_loa_desp'] = qdd['vlr_loa_desp'].str.replace(',', '.').astype(float)

    for coluna, largura in [('funcao_cod', 2), ('subfuncao_cod', 3), ('elemento_cod', 2)]:
        qdd[coluna] = qdd[coluna].str.zfill(largura)

    qdd = qdd.sort_values('fonte_cod', kind='stable')

    valores = qdd['vlr_loa_desp']
    avisa_valores('orcamento_despesa_fonte_80_95', 'negativos', valores < 0)
    avisa_valores('orcamento_despesa_fonte_80_95', 'iguais a zero', valores == 0)

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


def trata_orcamento_despesa(caminho):
    """
    Função para abrir o banco orcamento_despesa.csv, usado no volume 5.
    """
    qdd = pd.read_csv(caminho, dtype=str).rename(columns={'acao_desc': 'especificacao'})
    qdd = qdd.map(lambda valor: valor.strip() if isinstance(valor, str) else valor)
    qdd = qdd.apply(corrige_caracteres_especiais)

    qdd['vlr_loa_desp'] = qdd['vlr_loa_desp'].str.replace(',', '.').astype(float)

    for coluna, largura in [('funcao_cod', 2), ('subfuncao_cod', 3), ('elemento_cod', 2)]:
        qdd[coluna] = qdd[coluna].str.zfill(largura)

    valores = qdd['vlr_loa_desp']
    avisa_valores('orcamento_despesa', 'negativos', valores < 0)
    avisa_valores('orcamento_despesa', 'iguais a zero', valores == 0)

    qdd['codigo_numerico'] = (
        qdd['categoria_cod']
        + qdd['grupo_cod']
        + qdd['modalidade_cod']
        + qdd['elemento_cod']
    )

    qdd['codigo_acao'] = (
        qdd['funcao_cod']
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


def trata_orcamento_despesa_investimento(caminho):
    """
    Função para abrir o banco orcamento_despesa_investimento.csv, usado nos volumes 3 e 4.
    """
    qdd = pd.read_csv(caminho, dtype=str, keep_default_na=False)
    qdd = qdd.map(lambda valor: valor.strip() if isinstance(valor, str) else valor)
    qdd = qdd.apply(corrige_caracteres_especiais)

    qdd['vlr_loa_desp'] = qdd['vlr_loa_desp'].str.replace(',', '.').astype(float)

    valores = qdd['vlr_loa_desp']
    avisa_valores('orcamento_despesa_investimento', 'negativos', valores < 0)
    avisa_valores('orcamento_despesa_investimento', 'iguais a zero', valores == 0)

    return qdd


def trata_orcamento_obras(caminho):
    """
    Função para abrir o banco orcamento_obras.csv, usado no volume 4.
    """
    obras = pd.read_csv(caminho, dtype=str, keep_default_na=False)
    obras = obras.map(lambda valor: valor.strip() if isinstance(valor, str) else valor)
    obras = obras.apply(corrige_caracteres_especiais)

    obras['obra_desc'] = obras['obra_desc'].str.replace(r'\r?\n', ' ', regex=True)
    obras['obra_quantidade'] = pd.to_numeric(obras['obra_quantidade'])
    for coluna in ['vlr_tesouro', 'vlr_outros']:
        obras[coluna] = obras[coluna].str.replace(',', '.').astype(float)

    for coluna, largura in [('funcao_cod', 2), ('subfuncao_cod', 3), ('programa_cod', 3)]:
        obras[coluna] = obras[coluna].str.zfill(largura)

    obras['obra_numero'] = range(1, len(obras) + 1)

    avisa_valores('orcamento_obras', 'negativos em vlr_tesouro', obras['vlr_tesouro'] < 0)
    avisa_valores('orcamento_obras', 'negativos em vlr_outros', obras['vlr_outros'] < 0)
    avisa_valores('orcamento_obras', 'iguais a zero na soma de vlr_tesouro e vlr_outros', obras['vlr_tesouro'] + obras['vlr_outros'] == 0)
    avisa_valores('orcamento_obras', 'vazios em unidade_medida_desc', obras['unidade_medida_desc'] == '')

    palavras = obras['unidade_medida_desc'].str.split().explode().dropna()
    longas = palavras[palavras.str.len() > 14].unique()
    if len(longas) > 0:
        print('orcamento_obras: há palavras de mais de 14 caracteres em unidade_medida_desc:'
              f'{", ".join(longas)}', file=sys.stderr)

    return obras


def trata_planejamento_acao(caminho):
    """
    Função para abrir o banco planejamento_acao.csv, usado no volume 4.
    """
    acoes = pd.read_csv(caminho, dtype=str, keep_default_na=False)
    acoes = acoes.apply(corrige_caracteres_especiais)
    acoes = acoes[(acoes['programa_exclusao'] == 'NÃO') & (acoes['acao_exclusao'] == 'NÃO')]

    for coluna, largura in [('funcao_cod', 2), ('subfuncao_cod', 3), ('programa_cod', 3)]:
        acoes[coluna] = acoes[coluna].str.zfill(largura)

    return acoes
