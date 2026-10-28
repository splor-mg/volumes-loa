"""
Gera pdf/volume4.pdf a partir dos templates Jinja em volume4/jinja2.
"""
from pathlib import Path
import pandas as pd

from utils.python.latex import compila, renderiza
from utils.python.trata_bancos import le_planilha

NOME = 'volume4'
DADOS = Path('volume4/data')
JINJA2 = Path('volume4/jinja2')
AUX_FILES = Path('volume4/pdf/aux_files')


def le_tabela(caminho):
    return pd.read_csv(caminho, sep='\t', dtype=str, keep_default_na=False)


def prepara_tabela1(sumario):
    tabelas = []
    for _, uo in sumario.iterrows():
        tabelas.append({
            'orgao': uo['orgao'],
            'uo': uo['uo'],
            'linhas': le_tabela(DADOS / 'tabela1' / f'{uo["uo_cod"]}.txt').to_dict('records'),
        })
    return tabelas


def prepara_tabela2(sumario):
    poderes = set()
    orgaos = set()
    uos = []
    for _, uo in sumario.iterrows():
        poder = uo['poder']
        orgao = uo['orgao_cod']
        acoes = []
        tabela = le_tabela(DADOS / 'tabela2' / f'{uo["uo_cod"]}.txt')
        for especificacao, banco in tabela.groupby('especificacao', sort=False):
            territorios = {''}
            municipios = {''}
            linhas = []
            for linha in banco.to_dict('records'):
                territorio = linha['regiao_geografica_intermediaria_desc']
                municipio = linha['municipio_desc']
                linha['novo_territorio'] = territorio not in territorios
                linha['novo_municipio'] = municipio not in municipios
                territorios.add(territorio)
                municipios.add(municipio)
                linhas.append(linha)
            acoes.append({
                'especificacao': especificacao,
                'cod_admin': linhas[0]['cod_admin'],
                'nome_acao': linhas[0]['nome_acao'],
                'linhas': linhas,
            })
        uos.append({
            'novo_poder': poder not in poderes,
            'poder': poder,
            'novo_orgao': orgao not in orgaos,
            'orgao': uo['orgao'],
            'unidade': uo['uo'],
            'acoes': acoes,
        })
        poderes.add(poder)
        orgaos.add(orgao)
    return uos


def prepara_anexo():
    anexo = le_planilha('bancos/manual/correspondencia_mun_terr_desenvol.xlsx')
    anexo = anexo.sort_values('COD SIGPLAN')
    regioes = []
    for codigo, regiao in anexo.groupby('Código Região Geográfica Intermediária'):
        regioes.append({
            'codigo': f'{codigo:02}',
            'nome': regiao['Região Geográfica Intermediária'].iloc[0].upper(),
            'municipios': list(zip(regiao['COD SIGPLAN'], regiao['Municípios'])),
        })
    return regioes


log = Path('logs/logv4.Rout')
if log.exists() and log.stat().st_size > 0:
    print('!-- Verificar logs/logv4.Rout ...')

print('-- Iniciando volume4.pdf ...')
sumario = le_tabela(DADOS / 'sumario.txt')
tex = renderiza(
    JINJA2,
    NOME,
    tabelas1=prepara_tabela1(sumario),
    uos=prepara_tabela2(sumario),
    regioes=prepara_anexo(),
)
AUX_FILES.mkdir(parents=True, exist_ok=True)
(AUX_FILES / f'{NOME}.tex').write_text(tex, encoding='utf-8')
compila(JINJA2, AUX_FILES, NOME)
