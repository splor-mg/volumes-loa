"""
Confere se orcamento_despesa_fonte_80_95.csv tem os mesmos valores das fontes 80 e 95 de orcamento_despesa.csv.
As divergências ficam em logs/logv7_divergencias_orcamento_despesa.csv
"""
import sys
import pandas as pd


orcamento = pd.read_csv('bancos/PPO/orcamento_despesa.csv', dtype=str)
orcamento = orcamento[orcamento['fonte_cod'].isin(['80', '95'])]
fonte_80_95 = pd.read_csv('bancos/PPO/orcamento_despesa_fonte_80_95.csv', dtype=str)

chave = [coluna for coluna in orcamento.columns if coluna != 'vlr_loa_desp']
comparacao = orcamento.merge(
    fonte_80_95[orcamento.columns],
    on=chave,
    how='outer',
    suffixes=('_orcamento', '_fonte_80_95'),
)
divergencias = comparacao[
    comparacao['vlr_loa_desp_orcamento'] != comparacao['vlr_loa_desp_fonte_80_95']
]

print('- Testando correspondência entre orcamento_despesa.csv e orcamento_despesa_fonte_80_95.csv')

if len(divergencias):
    divergencias.to_csv('logs/logv7_divergencias_orcamento_despesa.csv', index=False)
    print(
        f'Foram encontradas {len(divergencias)} divergências entre orcamento_despesa.csv '
        'e orcamento_despesa_fonte_80_95.csv. '
        'Ver logs/logv7_divergencias_orcamento_despesa.csv',
        file=sys.stderr,
    )
