import petl as etl

def test_qdd_fonte_95():
    qdd_fonte_95 = etl.fromxlsx("bancos/SISOR/BASE_QDD_FISCAL_FONTE_95.xlsx", sheet="base_qdd_fiscal")
    qdd_fiscal = etl.fromxlsx("bancos/SISOR/BASE_QDD_FISCAL.xlsx", sheet="BASE_QDD_FISCAL")
    qdd_fiscal = etl.selecteq(qdd_fiscal, 'FONTE', 95)

    keys = ['ANO', 'COD_ORGAO', 'ORGAO', 'PODER',
            'SITUACAO', 'COD_UO', 'UO', 'CATEGORIA',
            'GRUPO_DESPESA', 'MODALIDADE', 'ELEMENTO_DESPESA',
            'FONTE', 'IPU', 'SEQ_PROGTRAB', 'FUNCAO', 'SUB_FUNCAO',
            'PROGRAMA', 'IDENT_PROJATIV', 'PROJ_ATIV', 'AÇÃO', 'SUB_PROJETO',
            'IAG', 'NOME_ACAO', 'NOME_PROGRAMA'
    ]

    agg_fonte_95 = etl.aggregate(qdd_fonte_95, keys, sum, "VALOR FINAL (R$)", presorted=False).rename('value', 'VALOR_FINAL_95')
    agg_fiscal = etl.aggregate(qdd_fiscal, keys, sum, "VALOR FINAL (R$)", presorted=False).rename('value', 'VALOR_FINAL')

    comparison_table = etl.join(agg_fonte_95, agg_fiscal, key=keys)
    comparison_table = etl.addfield(comparison_table, 'diff', lambda rec: round(rec['VALOR_FINAL_95'] - rec["VALOR_FINAL"], 3) )

    comparison_diff = etl.selectne(comparison_table, 'diff', 0)

    assert etl.nrows(comparison_diff) == 0
