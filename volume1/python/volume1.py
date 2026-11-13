"""
Gera em volume1/data os dados das tabelas do volume 1 migradas para Python,
um arquivo <tabela>.txt por tabela, a partir de bancos/PPO.
As demais tabelas do volume 1 continuam em R (volume1/R).
"""
from pathlib import Path

import pandas as pd

from utils.python.funcoes import nat
from utils.python.trata_bancos import (trata_classificacao_receita, trata_orcamento_despesa,
                                       trata_orcamento_despesa_investimento, trata_orcamento_pessoal,
                                       trata_orcamento_receita, trata_planejamento_acao)
from volume1.python.acoes import gera_t26, gera_t30, gera_t37, gera_t39
from volume1.python.despesa import gera_t4, gera_t5, gera_t13, gera_t14, gera_t15, gera_t17, gera_t23, gera_t28d
from volume1.python.receita import REC_ORDINARIO, gera_t2, gera_t3, gera_t7_t9, gera_t18, gera_t28c

DADOS = Path('volume1/data')

# Prepara as bases -------------------------------------------------------------
despesa = trata_orcamento_despesa('bancos/PPO/orcamento_despesa.csv')
codigos = ['funcao_cod', 'subfuncao_cod', 'programa_cod', 'acao_cod', 'categoria_cod', 'grupo_cod',
           'modalidade_cod', 'elemento_cod', 'fonte_cod', 'ipu_cod']
despesa[codigos] = despesa[codigos].astype(int)

investimento = trata_orcamento_despesa_investimento('bancos/PPO/orcamento_despesa_investimento.csv')
investimento[codigos[:4]] = investimento[codigos[:4]].astype(int)

acoes = trata_planejamento_acao('bancos/PPO/planejamento_acao.csv')
acoes[codigos[:2] + ['acao_cod']] = acoes[codigos[:2] + ['acao_cod']].astype(int)

pessoal = trata_orcamento_pessoal('bancos/PPO/orcamento_pessoal.csv')
receita = trata_orcamento_receita('bancos/PPO/orcamento_receita.csv')
classificacao = trata_classificacao_receita('bancos/PPO/classificacao_receita.csv')

# Tabelas de despesa -----------------------------------------------------------
gera_t4(despesa, DADOS / 'tabela4.txt')
gera_t5(despesa, pessoal, DADOS / 'tabela5.txt')
gera_t13(despesa, DADOS / 'tabela13.txt')
gera_t14(despesa, DADOS / 'tabela14.txt')
gera_t15(despesa, DADOS / 'tabela15.txt')
gera_t17(despesa, DADOS / 'tabela17.txt')
gera_t23(despesa, DADOS / 'tabela23.txt')
gera_t28d(despesa, receita, DADOS / 'tabela28d.txt')

# Tabelas de receita -----------------------------------------------------------
gera_t2(receita, DADOS / 'tabela2.txt')
gera_t3(receita, despesa, classificacao, DADOS / 'tabela3a.txt', DADOS / 'tabela3b.txt')
gera_t7_t9(receita, classificacao, 'tabela7', DADOS / 'tabela7.txt')
ordinaria = receita[nat(receita['receita_cod'], 1) & receita['fonte_cod'].isin(REC_ORDINARIO)]
gera_t7_t9(ordinaria, classificacao, 'tabela9', DADOS / 'tabela9.txt')
gera_t18(receita, despesa, DADOS / 'tabela18.txt')
gera_t28c(receita, DADOS / 'tabela28c.txt')

# Tabelas por ação -------------------------------------------------------------
colunas = ['uo_cod', 'funcao_cod', 'subfuncao_cod', 'programa_cod', 'acao_cod', 'acao_desc', 'vlr_loa_desp']
fiscal_investimento = pd.concat([despesa.rename(columns={'especificacao': 'acao_desc'})[colunas],
                                 investimento[colunas]], ignore_index=True)

memoria = pd.read_excel('bancos/manual/memoria_calculo.xlsx',
                        sheet_name=['criança e adolescente', 'segurança alimentar'])

crianca = memoria['criança e adolescente'].rename(
    columns={'FUNCAO_COD': 'funcao_cod', 'SUBFUNCAO_COD': 'subfuncao_cod', 'NE/E': 'exclusiva'})
indice = float(Path('utils/volume1/indice_crianca_adolescente.txt').read_text())
gera_t26(fiscal_investimento, crianca[['funcao_cod', 'subfuncao_cod', 'exclusiva']], indice,
         DADOS / 'tabela26.txt')

gera_t30(investimento, DADOS / 'tabela30.txt')

gera_t37(fiscal_investimento, memoria['segurança alimentar']['ACAO_COD'], DADOS / 'tabela37.txt')

gera_t39(fiscal_investimento, acoes, DADOS / 'tabela39.txt')
