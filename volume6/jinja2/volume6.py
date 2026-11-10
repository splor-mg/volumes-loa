"""
Gera pdf/volume6.pdf a partir dos templates Jinja em volume6/jinja2.
Os dados continuam sendo gerados em R (volume6/R).
"""
from pathlib import Path

from utils.python.funcoes import le_tabela
from utils.python.latex import compila, ler_codigos, renderiza

NOME = 'volume6'
DADOS = Path('volume6/data')
JINJA2 = Path('volume6/jinja2')
AUX_FILES = Path('volume6/pdf/aux_files')


def prepara_receita(caminho):
    receita = le_tabela(caminho)
    codigo = receita['cod_texto']
    receita['tipo'] = 'desdobramento'
    receita.loc[codigo.str.contains(r'\d[1-9]00\.00\.0\.0\.00\.000'), 'tipo'] = 'origem'
    receita.loc[codigo.str.contains(r'\d000\.00\.0\.0\.00\.000'), 'tipo'] = 'categoria'
    receita.loc[receita['descricao'].str.contains('TOTAL', case=False), 'tipo'] = 'total'
    return receita.to_dict('records')


def prepara_qdd(caminho):
    banco = le_tabela(caminho)
    larguras = {'FUNCAO': 2, 'SUB_FUNCAO': 3, 'PROJ_ATIV': 3, 'SUB_PROJETO': 4, 'ELEMENTO_DESPESA': 2}
    for coluna, largura in larguras.items():
        preenchido = banco[coluna] != ''
        banco.loc[preenchido, coluna] = banco.loc[preenchido, coluna].str.zfill(largura)

    banco['tipo'] = 'acao'
    banco.loc[banco['NOME_ACAO'] == '', 'tipo'] = 'elemento'
    banco.loc[banco['NOME_ACAO'].str.upper() == 'TOTAL', 'tipo'] = 'total'

    poderes = set()
    orgaos = set()
    uos = []
    for unidade, uo in banco.groupby('COD_UO', sort=False):
        primeira = uo.iloc[0]
        poder = primeira['poder']
        orgao = primeira['COD_ORGAO']
        uos.append({
            'novo_poder': poder not in poderes,
            'poder': poder,
            'novo_orgao': orgao not in orgaos,
            'orgao': f'{orgao[0:1]}.{orgao[1:3]}.{orgao[3:4]} - {primeira["ORGAO"]}',
            'unidade': f'{unidade[0:1]}.{unidade[1:3]}.{unidade[3:4]} - {primeira["UO"]}',
            'ano': primeira['ANO'],
            'linhas': uo.to_dict('records'),
        })
        poderes.add(poder)
        orgaos.add(orgao)
    return uos


log = Path('logs/logv6.Rout')
if log.exists() and log.stat().st_size > 0:
    print('!-- Verificar logs/logv6.Rout ...')

print('-- Iniciando pdf/volume6.pdf ...')
tex = renderiza(
    JINJA2,
    NOME,
    receita=prepara_receita(DADOS / 'receita_fonte_stn.txt'),
    uos=prepara_qdd(DADOS / 'QUADRO_DETALHAMENTO_DESPESA_porUO.txt'),
    grupos_despesa=ler_codigos('desc_grupos_de_despesa.xlsx', 'ESPECIFICACAO'),
    fontes=ler_codigos('desc_fontes_de_recursos_stn.xlsx', 'CLASSIFICACAO'),
    ipu=ler_codigos('desc_IPU.xlsx', 'ESPECIFICACAO'),
    iag=ler_codigos('desc_IAG.xlsx', 'INTERPRETACAO'),
)
AUX_FILES.mkdir(parents=True, exist_ok=True)
(AUX_FILES / f'{NOME}.tex').write_text(tex, encoding='utf-8')
compila(JINJA2, AUX_FILES, NOME)
