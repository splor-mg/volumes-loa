"""
Gera pdf/volume7.pdf a partir dos templates Jinja em volume7/jinja2.
"""
import csv
import os
import subprocess
from pathlib import Path

import jinja2
import pandas as pd

from utils.python.funcoes import texto_r
from utils.python.trata_bancos import le_planilha

NOME = 'volume7'
DADOS = Path('volume7/data')
JINJA2 = Path('volume7/jinja2')
AUX_FILES = Path('volume7/pdf/aux_files')


def ler_codigos(arquivo, coluna):
    planilha = le_planilha(Path('bancos/manual') / arquivo).sort_values('CODIGO', kind='stable')
    return [(texto_r(codigo), texto_r(descricao).upper()) for codigo, descricao in zip(planilha['CODIGO'], planilha[coluna])]


def prepara_consolidado():
    consolidado = pd.read_csv(DADOS / 'consolidado.txt', sep='\t', dtype=str, keep_default_na=False, quoting=csv.QUOTE_NONE)
    codigo = consolidado['codigo_texto']
    consolidado['nivel'] = 3
    consolidado.loc[codigo.str[4:6] == '00', 'nivel'] = 2
    consolidado.loc[codigo.str[2].isin(['0', '9']), 'nivel'] = 1

    # A última linha é o TOTAL
    return consolidado.iloc[:-1].to_dict('records'), consolidado.iloc[-1].to_dict()


def prepara_quadro():
    banco = pd.read_csv(DADOS / 'qdd.txt', sep='\t', dtype=str, keep_default_na=False, quoting=csv.QUOTE_NONE)
    banco['tipo'] = 'acao'
    banco.loc[banco['especificacao'] == '', 'tipo'] = 'elemento'
    banco.loc[banco['especificacao'] == 'TOTAL', 'tipo'] = 'total'

    poderes = set()
    orgaos = set()
    uos = []
    for _, uo in banco.groupby('uo_cod', sort=False):
        primeira = uo.iloc[0]
        poder = primeira['poder']
        orgao = primeira['orgao_cod']
        unidade = primeira['uo_cod']
        sigla = primeira['uo_sigla']
        uos.append({
            'novo_poder': poder not in poderes,
            'poder': poder,
            'novo_orgao': orgao not in orgaos,
            'orgao': f'{orgao[0:1]}.{orgao[1:3]}.{orgao[3:4]} - {primeira["orgao_nome"]} - {sigla}',
            'unidade': f'{unidade[0:1]}.{unidade[1:3]}.{unidade[3:4]} - {primeira["uo_nome"]} - {sigla}',
            'ano': primeira['ano'],
            'linhas': uo.to_dict('records'),
        })
        poderes.add(poder)
        orgaos.add(orgao)
    return uos


def renderiza():
    ambiente = jinja2.Environment(
        loader=jinja2.FileSystemLoader(JINJA2),
        block_start_string=r'\BLOCK{',
        block_end_string='}',
        variable_start_string=r'\VAR{',
        variable_end_string='}',
        comment_start_string=r'\#{',
        comment_end_string='}',
        trim_blocks=True,
        lstrip_blocks=True,
        keep_trailing_newline=True,
        undefined=jinja2.StrictUndefined,
    )
    consolidado, total = prepara_consolidado()
    return ambiente.get_template(f'{NOME}.tex.j2').render(
        ano_doc=int(Path('utils/ano.txt').read_text()),
        etapa_orcamento=Path('utils/etapa_orcamento.txt').read_text(encoding='utf-8').splitlines()[0],
        consolidado=consolidado,
        total=total,
        uos=prepara_quadro(),
        grupos_despesa=ler_codigos('desc_grupos_de_despesa.xlsx', 'ESPECIFICACAO'),
        fontes=ler_codigos('desc_fontes_de_recursos.xlsx', 'CLASSIFICACAO'),
        ipu=ler_codigos('desc_IPU.xlsx', 'ESPECIFICACAO'),
        iag=ler_codigos('desc_IAG.xlsx', 'INTERPRETACAO'),
    )


def compila():
    ambiente = os.environ | {'TEXINPUTS': f'{JINJA2}:capas:'}
    comando = ['pdflatex', '-interaction=batchmode', f'-output-directory={AUX_FILES}', AUX_FILES / f'{NOME}.tex']
    anteriores = []
    for _ in range(10):
        subprocess.run(comando, env=ambiente, check=True, stdout=subprocess.DEVNULL)
        auxiliares = [(AUX_FILES / f'{NOME}.{extensao}').read_bytes() for extensao in ('aux', 'toc', 'out')]
        if auxiliares == anteriores:
            break
        anteriores = auxiliares
    else:
        raise RuntimeError(f'{NOME}.tex não estabilizou após 10 execuções do pdflatex')

    Path('pdf').mkdir(exist_ok=True)
    os.replace(AUX_FILES / f'{NOME}.pdf', f'pdf/{NOME}.pdf')


log = Path('logs/logv7.Rout')
if log.exists() and log.stat().st_size > 0:
    print('!-- Verificar logs/logv7.Rout ...')

print('-- Iniciando volume7.pdf ...')
AUX_FILES.mkdir(parents=True, exist_ok=True)
(AUX_FILES / f'{NOME}.tex').write_text(renderiza(), encoding='utf-8')
compila()
