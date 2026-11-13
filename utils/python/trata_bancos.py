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


def le_banco(caminho):
    """
    Lê um banco de bancos/PPO como texto, sem espaços nas pontas e com os caracteres especiais corrigidos.
    """
    banco = pd.read_csv(caminho, dtype=str, keep_default_na=False)
    banco = banco.apply(lambda coluna: corrige_caracteres_especiais(coluna.str.strip()))

    return banco


def avisa_valores(banco, descricao, linhas):
    if linhas.any():
        numeros = ', '.join(str(i + 2) for i in linhas.index[linhas])
        print(f'{banco}: há valores {descricao} nas linhas {numeros}', file=sys.stderr)


def trata_orcamento_despesa_fonte_80_95(caminho):
    """
    Função para abrir o banco orcamento_despesa_fonte_80_95.csv, usado no volume 7.
    """
    qdd = le_banco(caminho)
    qdd['vlr_loa_desp'] = qdd['vlr_loa_desp'].astype(float)

    larguras = [('funcao_cod', 2), ('subfuncao_cod', 3), ('projeto_atividade_cod', 3),
                ('subprojeto_cod', 4), ('elemento_cod', 2)]
    for coluna, largura in larguras:
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
    Função para abrir o banco orcamento_despesa.csv, usado nos volumes 1, 2 e 5.
    """
    qdd = le_banco(caminho).rename(columns={'acao_desc': 'especificacao'})
    qdd['vlr_loa_desp'] = qdd['vlr_loa_desp'].astype(float)
    qdd['asps'] = qdd['asps'] == 'TRUE'

    larguras = [('funcao_cod', 2), ('subfuncao_cod', 3), ('projeto_atividade_cod', 3), ('subprojeto_cod', 4),
                ('elemento_cod', 2)]
    for coluna, largura in larguras:
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
    Função para abrir o banco orcamento_despesa_investimento.csv, usado nos volumes 1 e 3.
    """
    qdd = le_banco(caminho)
    qdd['vlr_loa_desp'] = qdd['vlr_loa_desp'].astype(float)

    valores = qdd['vlr_loa_desp']
    avisa_valores('orcamento_despesa_investimento', 'negativos', valores < 0)
    avisa_valores('orcamento_despesa_investimento', 'iguais a zero', valores == 0)

    return qdd


def trata_orcamento_obras(caminho):
    """
    Função para abrir o banco orcamento_obras.csv, usado no volume 4.
    """
    obras = le_banco(caminho)

    obras['obra_desc'] = obras['obra_desc'].str.replace(r'\r?\n', ' ', regex=True)
    obras['obra_quantidade'] = pd.to_numeric(obras['obra_quantidade'])
    obras[['vlr_tesouro', 'vlr_outros']] = obras[['vlr_tesouro', 'vlr_outros']].astype(float)

    for coluna, largura in [('funcao_cod', 2), ('subfuncao_cod', 3), ('programa_cod', 3)]:
        obras[coluna] = obras[coluna].str.zfill(largura)

    avisa_valores('orcamento_obras', 'negativos em vlr_tesouro', obras['vlr_tesouro'] < 0)
    avisa_valores('orcamento_obras', 'negativos em vlr_outros', obras['vlr_outros'] < 0)
    avisa_valores('orcamento_obras', 'iguais a zero na soma de vlr_tesouro e vlr_outros', obras['vlr_tesouro'] + obras['vlr_outros'] == 0)
    avisa_valores('orcamento_obras', 'vazios em unidade_medida', obras['unidade_medida'] == '')

    palavras = obras['unidade_medida'].str.split().explode().dropna()
    longas = palavras[palavras.str.len() > 14].unique()
    if len(longas) > 0:
        print('orcamento_obras: há palavras de mais de 14 caracteres em unidade_medida:'
              f'{", ".join(longas)}', file=sys.stderr)

    return obras


def trata_orcamento_pessoal(caminho):
    """
    Função para abrir o banco orcamento_pessoal.csv, usado nos volumes 1 e 2.
    """
    pessoal = le_banco(caminho)
    pessoal['pessoal_quantidade'] = pd.to_numeric(pessoal['pessoal_quantidade'])

    quantidades = pessoal['pessoal_quantidade']
    avisa_valores('orcamento_pessoal', 'sem 4 dígitos em uo_cod', ~pessoal['uo_cod'].str.match(r'\d{4}'))
    avisa_valores('orcamento_pessoal', 'negativos', quantidades < 0)
    avisa_valores('orcamento_pessoal', 'iguais a zero', quantidades == 0)

    return pessoal


def trata_orcamento_receita(caminho):
    """
    Função para abrir o banco orcamento_receita.csv, usado nos volumes 1 e 2.
    """
    receita = le_banco(caminho)
    receita['vlr_loa_rec'] = receita['vlr_loa_rec'].astype(float)
    receita['fonte_cod'] = receita['fonte_cod'].astype(int)
    regras = receita.columns[receita.isin(['TRUE', 'FALSE']).all()]
    receita[regras] = receita[regras] == 'TRUE'

    negativos = (receita['vlr_loa_rec'] < 0) & ~receita['receita_cod'].str.startswith('9')
    avisa_valores('orcamento_receita', 'negativos', negativos)

    return receita


def trata_classificacao_receita(caminho):
    """
    Função para abrir o banco classificacao_receita.csv, usado nos volumes 1 e 2.
    """
    classificacao = le_banco(caminho)
    return pd.DataFrame({
        'cod_texto': classificacao['receita_cod'].str.replace(
            r'(.{4})(..)(.)(.)(..)(...)', r'\1.\2.\3.\4.\5.\6', regex=True),
        'receita_desc': classificacao['receita_desc'],
    })


def trata_orcamento_repasse(caminho):
    """
    Função para abrir o banco orcamento_repasse.csv, usado no volume 2.
    """
    repasse = le_banco(caminho)
    repasse['vlr_repasse'] = repasse['vlr_repasse'].astype(float)
    codigos = ['grupo_cod', 'iag_cod', 'fonte_cod', 'ipu_cod']
    repasse[codigos] = repasse[codigos].astype(int)

    valores = repasse['vlr_repasse']
    avisa_valores('orcamento_repasse', 'negativos', valores < 0)
    avisa_valores('orcamento_repasse', 'iguais a zero', valores == 0)
    for coluna in ['uo_financiadora_cod', 'uo_beneficiada_cod']:
        avisa_valores('orcamento_repasse', f'sem 4 dígitos em {coluna}', repasse[coluna].str.len() != 4)

    return repasse


def trata_planejamento_acao(caminho):
    """
    Função para abrir o banco planejamento_acao.csv, usado nos volumes 1 a 4.
    """
    acoes = le_banco(caminho)
    acoes = acoes[(acoes['programa_exclusao'] == 'N') & (acoes['acao_exclusao'] == 'N')]

    for coluna, largura in [('funcao_cod', 2), ('subfuncao_cod', 3), ('programa_cod', 3)]:
        acoes[coluna] = acoes[coluna].str.zfill(largura)

    acoes['vlr_meta_fisica_ano0'] = pd.to_numeric(acoes['vlr_meta_fisica_ano0'])

    textos = ['funcao_desc', 'subfuncao_desc', 'acao_finalidade', 'produto', 'unidade_medida']
    acoes[textos] = acoes[textos].apply(lambda coluna: coluna.str.replace(r'\n+', ' ', regex=True)
                                        .str.replace(r'[\x00-\x1f]', ' ', regex=True))

    return acoes
