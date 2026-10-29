"""
Gera pdf/volume5.pdf a partir dos templates Jinja em volume5/jinja2.
"""
from pathlib import Path

from utils.python.consolidado_qdd import prepara_consolidado, prepara_qdd
from utils.python.latex import compila, ler_codigos, renderiza

NOME = 'volume5'
DADOS = Path('volume5/data')
JINJA2 = Path('volume5/jinja2')
AUX_FILES = Path('volume5/pdf/aux_files')

log = Path('logs/logv5.Rout')
if log.exists() and log.stat().st_size > 0:
    print('!-- Verificar logs/logv5.Rout ...')

print('-- Iniciando pdf/volume5.pdf ...')
consolidado, total = prepara_consolidado(DADOS / 'consolidado.txt')
tex = renderiza(
    JINJA2,
    NOME,
    consolidado=consolidado,
    total=total,
    uos=prepara_qdd(DADOS / 'qdd.txt'),
    grupos_despesa=ler_codigos('desc_grupos_de_despesa.xlsx', 'ESPECIFICACAO'),
    fontes=ler_codigos('desc_fontes_de_recursos.xlsx', 'CLASSIFICACAO'),
    ipu=ler_codigos('desc_IPU.xlsx', 'ESPECIFICACAO'),
    iag=ler_codigos('desc_IAG.xlsx', 'INTERPRETACAO'),
)
AUX_FILES.mkdir(parents=True, exist_ok=True)
(AUX_FILES / f'{NOME}.tex').write_text(tex, encoding='utf-8')
compila(JINJA2, AUX_FILES, NOME)
