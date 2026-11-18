"""
Gera pdf/volume3.pdf a partir dos templates Jinja em volume3/jinja2.
"""
from pathlib import Path

from utils.python.funcoes import le_tabela
from utils.python.latex import compila, renderiza
from utils.python.trata_bancos import le_banco

NOME = 'volume3'
DADOS = Path('volume3/data')
JINJA2 = Path('volume3/jinja2')
AUX_FILES = Path('volume3/pdf/aux_files')

# Anexo "Origem de recursos para investimento": cod é o nível de recuo da linha
ORIGEM = [
    {'cod': 1, 'descricao': 'Aumento de Capital'},
    {'cod': 2, 'descricao': 'Recursos do Estado'},
    {'cod': 3, 'descricao': 'Tesouro Ordinário'},
    {'cod': 4, 'descricao': 'Aplicação Livre'},
    {'cod': 3, 'descricao': 'Tesouro Vinculado'},
    {'cod': 4, 'descricao': 'FUNDESE'},
    {'cod': 1, 'descricao': 'Operação de Crédito'},
    {'cod': 2, 'descricao': 'Contratada'},
    {'cod': 3, 'descricao': 'Interna'},
    {'cod': 4, 'descricao': 'BNDES'},
    {'cod': 4, 'descricao': 'Outras'},
    {'cod': 3, 'descricao': 'Externa'},
    {'cod': 4, 'descricao': 'KFW'},
    {'cod': 1, 'descricao': 'Recursos Próprios'},
    {'cod': 4, 'descricao': 'Recursos Próprios'},
]


def prepara_tabela3(uo_cod):
    tabela = le_tabela(DADOS / 'tabela3' / f'{uo_cod}.txt')
    colunas = len(tabela.columns)

    if colunas <= 3:
        largura = 5
        largura_demais = round(4 / (colunas - 2))

    elif colunas <= 6:
        largura = 10
        largura_demais = round(10 / (colunas - 2), 1)

    else:
        largura = 12
        largura_demais = round(12 / (colunas - 2), 1)

    return {
        'colunas': colunas,
        'largura': largura,
        'largura_coluna': round(largura / (colunas - 1)),
        'largura_demais': f'{largura_demais:g}',
        'naturezas': tabela.columns[1:-1].tolist(),
        'linhas': tabela.to_numpy().tolist(),
    }


def prepara_uos():
    uos = le_tabela(DADOS / 'sumario.txt').to_dict('records')
    for uo in uos:
        uo_cod = uo['uo_cod']
        for pasta in ['tabela1', 'tabela2', 'tabela4', 'tabela5']:
            uo[pasta] = le_tabela(DADOS / pasta / f'{uo_cod}.txt').to_dict('records')
        uo['tabela3'] = prepara_tabela3(uo_cod)
    return uos


def prepara_detalhamento():
    classificacao = le_banco('datapackages/ppo/data/classificacao_investimento.csv')
    naturezas = classificacao[classificacao['natureza_invest_cod'] != classificacao['categoria_invest_cod']]
    detalhamento = []
    for (_, categoria), grupo in naturezas.groupby(['categoria_invest_cod', 'categoria_invest_desc']):
        detalhamento.append({'cod': 1, 'descricao': categoria})
        for natureza in sorted(grupo['natureza_invest_desc']):
            detalhamento.append({'cod': 5, 'descricao': natureza})
    return detalhamento


log = Path('logs/logv3.Rout')
if log.exists() and log.stat().st_size > 0:
    print('!-- Verificar logs/logv3.Rout ...')

print('-- Iniciando pdf/volume3.pdf ...')
consolidado1 = le_tabela(DADOS / 'consolidado' / 't1_investimentos_empresa.txt')
consolidado2 = le_tabela(DADOS / 'consolidado' / 't2_investimentos_empresa_detalhamento.txt')
consolidado3 = le_tabela(DADOS / 'consolidado' / 't3_investimentos_projeto_atividade.txt')
tex = renderiza(
    JINJA2,
    NOME,
    consolidado1=consolidado1.to_dict('records'),
    consolidado2=consolidado2.to_dict('records'),
    consolidado3=consolidado3.to_dict('records'),
    uos=prepara_uos(),
    origem=ORIGEM,
    detalhamento=prepara_detalhamento(),
)
AUX_FILES.mkdir(parents=True, exist_ok=True)
(AUX_FILES / f'{NOME}.tex').write_text(tex, encoding='utf-8')
compila(JINJA2, AUX_FILES, NOME)
