"""
Gera pdf/volume3.pdf a partir dos templates Jinja em volume3/jinja2.
"""
from pathlib import Path

from utils.python.funcoes import le_tabela
from utils.python.latex import compila, renderiza

NOME = 'volume3'
DADOS = Path('volume3/data')
JINJA2 = Path('volume3/jinja2')
AUX_FILES = Path('volume3/pdf/aux_files')


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


log = Path('logs/logv3.Rout')
if log.exists() and log.stat().st_size > 0:
    print('!-- Verificar logs/logv3.Rout ...')

print('-- Iniciando pdf/volume3.pdf ...')
consolidado1 = le_tabela(DADOS / 'consolidado' / 't1_investimentos_empresa.txt')
consolidado2 = le_tabela(DADOS / 'consolidado' / 't2_investimentos_empresa_detalhamento.txt')
consolidado3 = le_tabela(DADOS / 'consolidado' / 't3_investimentos_projeto_atividade.txt')
origem = le_tabela('bancos/manual/ANEXO_origens_de_recursos.txt')
detalhamento = le_tabela('bancos/manual/ANEXO_detalhamento_investimentos.txt')
tex = renderiza(
    JINJA2,
    NOME,
    consolidado1=consolidado1.to_dict('records'),
    consolidado2=consolidado2.to_dict('records'),
    consolidado3=consolidado3.to_dict('records'),
    uos=prepara_uos(),
    origem=origem.to_dict('records'),
    detalhamento=detalhamento.to_dict('records'),
)
AUX_FILES.mkdir(parents=True, exist_ok=True)
(AUX_FILES / f'{NOME}.tex').write_text(tex, encoding='utf-8')
compila(JINJA2, AUX_FILES, NOME)
