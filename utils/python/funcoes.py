"""
Funções auxiliares de formatação.
"""
import pandas as pd
from pathlib import Path


def texto_r(valor):
    """Vazio vira 'NA' e float vira integer"""
    if pd.isna(valor):
        return 'NA'
    if isinstance(valor, float) and valor.is_integer():
        return str(int(valor))
    return str(valor)


def formatar_num(serie):
    """Por exemplo, 1234567 vira '1.234.567', e alinha os valores à direita"""
    textos = serie.map(lambda valor: f'{valor:,.0f}'.replace(',', '.'))
    textos = textos.str.rjust(textos.str.len().max())
    return textos.str.replace(r' *(-*\d+.+)', r'\1', regex=True)


def escreve_tabela(tabela, caminho):
    linhas = ['\t'.join(tabela.columns)]
    for linha in tabela.itertuples(index=False):
        linhas.append('\t'.join('' if pd.isna(valor) else texto_r(valor) for valor in linha))
    Path(caminho).write_text('\n'.join(linhas) + '\n', encoding='utf-8')
