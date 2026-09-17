# ===================================================
# Gera os targets dos PDF das tabelas do volume 1 que eram responsabilidade da PRODEMGE

dependencias = c("pdf/T1_DEMONSTRATIVO_CONSOLIDADO_ORCAMENTO_FISCAL.pdf",
                 "pdf/T2_DCGF_DEMONSTRATIVO_RECEITA_CORRENTE_FISCAL.pdf",
                 "pdf/T3_DCGF_Demonstrativo_Receita_Despesa_Segundo_Categorias_Economicas.pdf",
                 "pdf/T6_DCGF_Demonstrativo_Evolucao_Receita_por_Categoria_Economica.pdf",
                 "pdf/T8_DCGF_RECEITA_CORRENTE_LIQUIDA.pdf",
                 "pdf/T12_DCGF_Demonstrativo_Evolucao_Despesa_Categoria_Economica.pdf",
                 "pdf/T13_DCGF_Demonstrativo_Consolidado_Despesa.pdf",
                 "pdf/T16_DCGF_Demons_Aplicacao_Recursos_Manut_Desenv_Ensino.pdf",
                 "pdf/T17_DCGF_Demonst_Aplicacao_Recursos_Progr_Saude_Investim.pdf",
                 "pdf/T18_DCGF_Demonst_Aplicacao_Recursos_Acoes_Servicos_Publicos_Saude.pdf",
                 "pdf/T19_DCGF_Demonstrativo_Aplicacao_Recursos_Amparo_Fomento_Pesquisa.pdf",
                 "pdf/T20A_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_LRF.pdf",
                 "pdf/T23_DCGF_Demonstrativo_do_Servico_da_divida_publica.pdf",
                 "pdf/T25_DCGF_Demonstrativo_Aplicacao_Recursos_FUNDEB.pdf",
                 "pdf/T26_DCGF_DEMONSTRATIVO_RECURSOS_APLICADOS_ACOES_PARA_CRIANCA_E_ADOLESCENTE.pdf",
                 "pdf/T27_DCGF_Demonst_Despesas_UGEPREVI.pdf",
                 "pdf/T28_DCGF_PT1_Receita_prevista_e_realizada.pdf",
                 "pdf/T28_DCGF_PT2_Despesa_prevista_e_realizada.pdf",
                 "pdf/T28_DCGF_PT3_Receita_prevista_LOA.pdf",
                 "pdf/T28_DCGF_PT4_Despesa_prevista_LOA.pdf",
                 "pdf/T37_DCGF_DEMONSTRATIVOS_RECURSOS_APLICADOS_SEGURANCA_ALIMENTAR_NUTRICIONAL.pdf",
                 "pdf/T38_DCGF_DEMONSTRATIVO_RECEITAS_DESPESAS_PREVIDENCIARIAS_RPPS.pdf",
                 "pdf/T39_DCGF_DEMONSTRATIVO_DA_POLITICA_DE_ATENDIMENTO_A_MULHER_VITIMA_DE_VIOLENCIA_NO_ESTADO.pdf")

arquivos = paste0(dependencias)

write(arquivos, file = stdout())
