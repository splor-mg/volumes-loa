"""
Tabela 5: DEMONSTRATIVO DOS RECURSOS FINANCEIROS - DEMAIS RECURSOS
"""
import sys
import pandas as pd

from utils.python.funcoes import escreve_tabela, formatar_num_tabela

FUNFIP = '4711'
ORDINARIAS = [10, 11, 12, 15, 18, 19]
UOS_CASO_ESPECIAL = ['1091'] # mesma fonte em receita própria e repasse do tesouro, mas o valor NÃO deve ser desconsiderado em REPASSE DO TESOURO ESTADUAL, mas sim somado
CHAVE = ['uo_cod', 'fonte_cod', 'funcao_cod', 'categoria_cod']
VALORES = ['ordinario', 'vinculado', 'total']


def ajusta_despesa(despesa, repasse):
    """
    Devolve os recursos às UOs que financiam ações de outras UOs e os deduz das UOs financiadas,
    para que não sejam somados ou deduzidos duas vezes.
    """
    aviso = 'Warning: V2 T5 qdd_ajustado: '
    chave = ['uo_cod', 'funcao_cod', 'categoria_cod', 'grupo_cod', 'fonte_cod', 'ipu_cod', 'iag_cod']
    ajustado = despesa.groupby(chave, as_index=False)['vlr_loa_desp'].sum()

    ipus = set(repasse['ipu_cod']) - {2, 5}
    if ipus:
        print(aviso + f'IPU diferente de 2 e 5 em orcamento_repasse.csv: {ipus}', file=sys.stderr)
    financiadoras = repasse.loc[repasse['ipu_cod'] == 5, 'uo_financiadora_cod'].unique()
    if len(financiadoras) > 1:
        print(aviso + f'UOs com IPU 5 (esperado só o FUNFIP): {", ".join(financiadoras)}', file=sys.stderr)

    repasse = repasse.assign(categoria_cod=3 + (repasse['grupo_cod'] >= 4))
    funfip = (repasse['ipu_cod'] == 5) & (repasse['uo_financiadora_cod'] == FUNFIP)
    chave_repasse = ['categoria_cod', 'grupo_cod', 'fonte_cod', 'ipu_cod', 'iag_cod']
    financiadora = repasse[(repasse['ipu_cod'] == 2) | funfip]
    financiadora = financiadora.groupby(['uo_financiadora_cod'] + chave_repasse)['vlr_repasse'].sum()
    financiadora = financiadora.rename('vlr_loa_desp').reset_index()
    beneficiadas = repasse[funfip].groupby(['uo_beneficiada_cod'] + chave_repasse)['vlr_repasse'].sum()
    beneficiadas = beneficiadas.reset_index().rename(columns={'uo_beneficiada_cod': 'uo_cod'})

    # Na UO beneficiada pelo FUNFIP, sai a despesa com o mesmo grupo, fonte e IPU
    chave_funfip = ['uo_cod', 'grupo_cod', 'fonte_cod', 'ipu_cod']
    valor = beneficiadas.join(ajustado.groupby(chave_funfip)['vlr_loa_desp'].sum(), on=chave_funfip)
    valor['vlr_loa_desp'] = valor['vlr_loa_desp'].fillna(0)
    for linha in valor[valor['vlr_loa_desp'] != valor['vlr_repasse']].to_dict('records'):
        print(aviso + f'valor do FUNFIP para a UO {linha["uo_cod"]}, grupo {linha["grupo_cod"]}, fonte '
              f'{linha["fonte_cod"]} e IPU {linha["ipu_cod"]} diferente entre orcamento_despesa.csv '
              f'({linha["vlr_loa_desp"]:.0f}) e orcamento_repasse.csv ({linha["vlr_repasse"]:.0f}). '
              'O ajuste será feito do mesmo jeito.', file=sys.stderr)
    excluir = ajustado.set_index(chave_funfip).index.isin(beneficiadas.set_index(chave_funfip).index)
    ajustado = ajustado[~excluir]

    deduzido = despesa.loc[despesa['fonte_cod'].isin([42, 43])
                           & (despesa['ipu_cod'] == 5)
                           & despesa['uo_cod'].isin(beneficiadas['uo_cod']), 'vlr_loa_desp'].sum()
    deduzido += ajustado.loc[ajustado['ipu_cod'] == 2, 'vlr_loa_desp'].sum()
    if deduzido != financiadora['vlr_loa_desp'].sum():
        print(aviso + f'valor deduzido das UOs beneficiadas ({deduzido:.0f}) diferente do valor somado às '
              f'UOs financiadoras ({financiadora["vlr_loa_desp"].sum():.0f})', file=sys.stderr)

    financiadora = financiadora.rename(columns={'uo_financiadora_cod': 'uo_cod'})
    ajustado = pd.concat([ajustado[ajustado['ipu_cod'] != 2], financiadora])
    return ajustado.groupby(chave, as_index=False, dropna=False)['vlr_loa_desp'].sum()


def repasse_tesouro(uo_cod, receita, ajustado):
    """
    Despesa do QDD ajustado que não é coberta pela receita própria da UO.
    Devolve as linhas do repasse e se ele sai sem separar despesa corrente e de capital.
    """
    aviso = f'Warning: V2 T5: UO {uo_cod}: '
    caso_especial = uo_cod in UOS_CASO_ESPECIAL
    if receita.empty:
        return ajustado, caso_especial

    receita_fonte = receita.groupby('fonte_cod')['vlr_loa_rec'].sum()
    fontes = pd.concat([ajustado.groupby('fonte_cod')['vlr_loa_desp'].sum(), receita_fonte], axis=1)
    if fontes.isna().any(axis=1).all():
        print(aviso + 'nenhuma fonte da receita própria aparece no QDD ajustado. '
              'A correção segue como se não houvesse receita', file=sys.stderr)
    fontes = fontes.fillna(0).sort_index()
    com_receita = fontes['vlr_loa_rec'] > 0
    maior = fontes['vlr_loa_desp'] > fontes['vlr_loa_rec']
    ordinaria = fontes.index.isin(ORDINARIAS)
    ordinarias = fontes.index[maior & com_receita & ordinaria]
    vinculadas = fontes.index[maior & com_receita & ~ordinaria]
    partes = [ajustado[ajustado['fonte_cod'].isin(fontes.index[maior & ~com_receita])]]

    # Fonte ordinária com receita própria
    if len(ordinarias):
        if (ordinarias != 10).any():
            print(aviso + 'a correção da fonte ordinária com receita própria considera só a fonte 10. '
                  'Ela será feita mesmo assim, mas pode dar erro', file=sys.stderr)
        subtrair = fontes.loc[ordinarias, 'vlr_loa_rec'].sum()
        ordinario = ajustado[ajustado['fonte_cod'].isin(ordinarias)]
        ordinario = ordinario.groupby(CHAVE, as_index=False, dropna=False)['vlr_loa_desp'].sum()
        descricoes = receita.loc[receita['fonte_cod'].isin(ordinarias), 'receita_desc']
        if descricoes.str.contains('FUNDO ESTADUAL DE SA.DE|141/2012', case=False).all():
            funcao10 = ordinario.loc[ordinario['funcao_cod'] == 10, 'vlr_loa_desp'].sum()
            if funcao10 != subtrair:
                print(aviso + f'despesa da função 10 ({funcao10:.0f}) diferente da receita do FES '
                      f'({subtrair:.0f}). A correção será feita mesmo assim', file=sys.stderr)
            # Função 10 com despesa corrente e de capital: não se sabe de qual deduzir a receita
            fonte10 = ordinario['fonte_cod'] == 10
            if (fonte10 & (ordinario['funcao_cod'] == 10)).sum() > 1:
                ordinario.loc[fonte10 & (ordinario['categoria_cod'] == 3), 'funcao_cod'] = 0
                caso_especial = True
            receita_uo = receita_fonte[receita_fonte.index.isin(ordinarias)].rename_axis('receita_fonte_cod')
            receita_uo = receita_uo.reset_index().assign(uo_cod=uo_cod, funcao_cod=10)
            ordinario = ordinario.merge(receita_uo, on=['uo_cod', 'funcao_cod'], how='outer')
            ordinario['vlr_loa_desp'] -= ordinario['vlr_loa_rec'].fillna(0)
        elif caso_especial:
            corrente = {'uo_cod': uo_cod, 'fonte_cod': 10, 'vlr_loa_desp': -subtrair}
            ordinario = pd.concat([ordinario, pd.DataFrame([corrente])], ignore_index=True)
        else:
            print(aviso + 'receita de fonte ordinária fora do FES e UO fora do caso especial. Codificar '
                  'nova solução', file=sys.stderr)
        partes.append(ordinario)

    # Fonte vinculada com receita própria: a receita sai proporcionalmente da despesa
    if len(vinculadas):
        print(aviso + f'fontes vinculadas com despesa maior que a receita: {", ".join(map(str, vinculadas))}',
              file=sys.stderr)
        vinculado = ajustado[ajustado['fonte_cod'].isin(vinculadas)]
        vinculado = vinculado.groupby(CHAVE, as_index=False, dropna=False)['vlr_loa_desp'].sum()
        soma = vinculado.groupby(['categoria_cod', 'fonte_cod'])['vlr_loa_desp'].transform('sum')
        receita_vinculada = vinculado['fonte_cod'].map(fontes['vlr_loa_rec'])
        vinculado['vlr_loa_desp'] -= vinculado['vlr_loa_desp'] / soma * receita_vinculada
        partes.append(vinculado)

    return pd.concat(partes), caso_especial


def gera_tabela5(uo_cod, receita, ajustado, repasse, total_qdd, caminho):
    aviso = f'Warning: V2 T5: UO {uo_cod}: '

    # 2. RECURSOS REPASSADOS PELO TESOURO ESTADUAL
    tesouro, caso_especial = repasse_tesouro(uo_cod, receita, ajustado)
    subtotal2 = {'especificacao': 'SUBTOTAL 2', 'total': float('nan')}
    partes = []
    if len(tesouro):
        capital = tesouro['categoria_cod'].notna() & (tesouro['categoria_cod'] != 3)
        especificacao = tesouro['categoria_cod'].map({3: 'DESPESAS CORRENTES'})
        especificacao = especificacao.mask(capital, 'DESPESAS DE CAPITAL')
        tipo = tesouro['fonte_cod'].isin(ORDINARIAS).map({True: 'ordinario', False: 'vinculado'})
        tesouro = tesouro.assign(especificacao=especificacao, tipo=tipo)
        tesouro = tesouro.groupby(['especificacao', 'tipo'], dropna=False)['vlr_loa_desp'].sum().unstack()
        tesouro = tesouro.reindex(columns=VALORES[:2]).fillna(0).reset_index()
        tesouro['total'] = tesouro['vinculado'] + tesouro['ordinario']
        subtotal2 |= tesouro[VALORES].sum().to_dict()
        if not caso_especial:
            partes.append(tesouro)
    partes.append(pd.DataFrame([subtotal2]))

    # 3. RECURSOS RECEBIDOS e 4. RECURSOS REPASSADOS A ÓRGÃOS E ENTIDADES DO ORÇAMENTO FISCAL
    subtotais = []
    for numero, titulo, uo, outra in [(3, 'RECEBIDOS DE', 'beneficiada', 'financiadora'),
                                      (4, 'REPASSADOS A', 'financiadora', 'beneficiada')]:
        linhas = repasse[repasse[f'uo_{uo}_cod'] == uo_cod]
        linhas = linhas.groupby(linhas[f'uo_{outra}_cod'] + ' - ' + linhas[f'uo_{outra}_nome'])['vlr_repasse']
        linhas = linhas.sum().rename('total').rename_axis('especificacao').reset_index()
        subtotais.append(linhas['total'].sum() if len(linhas) else float('nan'))
        partes += [pd.DataFrame({'especificacao': [f'{numero}. RECURSOS {titulo} ÓRGÃOS E ENTIDADES DO '
                                                   'ORÇAMENTO FISCAL']}),
                   linhas,
                   pd.DataFrame({'especificacao': [f'SUBTOTAL {numero}'], 'total': [subtotais[-1]]})]

    # 5. RECEITA TOTAL e 6. RECEITA DISPONÍVEL
    subtotal1 = receita['vlr_loa_rec'].sum() if len(receita) else float('nan')
    receita_total = pd.Series([subtotal1, subtotal2['total'], subtotais[0]]).sum()
    disponivel = pd.Series([receita_total, -subtotais[1]]).sum()
    if disponivel <= 0:
        print(aviso + f'receita disponível negativa ou zero: {disponivel:.0f}', file=sys.stderr)
    if disponivel != total_qdd:
        print(aviso + f'receita disponível ({disponivel:.0f}) diferente do total de orcamento_despesa.csv '
              f'({total_qdd:.0f})', file=sys.stderr)
    partes.append(pd.DataFrame({'especificacao': ['5. RECEITA TOTAL (1 + 2 + 3)',
                                                  '6. RECEITA DISPONÍVEL (5 - 4)'],
                                'total': [receita_total, disponivel]}))

    tabela = pd.concat([parte for parte in partes if len(parte)], ignore_index=True)
    tabela = tabela.reindex(columns=['especificacao'] + VALORES).fillna({'especificacao': ''})
    tabela[VALORES] = tabela[VALORES].apply(formatar_num_tabela)
    escreve_tabela(tabela, caminho)
