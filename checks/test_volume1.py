from .report import Report

def test_volume1_t2():
    report = Report('T2_DCGF_DEMONSTRATIVO_RECEITA_CORRENTE_FISCAL', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t3():
    report = Report('T3_DCGF_Demonstrativo_Receita_Despesa_Segundo_Categorias_Economicas', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t4():
    report = Report('T4_DEMONSTRATIVO_DESPESA_POR_ORGAOS_ENTIDADES_SEGUNDO_GRUPOS_DESPESA', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t5():
    report = Report('T5_DEMONSTRATIVO_CONSOLIDADO_CATEGORIA_PESSOAL', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t6():
    report = Report('T6_DCGF_Demonstrativo_Evolucao_Receita_por_Categoria_Economica', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t7():
    report = Report('T7_QUADRO_GERAL_DA_RECEITA', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t8():
    report = Report('T8_DCGF_RECEITA_CORRENTE_LIQUIDA', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t9():
    report = Report('T9_DEMONSTRATIVO_RECEITA_ORCAMENTARIA_CORRENTE_ORDINARIA', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t12():
    report = Report('T12_DCGF_Demonstrativo_Evolucao_Despesa_Categoria_Economica', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t13():
    report = Report('T13_DCGF_Demonstrativo_Consolidado_Despesa', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t14():
    report = Report('T14_DEMONSTRATIVO_DESPESA_FUNCAO_SUBFUNCAO_PROGRAMA_CONFORME_VINCULO_COM_RECURSOS', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t15():
    report = Report('T15_PROGRAMA_TRABALHO_GOVERNO', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t16():
    report = Report('T16_DCGF_Demons_Aplicacao_Recursos_Manut_Desenv_Ensino', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t17():
    report = Report('T17_DCGF_Demonst_Aplicacao_Recursos_Progr_Saude_Investim', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t18():
    report = Report('T18_DCGF_Demonst_Aplicacao_Recursos_Acoes_Servicos_Publicos_Saude', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t19():
    report = Report('T19_DCGF_Demonstrativo_Aplicacao_Recursos_Amparo_Fomento_Pesquisa', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t20():
    report = Report('T20A_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_LRF', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t20():
    report = Report('T20B_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_LRF', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t23():
    report = Report('T23_DCGF_Demonstrativo_do_Servico_da_divida_publica', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t25():
    report = Report('T25_DCGF_Demonstrativo_Aplicacao_Recursos_FUNDEB', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t26():
    report = Report('T26_DCGF_DEMONSTRATIVO_RECURSOS_APLICADOS_ACOES_PARA_CRIANCA_E_ADOLESCENTE', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t27():
    report = Report('T27_DCGF_Demonst_Despesas_UGEPREVI', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t28():
    report = Report('T28_DCGF_PT1_Receita_prevista_e_realizada', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t28():
    report = Report('T28_DCGF_PT2_Despesa_prevista_e_realizada', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t28():
    report = Report('T28_DCGF_PT3_Receita_prevista_LOA', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t28():
    report = Report('T28_DCGF_PT4_Despesa_prevista_LOA', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t30():
    report = Report('T30_INVESTIMENTOS_SEGUNDO_FUNCOES', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t31():
    report = Report('T31_INVESTIMENTOS_SEGUNDO_FUNCOES_SUBFUNCOES_PROGRAMAS_POR_PROJETOS_ATIVIDADES', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t32():
    report = Report('T32_INVESTIMENTOS_POR_EMPRESA_SEGUNDO_FONTES_RECURSO', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t33():
    report = Report('T33_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO_INVESTIMENTOS', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t37():
    report = Report('T37_DCGF_DEMONSTRATIVOS_RECURSOS_APLICADOS_SEGURANCA_ALIMENTAR_NUTRICIONAL', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t38():
    report = Report('T38_DCGF_DEMONSTRATIVO_RECEITAS_DESPESAS_PREVIDENCIARIAS_RPPS', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume1_t39():
    report = Report('T39_DCGF_DEMONSTRATIVO_CUMPRIMENTO_LIMITACAO_CRESCIMENTO_DESPESA', 'volume1')
    assert report.test_tex()
    assert report.test_pdf()
