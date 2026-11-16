"""
Gera pdf/volume7.pdf a partir dos templates Jinja em volume7/jinja2.
"""
from pathlib import Path

from utils.python.consolidado_qdd import prepara_consolidado, prepara_qdd
from utils.python.latex import compila, ler_codigos, renderiza
from utils.python.trata_bancos import le_banco

NOME = 'volume7'
DADOS = Path('volume7/data')
JINJA2 = Path('volume7/jinja2')
AUX_FILES = Path('volume7/pdf/aux_files')

log = Path('logs/logv7.Rout')
if log.exists() and log.stat().st_size > 0:
    print('!-- Verificar logs/logv7.Rout ...')

classificacao = le_banco('bancos/PPO/classificacao_despesa.csv')
grupos = classificacao[(classificacao['grupo_cod'] != '0') & (classificacao['modalidade_cod'] == '0')]
print('-- Iniciando pdf/volume7.pdf ...')
consolidado, total = prepara_consolidado(DADOS / 'consolidado.txt')
tex = renderiza(
    JINJA2,
    NOME,
    consolidado=consolidado,
    total=total,
    uos=prepara_qdd(DADOS / 'qdd.txt'),
    grupos_despesa=ler_codigos(grupos, 'grupo_cod', 'despesa_desc'),
    fontes=ler_codigos(le_banco('bancos/PPO/classificacao_fonte.csv'), 'fonte_cod', 'fonte_desc'),
    ipu=ler_codigos(le_banco('bancos/PPO/classificacao_ipu.csv'), 'ipu_cod', 'ipu_desc'),
    iag=ler_codigos(le_banco('bancos/PPO/classificacao_iag.csv'), 'iag_cod', 'iag_desc'),
)
AUX_FILES.mkdir(parents=True, exist_ok=True)
(AUX_FILES / f'{NOME}.tex').write_text(tex, encoding='utf-8')
compila(JINJA2, AUX_FILES, NOME)
