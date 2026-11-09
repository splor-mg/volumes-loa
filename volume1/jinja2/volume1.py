"""
Gera pdf/<tabela>.pdf a partir do template Jinja volume1/jinja2/<tabela>.tex.j2.
Uso: python3 -m volume1.jinja2.volume1 <tabela>
"""
import re
import sys
from pathlib import Path

import pandas as pd

from utils.python.funcoes import le_tabela
from utils.python.latex import compila, renderiza

DADOS = Path('volume1/data')
JINJA2 = Path('volume1/jinja2')
AUX_FILES = Path('volume1/pdf/aux_files')

# Tabelas que leem os dados de outro volume
DADOS_TABELA = {
    'tabela31': 'volume3/data/consolidado/t3_investimentos_projeto_atividade.txt',
    'tabela32': 'volume3/data/consolidado/t1_investimentos_empresa.txt',
    'tabela33': 'volume3/data/consolidado/t2_investimentos_empresa_detalhamento.txt',
}


def base_legal(codigo):
    banco = 'bancos/manual/desc_base_legal_demonstrativos.xlsx'
    base = pd.read_excel(banco, sheet_name='base_legal')
    legislacao = base.loc[base['cod'].str.strip() == codigo, 'legislacao'].str.strip()
    if legislacao.empty:
        sys.exit(f'Faltando base legal do demonstrativo {codigo} na planilha {banco}')
    return legislacao.iloc[0]


def negativo_contabil(texto):
    """Como negativoContabil do R: -1.234 vira (1.234)."""
    return re.sub(r' *-(\d.+)', r'(\1)', texto)


def formata_receita_cod(codigo):
    """Como formatReceita_COD do R: separa as naturezas da receita com pontos."""
    if len(codigo) == 10:
        return re.sub(r'(.)(.)(.)(.)(..)(..)(..)', r'\1.\2.\3.\4.\5.\6.\7', codigo)
    if len(codigo) == 13:
        return re.sub(r'(.{4})(..)(.)(.)(..)(...)', r'\1.\2.\3.\4.\5.\6', codigo)
    return codigo


def formata_valor(texto):
    if pd.isna(texto):
        return ''
    valor = round(float(texto.replace('.', '').replace(',', '.')))
    if valor == 0:
        return '-'
    absoluto = f'{abs(valor):,}'.replace(',', '.')
    return f'\\textcolor{{red}}{{({absoluto})}}' if valor < 0 else absoluto


def formata_percentual(texto):
    if pd.isna(texto):
        return ''
    percentual = float(texto.replace(',', '.'))
    if round(percentual, 2) == 0:
        return '-'
    return f'{percentual:.2f}'.replace('.', ',') + '\\%'


def formata_valor_t1(valor, percentual, com_sinal):
    """Como formata_valor do .Rnw da T1: zero vira '-' e percentual sai com sinal de menos."""
    if valor == '':
        return ''
    valor = negativo_contabil(valor)
    if not percentual and not re.search('[1-9]', valor):
        return '-'
    if percentual or com_sinal:
        return re.sub(r'^\((.*)\)$', r'-\1', valor)
    return valor


def prepara_t1():
    banco = le_tabela(DADOS / 'tabela1.txt')
    colunas = ['desc', 'ord', 'part_ord', 'vinc', 'part_vinc', 'total', 'part_total']
    banco.columns = [f'{lado}_{coluna}' for lado in ('rec', 'desp') for coluna in colunas]

    # O nível vem do recuo da descrição
    recuos = {}
    for lado in ('rec', 'desp'):
        descricao = banco[f'{lado}_desc']
        recuos[lado] = descricao.str.len() - descricao.str.lstrip(' \t\r\n').str.len()
    banco = banco.apply(lambda coluna: coluna.str.strip())
    for lado, recuo in recuos.items():
        niveis = {valor: nivel for nivel, valor in enumerate(sorted(recuo.unique()))}
        banco[f'{lado}_nivel'] = recuo.map(niveis)

    linhas = []
    for i, linha in enumerate(banco.to_dict('records')):
        for lado in ('rec', 'desp'):
            valores = [linha[f'{lado}_{coluna}'] for coluna in colunas[1:]]
            linha[f'{lado}_valores'] = [formata_valor_t1(valor, k % 2 == 1, False)
                                        for k, valor in enumerate(valores)]
        if all(linha[coluna] == '' for coluna in banco.columns if not coluna.endswith('_nivel')):
            linha['tipo'] = 'vazia'
        elif linha['rec_desc'].startswith('RESULTADO'):
            linha['tipo'] = 'resultado'
            linha['resultado'] = [formata_valor_t1(linha[f'rec_{coluna}'], False, True)
                                  for coluna in ('ord', 'vinc', 'total')]
        elif linha['rec_desc'].startswith('TOTAL'):
            linha['tipo'] = 'total'
            linha['apos_total'] = banco['rec_desc'].iloc[i - 1].startswith('TOTAL')
        else:
            linha['tipo'] = 'normal'
        linhas.append(linha)
    return {'linhas': linhas}


def prepara_t40():
    banco = pd.read_csv(DADOS / 'tabela40.txt', sep=';', dtype=str).apply(lambda coluna: coluna.str.strip())
    linhas = []
    for linha in banco.to_dict('records'):
        nivel = int(linha['NIVEL'])
        linhas.append({
            'poder': linha['PODER'],
            'rotulo': linha['ESPECIFICACAO'],
            'nivel': nivel,
            'negrito': nivel != 2,
            'sombreado': nivel == 0,
            'valores': [formata_valor(linha[f'DESPESA_ANO{ano}']) for ano in (1, 2, 3)],
            'percentuais': [formata_percentual(linha[f'PERCENTUAL_ANO{ano}']) for ano in (1, 2, 3)],
        })

    # Os totais do consolidado e do estado saem como TOTAL e sem sombreado
    totais = {linha['poder']: linha | {'rotulo': 'TOTAL', 'sombreado': False}
              for linha in linhas if linha['poder'] in ('CONSOLIDADO', 'TOTAL') and linha['nivel'] == 0}
    poderes = [{'total': linha, 'detalhes': [detalhe for detalhe in linhas
                                             if detalhe['poder'] == linha['poder'] and detalhe['nivel'] != 0]}
               for linha in linhas if linha['nivel'] == 0 and linha['poder'] not in ('CONSOLIDADO', 'TOTAL')]
    return {
        'consolidado': [linha for linha in linhas if linha['poder'] == 'CONSOLIDADO' and linha['nivel'] != 0],
        'total_consolidado': totais['CONSOLIDADO'],
        'poderes': poderes,
        'total_geral': totais['TOTAL'],
    }


nome = sys.argv[1]

log = Path('logs/logv1.Rout')
if log.exists() and log.stat().st_size > 0:
    print('!-- Verificar logs/logv1.Rout ...')

print(f'-- Iniciando pdf/{nome}.pdf ...')

if nome == 'tabela1':
    contexto = prepara_t1()
elif nome == 'tabela3':
    contexto = {'linhas': le_tabela(DADOS / 'tabela3a.txt').to_dict('records'),
                'resumo': le_tabela(DADOS / 'tabela3b.txt').to_dict('records')}
elif nome == 'tabela25':
    contexto = {'linhas': le_tabela(DADOS / 'tabela25a.txt').to_dict('records'),
                'magisterio': le_tabela(DADOS / 'tabela25b.txt').to_dict('records')}
elif nome == 'tabela40':
    contexto = prepara_t40()
else:
    contexto = {'linhas': le_tabela(DADOS_TABELA.get(nome, DADOS / f'{nome}.txt')).to_dict('records')}
if nome in ('tabela6', 'tabela12'):
    colunas = contexto['linhas'][0]
    contexto['anos'] = sorted(int(coluna[-4:]) for coluna in colunas if coluna.startswith('VL'))

tex = renderiza(JINJA2, nome, base_legal=base_legal, negativo_contabil=negativo_contabil,
                formata_receita_cod=formata_receita_cod, **contexto)
AUX_FILES.mkdir(parents=True, exist_ok=True)
(AUX_FILES / f'{nome}.tex').write_text(tex, encoding='utf-8')
compila(JINJA2, AUX_FILES, nome)
