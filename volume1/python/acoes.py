"""
Tabelas do volume 1 por ação, a partir de orcamento_despesa.csv e orcamento_despesa_investimento.csv:
- T26: RECURSOS APLICADOS EM AÇÕES VOLTADAS PARA A CRIANÇA E O ADOLESCENTE
- T30: INVESTIMENTOS SEGUNDO AS FUNÇÕES
- T37: RECURSOS APLICADOS NA POLÍTICA DE SEGURANÇA ALIMENTAR E NUTRICIONAL SUSTENTÁVEL
- T39: RECURSOS APLICADOS NA POLÍTICA DE ATENDIMENTO À MULHER VÍTIMA DE VIOLÊNCIA
"""
import sys
import pandas as pd

from utils.python.funcoes import escreve_tabela, formatar_num

CHAVE = ['uo_cod', 'funcao_cod', 'subfuncao_cod', 'programa_cod', 'acao_cod', 'acao_desc']
ORDEM = ['exclusiva', 'uo_cod', 'funcao_cod', 'subfuncao_cod', 'programa_cod', 'acao_cod']


def funcional(tabela, largura_funcao):
    acao = tabela['acao_cod'].astype(str)
    return (tabela['funcao_cod'].astype(str).str.zfill(largura_funcao)
            + '.' + tabela['subfuncao_cod'].map('{:03d}'.format)
            + '.' + tabela['programa_cod'].map('{:03d}'.format)
            + '.' + acao.str[0] + '.' + acao.str[1:4])


def gera_t26(despesa, memoria, indice, caminho):
    tabela = despesa.merge(memoria, on=['funcao_cod', 'subfuncao_cod'])
    tabela = tabela.groupby(CHAVE + ['exclusiva'], sort=False, as_index=False)['vlr_loa_desp'].sum()

    # Ações não exclusivas: valor proporcional à população de crianças e adolescentes
    nao_exclusiva = tabela['exclusiva'] == 'NE'
    tabela.loc[nao_exclusiva, 'vlr_loa_desp'] *= indice

    tabela['funcional'] = funcional(tabela, 1)
    tabela = tabela.sort_values(ORDEM, kind='stable')

    total = {'uo_cod': 'TOTAL', 'vlr_loa_desp': tabela['vlr_loa_desp'].sum()}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)
    tabela['vlr_loa_desp'] = formatar_num(tabela['vlr_loa_desp'].round())

    escreve_tabela(tabela[['uo_cod', 'funcional', 'acao_desc', 'vlr_loa_desp', 'exclusiva']], caminho)


def gera_t30(investimento, acoes, caminho):
    funcoes = acoes[['funcao_cod', 'funcao_desc']].drop_duplicates()
    tabela = investimento.groupby('funcao_cod', as_index=False)['vlr_loa_desp'].sum()

    sem_nome = sorted(set(tabela['funcao_cod']) - set(funcoes['funcao_cod']))
    if sem_nome:
        print(f'Warning: T30_INVESTIMENTOS_SEGUNDO_FUNCOES: O código da função {", ".join(map(str, sem_nome))} '
              'não existe em planejamento_acao.csv, ou seja, não é possível lhe atribuir um nome.',
              file=sys.stderr)

    tabela = tabela.merge(funcoes).sort_values('funcao_cod', kind='stable')
    tabela['porcent'] = (tabela['vlr_loa_desp'] / tabela['vlr_loa_desp'].sum() * 100).round(3)

    total = {'funcao_desc': 'TOTAL', 'vlr_loa_desp': tabela['vlr_loa_desp'].sum(), 'porcent': tabela['porcent'].sum()}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)
    tabela['vlr_loa_desp'] = formatar_num(tabela['vlr_loa_desp'])

    porcent = tabela['porcent'].round(2)
    casas = max(len(f'{valor:.2f}'.rstrip('0').split('.')[1]) for valor in porcent)
    tabela['porcent'] = porcent.map(lambda valor: f'{valor:.{casas}f}'.replace('.', ','))

    escreve_tabela(tabela[['funcao_desc', 'vlr_loa_desp', 'porcent']], caminho)


def gera_t37(despesa, memoria, caminho):
    tabela = despesa[despesa['acao_cod'].isin(memoria)]
    tabela = tabela.groupby(CHAVE[1:], sort=False, as_index=False)['vlr_loa_desp'].sum()
    tabela['funcional'] = funcional(tabela, 2)
    tabela = tabela.sort_values('funcional', kind='stable')

    total = {'funcional': 'TOTAL', 'vlr_loa_desp': tabela['vlr_loa_desp'].sum()}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)
    tabela['vlr_loa_desp'] = formatar_num(tabela['vlr_loa_desp'].round())

    escreve_tabela(tabela[['funcional', 'acao_desc', 'vlr_loa_desp']], caminho)


def gera_t39(despesa, acoes, caminho):
    chave = ['uo_cod', 'acao_cod', 'funcao_cod', 'subfuncao_cod']
    memoria = acoes.rename(columns={'uo_acao_cod': 'uo_cod'})[chave + ['politica_mulheres']]
    memoria = memoria.drop_duplicates(chave)
    tabela = despesa.merge(memoria, how='left')
    tabela['exclusiva'] = tabela['politica_mulheres'].map({'DIRETAMENTE RELACIONADA': 'DR',
                                                           'INDIRETAMENTE RELACIONADA': 'IR'})
    tabela = tabela.dropna(subset='exclusiva')
    tabela = tabela.groupby(CHAVE + ['exclusiva'], sort=False, as_index=False)['vlr_loa_desp'].sum()
    tabela['funcional'] = funcional(tabela, 1)
    tabela = tabela.sort_values(ORDEM, kind='stable')

    # Totais de DR e IR depois de cada grupo, quando DR vem antes de IR
    dr = tabela[tabela['exclusiva'] == 'DR']
    ir = tabela[tabela['exclusiva'] == 'IR']
    total = pd.DataFrame([{'uo_cod': 'TOTAL', 'vlr_loa_desp': tabela['vlr_loa_desp'].sum()}])
    if tabela['exclusiva'].iloc[-1] == 'IR':
        total_dr = pd.DataFrame([{'uo_cod': 'TOTAL DR', 'vlr_loa_desp': round(dr['vlr_loa_desp'].sum())}])
        total_ir = pd.DataFrame([{'uo_cod': 'TOTAL IR', 'vlr_loa_desp': round(ir['vlr_loa_desp'].sum())}])
        tabela = pd.concat([dr, total_dr, ir, total_ir, total], ignore_index=True)
    else:
        tabela = pd.concat([tabela, total], ignore_index=True)
    tabela['vlr_loa_desp'] = formatar_num(tabela['vlr_loa_desp'].round())

    escreve_tabela(tabela[['uo_cod', 'funcional', 'acao_desc', 'vlr_loa_desp', 'exclusiva']], caminho)
