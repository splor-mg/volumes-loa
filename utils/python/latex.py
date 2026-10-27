"""
Geração do PDF dos volumes a partir dos templates Jinja.
"""
import os
import subprocess
from pathlib import Path

import jinja2

from utils.python.funcoes import texto_r
from utils.python.trata_bancos import le_planilha


def ler_codigos(arquivo, coluna):
    planilha = le_planilha(Path('bancos/manual') / arquivo)
    planilha = planilha.sort_values('CODIGO', kind='stable')
    return [
        (texto_r(codigo), texto_r(descricao).upper())
        for codigo, descricao in zip(planilha['CODIGO'], planilha[coluna])
    ]


def renderiza(pasta, nome, **contexto):
    ambiente = jinja2.Environment(
        loader=jinja2.FileSystemLoader(pasta),
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
    etapa = Path('utils/etapa_orcamento.txt').read_text(encoding='utf-8')
    return ambiente.get_template(f'{nome}.tex.j2').render(
        ano_doc=int(Path('utils/ano.txt').read_text()),
        etapa_orcamento=etapa.splitlines()[0],
        **contexto,
    )


def compila(pasta, aux_files, nome):
    ambiente = os.environ | {'TEXINPUTS': f'{pasta}:capas:'}
    comando = [
        'pdflatex',
        '-interaction=batchmode',
        f'-output-directory={aux_files}',
        aux_files / f'{nome}.tex',
    ]
    anteriores = []
    for _ in range(10):
        subprocess.run(comando, env=ambiente, check=True, stdout=subprocess.DEVNULL)
        auxiliares = [
            (aux_files / f'{nome}.{extensao}').read_bytes()
            for extensao in ('aux', 'toc', 'out')
        ]
        if auxiliares == anteriores:
            break
        anteriores = auxiliares
    else:
        raise RuntimeError(f'{nome}.tex não estabilizou após 10 execuções do pdflatex')

    Path('pdf').mkdir(exist_ok=True)
    os.replace(aux_files / f'{nome}.pdf', f'pdf/{nome}.pdf')
