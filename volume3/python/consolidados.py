"""
Quadros consolidados do volume 3, também lidos pelo volume 1:
- t1_investimentos_empresa.txt: INVESTIMENTOS POR EMPRESA SEGUNDO FONTES DE RECURSO
- t2_investimentos_empresa_detalhamento.txt: INVESTIMENTOS POR EMPRESA SEGUNDO O DETALHAMENTO DOS INVESTIMENTOS
- t3_investimentos_projeto_atividade.txt: INVESTIMENTOS SEGUNDO FUNÇÕES, SUBFUNÇÕES E PROGRAMAS POR PROJETOS E ATIVIDADES
"""
import sys
import pandas as pd

from utils.python.funcoes import escreve_tabela, formatar_num, formatar_num_tabela

FONTES = [('111', 'tesouro_ordinario'),
          ('112', 'tesouro_vinculado'),
          ('12', 'outras_entidades'),
          ('2', 'operacao_credito'),
          ('3', 'alienacao'),
          ('4', 'convenios'),
          ('5', 'recursos_proprios'),
          ('6', 'outras_origens')]

CATEGORIAS = ['4610', '4810', '4510', '4710']


def gera_consolidado1(qdd, caminho):
    fonte = pd.Series('', index=qdd.index)
    for prefixo, coluna in FONTES:
        fonte[qdd['fonte_invest_cod'].str.startswith(prefixo)] = coluna

    sem_fonte = qdd.loc[fonte == '', 'fonte_invest_cod'].unique()
    if len(sem_fonte):
        print('Warning: Fonte(s) sem coluna em INVESTIMENTOS POR EMPRESA SEGUNDO '
              f'FONTES DE RECURSO: {", ".join(sem_fonte)}', file=sys.stderr)

    t1 = qdd[fonte != ''].groupby(['empresa', fonte])['vlr_loa_desp'].sum()
    t1 = t1.unstack(fill_value=0).reindex(columns=[coluna for _, coluna in FONTES], fill_value=0)
    t1['total'] = t1.sum(axis=1)
    t1.loc['TOTAL'] = t1.sum()

    escreve_tabela(t1.apply(formatar_num_tabela).reset_index(names='orgaos'), caminho)


def gera_consolidado2(qdd, caminho):
    categoria = qdd['categoria_invest_cod'].isin(CATEGORIAS)

    sem_categoria = qdd.loc[~categoria, 'categoria_invest_desc'].unique()
    if len(sem_categoria):
        print('Warning: Categoria(s) sem coluna em INVESTIMENTOS POR EMPRESA SEGUNDO '
              f'O DETALHAMENTO DOS INVESTIMENTOS: {", ".join(sem_categoria)}', file=sys.stderr)

    t2 = qdd[categoria].groupby(['empresa', 'categoria_invest_cod'])['vlr_loa_desp'].sum()
    t2 = t2.unstack(fill_value=0).reindex(columns=CATEGORIAS, fill_value=0)
    t2.loc['TOTAL'] = t2.sum()
    t2['total'] = t2.sum(axis=1)

    escreve_tabela(t2.apply(formatar_num_tabela).reset_index(names='empresas'), caminho)


def gera_consolidado3(qdd, caminho):
    identificador = qdd['identificador_cod']
    base = qdd[(identificador == 3) | (identificador >= 6)]
    base = base.assign(projeto=base['vlr_loa_desp'].where(base['identificador_cod'] == 3, 0),
                       atividade=base['vlr_loa_desp'].where(base['identificador_cod'] >= 6, 0))

    niveis = [(['funcao_cod'], 'funcao_desc'),
              (['funcao_cod', 'subfuncao_cod'], 'subfuncao_desc'),
              (['funcao_cod', 'subfuncao_cod', 'programa_cod'], 'programa_desc')]
    partes = []
    for chave, descricao in niveis:
        soma = base.groupby(chave + [descricao], as_index=False, dropna=False)
        soma = soma[['projeto', 'atividade']].sum()
        partes.append(soma.rename(columns={descricao: 'especificacao'}))

    t3 = pd.concat(partes, ignore_index=True)
    codigos = ['funcao_cod', 'subfuncao_cod', 'programa_cod']
    t3[codigos] = t3[codigos].fillna(0).astype(int)
    t3 = t3.sort_values(codigos, kind='stable')

    t3['codigo'] = (t3['funcao_cod'].map('{:02d}'.format)
                    + '.' + t3['subfuncao_cod'].map('{:03d}'.format)
                    + '.' + t3['programa_cod'].map('{:03d}'.format))

    total = {'especificacao': 'TOTAL',
             'projeto': base['projeto'].sum(),
             'atividade': base['atividade'].sum()}
    t3 = pd.concat([t3, pd.DataFrame([total])], ignore_index=True)
    t3['total'] = t3['projeto'] + t3['atividade']
    for coluna in ['projeto', 'atividade', 'total']:
        t3[coluna] = formatar_num(t3[coluna])

    escreve_tabela(t3[['codigo', 'especificacao', 'projeto', 'atividade', 'total']], caminho)
