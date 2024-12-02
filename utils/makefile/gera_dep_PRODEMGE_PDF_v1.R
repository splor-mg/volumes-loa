# ===================================================
# Gera os targets dos PDF das tabelas do volume 1 que eram responsabilidade da PRODEMGE

dependencias = c("pdf/T14_DEMONSTRATIVO_DESPESA_FUNCAO_SUBFUNCAO_PROGRAMA_CONFORME_VINCULO_COM_RECURSOS.pdf",
                 "pdf/T15_PROGRAMA_TRABALHO_GOVERNO.pdf",
                 "pdf/T30_INVESTIMENTOS_SEGUNDO_FUNCOES.pdf",
                 "pdf/T4_DEMONSTRATIVO_DESPESA_POR_ORGAOS_ENTIDADES_SEGUNDO_GRUPOS_DESPESA.pdf",
                 "pdf/T5_DEMONSTRATIVO_CONSOLIDADO_CATEGORIA_PESSOAL.pdf",
                 "pdf/T7_Quadro_Geral_da_Receita.pdf",
                 "pdf/T9_DEMONSTRATIVO_RECEITA_ORCAMENTARIA_CORRENTE_ORDINARIA.pdf")

arquivos = paste0(dependencias)

write(arquivos, file = stdout())
