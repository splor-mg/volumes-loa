"""
Tabelas do volume 1 a partir de orcamento_receita.csv:
- T2: DEMONSTRATIVO DA RECEITA CORRENTE FISCAL
- T3: DEMONSTRATIVO DA RECEITA E DESPESA SEGUNDO AS CATEGORIAS ECONÔMICAS
- T7: QUADRO GERAL DA RECEITA
- T9: DEMONSTRATIVO DA RECEITA ORÇAMENTÁRIA CORRENTE ORDINÁRIA
- T18: DEMONSTRATIVO DA APLICAÇÃO DE RECURSOS NAS AÇÕES E SERVIÇOS PÚBLICOS DE SAÚDE
- T28C: RECEITA PREVISTA NA LOA DOS PROGRAMAS FINANCIADOS COM RECURSOS DA UNIÃO
"""
import sys

import pandas as pd

from utils.python.formata_texto import corrige_caracteres_especiais
from utils.python.funcoes import escreve_tabela, formatar_num, formatar_num_contabil, nat
from utils.python.quadro_receita import VALORES, gera_quadro_receita
from volume1.python.despesa import CATEGORIAS, FONTES_CONSIDERADAS, FONTES_UNIAO, sem_acento

# Parâmetros do T9
REC_ORDINARIO = [10, 15, 19]


def gera_t2(receita, caminho):
    corrente = receita.loc[nat(receita['receita_cod'], 1), 'vlr_loa_rec'].sum()
    deducao = receita.loc[nat(receita['receita_cod'], 9), 'vlr_loa_rec'].sum()
    tabela = pd.DataFrame({
        'espec': ['RECEITAS CORRENTES', 'DEDUÇÃO DA RECEITA CORRENTE', 'RECEITA CORRENTE FISCAL'],
        'valor': [corrente, deducao, corrente + deducao],
    })
    tabela['valor'] = formatar_num_contabil(tabela['valor'])

    escreve_tabela(tabela, caminho)


def gera_t3(receita, despesa, classificacao, grupos, caminho, caminho_resumo):
    base = despesa[despesa['modalidade_cod'] != 91]
    categoria = base['categoria_cod'].astype(str)
    grupo_desc = base['grupo_cod'].map({codigo: sem_acento(texto) for codigo, texto in grupos.items()})

    # Despesa: categorias (30, 40, 90), na ordem em que aparecem no banco, e grupos (31, 32...)
    chave = categoria + '0. ' + base['categoria_cod'].map(CATEGORIAS).fillna('IGN')
    categorias = base.groupby(chave.rename('despesa_desc'), sort=False)['vlr_loa_desp'].sum()
    chave = categoria + base['grupo_cod'].astype(str) + '. ' + grupo_desc
    grupos_desp = base.groupby(chave.rename('despesa_desc'))['vlr_loa_desp'].sum()

    desp = pd.concat([grupos_desp.rename('vl_desp').reset_index(),
                      categorias.rename('vl_desp_total').reset_index()])
    desp = desp.sort_values('despesa_desc', kind='stable')
    desp = desp[~desp['despesa_desc'].str.startswith('99')]
    inicio = desp['despesa_desc'].str.startswith('3').map({True: '0', False: '4'})
    desp['ordem'] = inicio + (desp.groupby(inicio).cumcount() + 1).astype(str)

    rec_corrente = receita.loc[nat(receita['receita_cod'], 1, 9), 'vlr_loa_rec'].sum()
    rec_capital = receita.loc[nat(receita['receita_cod'], 2), 'vlr_loa_rec'].sum()
    desp_corrente = base.loc[base['categoria_cod'] == 3, 'vlr_loa_desp'].sum()
    desp_capital = base.loc[base['categoria_cod'].isin([4, 9]), 'vlr_loa_desp'].sum()
    deficit = rec_corrente - desp_corrente
    rec_total = receita.loc[~nat(receita['receita_cod'], 7), 'vlr_loa_rec'].sum()

    totais = pd.DataFrame({
        'despesa_desc': ['Resultado do Orçamento Corrente', 'TOTAL', 'TOTAL'],
        'vl_desp_total': [deficit, desp_corrente + deficit, desp_capital],
        'ordem': ['10', '20', '50'],
    })
    desp = pd.concat([desp, totais])
    desp['despesa_desc'] = corrige_caracteres_especiais(
        desp['despesa_desc'].str.replace(r'\d{2}\.(.+)', r'\1', regex=True))

    # Receita: categorias (1, 2, 9) e origens (11, 12...), na ordem do código, sem intraorçamentárias
    rec = receita[~nat(receita['receita_cod'], 7)]
    codigo = rec['receita_cod']
    categorias_rec = rec.groupby(codigo.str[0].str.ljust(13, '0'))['vlr_loa_rec'].sum()
    origens = rec[~nat(codigo, 9)]
    origens = origens.groupby(origens['receita_cod'].str[:2].str.ljust(13, '0'))['vlr_loa_rec'].sum()

    rec = pd.concat([categorias_rec.rename('vl_rec_total'), origens.rename('vl_rec')], axis=1)
    rec = rec.sort_index().rename_axis('receita_cod').reset_index()
    rec['cod_texto'] = rec['receita_cod'].str.replace(r'(.{4})(..)(.)(.)(..)(...)', r'\1.\2.\3.\4.\5.\6',
                                                      regex=True)
    rec = rec.merge(classificacao, how='left')
    inicio = rec['receita_cod'].str[0].map({'1': '0', '2': '4', '9': '1'})
    rec['ordem'] = inicio + (rec.groupby(inicio).cumcount() + 1).astype(str)
    rec.loc[nat(rec['receita_cod'], 9), ['receita_desc', 'ordem']] = ['DEDUÇÃO DA RECEITA CORRENTE', '10']

    totais = pd.DataFrame({
        'receita_desc': ['TOTAL', 'RESULTADO DO ORÇAMENTO CORRENTE', 'TOTAL'],
        'vl_rec_total': [rec_corrente, deficit, rec_capital + deficit],
        'ordem': ['20', '30', '50'],
    })
    rec = pd.concat([rec, totais])

    tabela = rec.merge(desp, on='ordem', how='outer').sort_values('ordem')
    valores = ['vl_rec', 'vl_rec_total', 'vl_desp', 'vl_desp_total']
    tabela[valores] = tabela[valores].apply(formatar_num_contabil)
    colunas = ['ordem', 'receita_desc', 'vl_rec', 'vl_rec_total', 'despesa_desc', 'vl_desp', 'vl_desp_total']
    escreve_tabela(tabela[colunas], caminho)

    # Resumo
    categorias['99.TOTAL'] = categorias.sum()
    resumo_desp = pd.DataFrame({
        'despesa_desc': categorias.index.str.replace(r'\d{2}\.(.+)', r'\1', regex=True).str.upper(),
        'vl_desp_total': categorias.to_numpy(),
        'ordem': range(1, len(categorias) + 1),
    })
    resumo_rec = pd.DataFrame({
        'receita_desc': ['RECEITAS CORRENTES', 'RECEITAS DE CAPITAL', 'TOTAL', 'DÉFICIT'],
        'vl_rec_total': [rec_corrente, rec_capital, rec_total, rec_total - categorias['99.TOTAL']],
        'ordem': [1, 2, 4, 5],
    })

    resumo = resumo_rec.merge(resumo_desp, on='ordem', how='outer').sort_values('ordem')
    valores = ['vl_rec_total', 'vl_desp_total']
    resumo[valores] = resumo[valores].apply(formatar_num_contabil)
    escreve_tabela(resumo[['ordem', 'receita_desc', 'vl_rec_total', 'despesa_desc', 'vl_desp_total']],
                   caminho_resumo)


def gera_t7_t9(receita, classificacao, nome, caminho):
    tabela = gera_quadro_receita(receita, classificacao, f'Warning: {nome}: ')

    total = {'receita_desc': 'TOTAL', 'valor_categoria': receita['vlr_loa_rec'].sum()}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)
    tabela[VALORES] = tabela[VALORES].apply(
        lambda coluna: formatar_num(coluna).str.replace(r' *-(.+)', r'(\1)', regex=True))

    escreve_tabela(tabela, caminho)


def gera_t18(receita, despesa, sumario, caminho):
    nome = 'T18_DCGF_Demonst_Aplicacao_Recursos_Acoes_Servicos_Publicos_Saude'

    # A. Receita: as colunas de regras também marcam as dedutoras (9...), que ficam de fora
    rec = receita[~nat(receita['receita_cod'], 9)]
    fonte20 = rec['fonte_cod'] == 20
    lc194 = nat(rec['receita_cod'], 17196201)
    ibs_municipios = rec['ibs'] & (rec['receita_cod'].str[9] == '2')

    # Em cada nível, uma receita fica na última linha em que se encaixa
    niveis = [
        (1, [(100, 'I - RECEITA DE IMPOSTOS', rec[['irrf', 'ipva', 'itcd', 'icms', 'ibs']].any(axis=1)),
             (200, 'II - RECEITA DE TRANSFERÊNCIAS CONSTITUCIONAIS E LEGAIS',
              rec[['fpe_principal', 'lei_kandir_principal', 'ipi_principal']].any(axis=1) | lc194)]),
        (1, [(300, 'III - DEDUÇÕES DE TRANSFERÊNCIAS CONSTITUCIONAIS AOS MUNICÍPIOS',
              fonte20 & (rec[['icms', 'ipva', 'ipi_principal', 'itcd']].any(axis=1) | ibs_municipios | lc194))]),
        (2, [(310, 'Parcela do ICMS Repassada aos Municípios', rec['icms'] & fonte20),
             (320, 'Parcela do IPVA Repassada aos Municípios', rec['ipva'] & fonte20),
             (330, 'Parcela da Cota Parte do IPI Exportação Repassada aos Municípios',
              rec['ipi_principal'] & fonte20),
             (340, 'Parcela do IBS Repassada aos Municípios', ibs_municipios),
             (350, 'Parcela do ITCD Repassada aos Municípios', rec['itcd'] & fonte20),
             (360, 'Parcela da LC nº 194/2022 Repassada aos Municípios', lc194 & fonte20)]),
        (2, [(110, 'ITCD Principal', rec['itcd_principal']),
             (120, 'ICMS Principal', rec['icms_principal']),
             (130, 'IPVA Principal', rec['ipva_principal']),
             (140, 'IBS Principal', rec['ibs_principal']),
             (150, 'IRRF', rec['irrf']),
             (160, 'Multas, Juros de Mora e Outros Encargos dos Impostos',
              rec[['icms_mjm', 'itcd_mjm', 'ipva_mjm']].any(axis=1)),
             (170, 'Dívida Ativa dos Impostos', rec[['icms_da', 'itcd_da', 'ipva_da']].any(axis=1)),
             (180, 'Multas, Juros de Mora e Outro Encargos da Dívida Ativa',
              rec[['icms_mjm_da', 'ipva_mjm_da']].any(axis=1)),
             (210, 'Cota Parte FPE', rec['fpe_principal']),
             (220, 'Cota Parte IPI Exportação', rec['ipi_principal']),
             (230, 'ICMS Desoneração - LC nº 87/1996', rec['lei_kandir_principal']),
             (240, 'Compensação Perdas Arrecadação ICMS - LC nº 194/2022', lc194)]),
    ]
    linhas = []
    for nvl, regras in niveis:
        ordem = pd.Series(0, index=rec.index)
        for numero, _, filtro in regras:
            ordem[filtro] = numero
        for numero, espec, _ in regras:
            if (ordem == numero).any():
                linhas.append([numero, espec, nvl, rec.loc[ordem == numero, 'vlr_loa_rec'].sum()])
    asps = pd.DataFrame(linhas, columns=['ordem', 'espec', 'nvl', 'VL_LOA']).sort_values('ordem')

    total = asps.loc[asps['ordem'].isin([100, 200]), 'VL_LOA'].sum()
    total -= asps.loc[asps['ordem'] == 300, 'VL_LOA'].sum()
    total_asps = receita.loc[receita['asps'], 'vlr_loa_rec'].sum()
    if round(total, 2) != round(total_asps, 2):
        print(f'Warning: {nome}: Receita asps (I + II - III) {total:,.0f} é diferente da soma da coluna asps '
              f'de orcamento_receita.csv {total_asps:,.0f}'.replace(',', '.'), file=sys.stderr)

    a = pd.DataFrame([['A. TOTAL DAS RECEITAS PARA APURAÇÃO DA ASPS (I + II - III)', 0, total]],
                     columns=['espec', 'nvl', 'VL_LOA'])
    asps = pd.concat([a, asps.drop(columns='ordem')])

    # B. Despesa, com o nome da UO de volume2/data/sumario.txt
    uos = dict(zip(sumario['uo_cod'], sumario['uo'].str.replace(r'^[0-9.]+ - ', '', regex=True)))
    sem_nome = despesa.loc[~despesa['uo_cod'].isin(uos), 'uo_cod'].unique()
    if len(sem_nome):
        sys.exit(f"{nome}: Há UO's que não possuem seu descritivo em volume2/data/sumario.txt. "
                 f'É o caso de: {", ".join(sem_nome)}')

    desp = despesa[despesa['asps']]
    cod = (desp['uo_cod'] + '.' + desp['funcao_cod'].astype(str)).rename('cod')
    parte_b = desp.groupby([cod, desp['uo_cod'].map(uos).rename('espec')])['vlr_loa_desp'].sum()
    parte_b = parte_b.rename('VL_LOA').reset_index()
    parte_b['nvl'] = 1
    b = pd.DataFrame([['B. DESPESA COM SAÚDE', 0, parte_b['VL_LOA'].sum()]], columns=['espec', 'nvl', 'VL_LOA'])

    # C. Percentual B/A
    percentual = round(b.loc[0, 'VL_LOA'] * 100 / total, 2)
    c = pd.DataFrame([[
        'C - Percentual de Aplicação de Recursos nas Ações e Serviços Públicos de Saúde - B/A Aplicação Mínima 12,00%',
        0, f'{percentual:.2f}'.replace('.', ',') + '\\%']], columns=['espec', 'nvl', 'VL_LOA'])

    asps['espec'] = corrige_caracteres_especiais(asps['espec'])
    b['espec'] = corrige_caracteres_especiais(b['espec'])
    c['espec'] = corrige_caracteres_especiais(c['espec'])
    tabela = pd.concat([asps, b, parte_b], ignore_index=True)
    tabela['VL_LOA'] = formatar_num(tabela['VL_LOA'])
    tabela = pd.concat([tabela, c], ignore_index=True)

    escreve_tabela(tabela[['espec', 'nvl', 'VL_LOA', 'cod']], caminho)


def gera_t28c(receita, caminho):
    tabela = receita[~nat(receita['receita_cod'], 999) & receita['fonte_cod'].isin(FONTES_UNIAO)]
    tabela = tabela.groupby(['receita_cod', 'receita_desc'], sort=False, as_index=False)['vlr_loa_rec'].sum()
    tabela = tabela.sort_values('receita_cod', kind='stable')
    tabela['cod_texto'] = tabela['receita_cod'].str.replace(r'(.{4})(..)(.)(.)(..)(...)', r'\1.\2.\3.\4.\5.\6',
                                                            regex=True)

    total = {'receita_desc': 'TOTAL', 'vlr_loa_rec': tabela['vlr_loa_rec'].sum()}
    tabela = pd.concat([tabela, pd.DataFrame([total])], ignore_index=True)
    tabela['vlr_loa_rec'] = formatar_num(tabela['vlr_loa_rec'])
    tabela['fonte_exec'] = ''
    tabela.loc[0, 'fonte_exec'] = FONTES_CONSIDERADAS

    escreve_tabela(tabela[['cod_texto', 'receita_desc', 'vlr_loa_rec', 'fonte_exec']], caminho)
