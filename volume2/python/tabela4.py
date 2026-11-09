"""
Tabela 4: DEMONSTRATIVO DOS RECURSOS FINANCEIROS
"""
import pandas as pd

from utils.python.funcoes import escreve_tabela, formatar_num_tabela
from utils.python.quadro_receita import VALORES, gera_quadro_receita


def gera_tabela4(receita, classificacao, caminho):
    # UO sem receita própria: a tabela sai zerada, porque a UO tem a tabela 5
    if receita.empty:
        tabela = pd.DataFrame({'cod_texto': '', 'fonte_cod': '', 'receita_desc': ['', 'SUBTOTAL 1'],
                               'valor_desdobramento': '0', 'valor_especie': '0', 'valor_categoria': '0'})
        escreve_tabela(tabela, caminho)
        return

    tabela = gera_quadro_receita(receita, classificacao, f'Warning: V2 T4: UO {receita["uo_cod"].iloc[0]}: ')

    total = {'receita_desc': 'SUBTOTAL 1', 'valor_categoria': receita['vlr_loa_rec'].sum()}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)
    tabela[VALORES] = tabela[VALORES].apply(formatar_num_tabela)

    escreve_tabela(tabela, caminho)
