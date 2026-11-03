"""
Gera pdf/volume2.pdf a partir dos templates Jinja em volume2/jinja2.
"""
import re
import sys
from pathlib import Path

from utils.python.funcoes import le_tabela, texto_r
from utils.python.latex import compila, ler_codigos, renderiza
from utils.python.trata_bancos import le_planilha

NOME = 'volume2'
DADOS = Path('volume2/data')
JINJA2 = Path('volume2/jinja2')
AUX_FILES = Path('volume2/pdf/aux_files')
FUNFIP = '4711'


def prepara_tabela2(caminho):
    tabela = le_tabela(caminho)
    valores = tabela.columns[5:].tolist()
    colunas = 3 + len(valores)
    largura = 2 if colunas == 5 else round(10 / (colunas - 4), 1)

    linhas = tabela.to_dict('records')
    for linha, proxima in zip(linhas, linhas[1:] + [None]):
        fonte = linha['fonte_desc'].upper()
        iag = linha['iag_cod'].upper()
        linha['negrito'] = fonte == 'TOTAL' or iag == 'TOTAL'
        if proxima and iag != 'TOTAL' and proxima['iag_cod'].upper() != 'TOTAL':
            inicio = 2 if iag == '' and proxima['iag_cod'] != '' else 3
            linha['linha_horizontal'] = f'\\cline{{{inicio}-{colunas}}}'
        elif proxima and iag == 'TOTAL' and proxima['fonte_desc'].upper() != 'TOTAL':
            linha['linha_horizontal'] = '\\hline'
        elif iag == 'TOTAL' or fonte == 'TOTAL':
            linha['linha_horizontal'] = '\\hline \\hline \\hline'
        else:
            linha['linha_horizontal'] = f'\\cline{{2-{colunas}}}'

    return {
        'colunas': colunas,
        'largura': f'{largura:g}',
        'grupos': valores[:-1],
        'valores': valores,
        'linhas': linhas,
    }


def prepara_tabela5(caminho):
    linhas = le_tabela(caminho).to_dict('records')
    for linha in linhas:
        linha['titulo'] = re.match(r'\d\..', linha['especificacao']) is not None
    return linhas


def prepara_rodape():
    ipu = le_planilha('bancos/manual/desc_IPU.xlsx')
    iag = le_planilha('bancos/manual/desc_IAG.xlsx')
    ipus = [f'{texto_r(codigo)} - {texto}' for codigo, texto in zip(ipu['CODIGO'], ipu['ESPECIFICACAO'])]
    iags = [f'{texto_r(codigo)} - {texto}' for codigo, texto in zip(iag['CODIGO'], iag['INTERPRETACAO'])]
    return list(zip(iags + [''] * (len(ipus) - len(iags)), ipus))


def prepara_uos():
    aviso = 'Warning: V2 {}: Para a UO {} NÃO existe o banco {}'
    poderes = set()
    orgaos = set()
    uos = le_tabela(DADOS / 'sumario.txt').to_dict('records')
    for uo in uos:
        uo_cod = uo['uo_cod']
        uo['novo_poder'] = uo['poder'] not in poderes
        uo['novo_orgao'] = uo['orgao'] not in orgaos
        uo['nome'] = uo['uo'].split(' - ', 1)[1]
        poderes.add(uo['poder'])
        orgaos.add(uo['orgao'])

        uo['tabela1'] = le_tabela(DADOS / 'tabela1' / f'{uo_cod}.txt').to_dict('records')

        caminho = DADOS / 'tabela2' / f'{uo_cod}.txt'
        uo['tabela2'] = prepara_tabela2(caminho) if caminho.exists() else None
        if not caminho.exists():
            print(aviso.format('T2', uo_cod, 'T2 RECURSOS FINANCEIROS FONTE RECURSOS GRUPOS DESPESA '
                               'FISCAL'), file=sys.stderr)

        # Na UO do FUNFIP, a tabela 3 é a do pessoal inativo civil
        caminho = DADOS / 'tabela3' / f'{uo_cod}.txt'
        funfip = DADOS / 'tabela3' / 'funfip.txt'
        uo['funfip'] = None
        uo['tabela3'] = None
        if uo_cod == FUNFIP and funfip.exists():
            uo['funfip'] = le_tabela(funfip).to_dict('records')
        elif caminho.exists():
            uo['tabela3'] = le_tabela(caminho).to_dict('records')
        else:
            print(aviso.format('T3', uo_cod, 'T3 RECURSOS OCAMENTARIO CATEGORIA PESSOAL'),
                  file=sys.stderr)

        # Tabelas 4 e 5 só nas UOs que não começam com 1
        direta = uo_cod.startswith('1')
        caminho = DADOS / 'tabela4' / f'{uo_cod}.txt'
        uo['tabela4'] = None
        if not caminho.exists():
            print(aviso.format('T4', uo_cod, 'T4 DEMONSTRATIVO DOS RECURSOS FINANCEIROS'),
                  file=sys.stderr)
        elif not direta:
            uo['tabela4'] = le_tabela(caminho).to_dict('records')

        caminho = DADOS / 'tabela5' / f'{uo_cod}.txt'
        uo['tabela5'] = None
        if direta:
            continue
        if not caminho.exists():
            print(aviso.format('T5', uo_cod, 'T5 DEMONSTRATIVO DOS RECURSOS FINANCEIROS TABELA DEMAIS '
                               'RECURSOS'), file=sys.stderr)
        else:
            uo['tabela5'] = prepara_tabela5(caminho)
    return uos


log = Path('logs/logv2.Rout')
if log.exists() and log.stat().st_size > 0:
    print('!-- Verificar logs/logv2.Rout ...')

print('-- Iniciando pdf/volume2.pdf ...')
tex = renderiza(
    JINJA2,
    NOME,
    uos=prepara_uos(),
    rodape=prepara_rodape(),
    grupos_despesa=ler_codigos('desc_grupos_de_despesa.xlsx', 'ESPECIFICACAO'),
    fontes=ler_codigos('desc_fontes_de_recursos.xlsx', 'CLASSIFICACAO'),
    ipu=ler_codigos('desc_IPU.xlsx', 'ESPECIFICACAO'),
    iag=ler_codigos('desc_IAG.xlsx', 'INTERPRETACAO'),
)
AUX_FILES.mkdir(parents=True, exist_ok=True)
(AUX_FILES / f'{NOME}.tex').write_text(tex, encoding='utf-8')
compila(JINJA2, AUX_FILES, NOME)
