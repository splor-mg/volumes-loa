
rm(list= ls()) #limpa todas as variáveis de ambiente

#source("utils/packages_latex/instala_bibliotecas.R", encoding = "UTF-8")
#instalar_bbts()


source("utils/makefile/init.R", encoding = "UTF-8")
source("utils/formataBancos.R", encoding = "UTF-8")
source("utils/makefile/gera_dep_PRODEMGE_PDF_v1.R", encoding = "UTF-8")
source("utils/makefile/gera_dep_DCGF_PDF_v1.R", encoding = "UTF-8")
source("utils/makefile/gera_dep_QDD_FISCAL_TXT_v1.R", encoding = "UTF-8")
source("utils/makefile/gera_dep_RECEITA_TXT_v1.R", encoding = "UTF-8")
source("utils/makefile/gera_dep_RECEITA-QDD_FISCAL_TXT_v1.R", encoding = "UTF-8")

source("utils/makefile/ultimo_banco_mod.R", encoding = "UTF-8")


# ---------- volume 5 ---------------
source("utils/makefile/gera_dependencias_v5.R" , encoding = "UTF-8")
source("volume5/Rnw/CodigosR/Projeto_volume5.R" , encoding = "UTF-8")
args <- c(5)
source("utils/Rnw2Tex.R" , encoding = "UTF-8")



# ---------- volume 4 ---------------
source("utils/makefile/gera_dependencias_v4.R" , encoding = "UTF-8")


source("volume4/R/sumario_v4.R" , encoding = "UTF-8")
source("volume4/R/T2_DETALHAMENTO_INVESTIMENTOS_POR_TERRITORIOS_PLANEJAMENTO_MUNICIPIOS.R", encoding = "UTF-8")
source("volume4/R/T1_OBRAS_POR_UNIDADE_ORCAMENTARIA.R" , encoding = "UTF-8")


source("volume4/Rnw/CodigosR/Projeto_volume4.R" , encoding = "UTF-8")
args <- c(4)
source("utils/Rnw2Tex.R" , encoding = "UTF-8")


# ---------- volume 3 ---------------


source("utils/makefile/gera_dependencias_v3.R" , encoding = "UTF-8")

source("volume3/R/V3_bancos_consolidados.R", encoding = "UTF-8")


source("volume3/R/V3_T5_QUADRO_DE_DETALHAMENTO_INVESTIMENTO.R", encoding = "UTF-8")

source("volume3/R/V3_T4_DETALHAMENTO_DOS_INVESTIMENTOS.R", encoding = "UTF-8")

source("volume3/R/V3_T3_RECURSOS_FINANCEIROS_FONTE_RECURSOS_APLICACAO_INVESTIMENTO.R", encoding = "UTF-8")

source("volume3/R/V3_T2_SUPORTE_CORRESPONDENCIA_DE_NIVEIS_E_SUA_ORDEM.R", encoding = "UTF-8")

source("volume3/R/V3_T2_ORIGENS_RECURSOS_INVESTIMENTOS.R", encoding = "UTF-8")

source("volume3/R/V3_T1_PROGRAMA_DE_INVESTIMENTO.R", encoding = "UTF-8")



source("volume3/Rnw/CodigosR/Projeto_volume3.R" , encoding = "UTF-8")

args <- c(3)
source("utils/Rnw2Tex.R", encoding = "UTF-8")



# ---------- volume 2 ---------------


source("volume2/R/sumario.R", encoding = "UTF-8")

source("volume2/R/V2_Tabela1_PROGRAMA_DE_TRABALHO.R", encoding = "UTF-8")

source("volume2/R/V2_Tabela2_FONTE_RECURSOS_GRUPOS_DESPESA_FISCAL.R", encoding = "UTF-8")

source("volume2/R/V2_Tabela3_DETALHAMENTO_DA_CATEGORIA_DE_PESSOAL.R", encoding = "UTF-8")

source("volume2/R/V2_Tabela3_FUNFIP_DETALHAMENTO_DE_PESSOAL_INATIVO_CIVIL.R", encoding = "UTF-8")

source("volume2/R/V2_Tabela4_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS.R", encoding = "UTF-8")


source("volume2/R/V2_Tabela5_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS.R", encoding = "UTF-8")
source("volume2/R/lib/V2_Tabela5_SUPORTE_CorrecaoFontesSimultaneas.R", encoding = "UTF-8")
source("volume2/R/lib/V2_Tabela5_SUPORTE_CorrecaoFonte10.R", encoding = "UTF-8")





















args <- c("2B")
source("utils/Rnw2Tex.R" , encoding = "UTF-8")

args <- c("2A")
source("utils/Rnw2Tex.R" , encoding = "UTF-8")







# ---------- volume 1 ---------------

# v1: v1_prodemge v1_dcgf

# v1_prodemge: $(DEP_PRODEMGE_PDF_V1) pdf/T31_INVESTIMENTOS_SEGUNDO_FUNCOES_SUBFUNCOES_PROGRAMAS_POR_PROJETOS_ATIVIDADES.pdf pdf/T32_INVESTIMENTOS_POR_EMPRESA_SEGUNDO_FONTES_RECURSO.pdf pdf/T33_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO_INVESTIMENTOS.pdf ## Gera tabelas do volume 1 de responsabilidade da PRODEMGE

# v1_dcgf: $(DEP_DCGF_PDF_V1) volume1/data/T1_DEMONSTRATIVO_CONSOLIDADO_ORCAMENTO_FISCAL.csv ## Gera tabelas do volume 1 de responsabilidade da DCGF
 

# DEP_PRODEMGE_PDF_V1 := $(shell Rscript utils/makefile/gera_dep_PRODEMGE_PDF_v1.R 2> logs/log.Rout)
# DEP_DCGF_PDF_V1 := $(shell Rscript utils/makefile/gera_dep_DCGF_PDF_v1.R 2> logs/log.Rout)
# DEP_QDD_FISCAL_TXT_V1 := $(shell Rscript utils/makefile/gera_dep_QDD_FISCAL_TXT_v1.R 2> logs/log.Rout)
# DEP_RECEITA_TXT_V1 := $(shell Rscript utils/makefile/gera_dep_RECEITA_TXT_v1.R 2> logs/log.Rout)
# DEP_REC_QDD_TXT_V1 := $(shell Rscript utils/makefile/gera_dep_RECEITA-QDD_FISCAL_TXT_v1.R 2> logs/log.Rout)



source("utils/makefile/gera_dep_DCGF_PDF_v1.R", encoding = "UTF-8")
source("utils/makefile/gera_dep_QDD_FISCAL_TXT_v1.R", encoding = "UTF-8")
source("utils/makefile/gera_dep_RECEITA_TXT_v1.R", encoding = "UTF-8")
source("utils/makefile/gera_dep_RECEITA-QDD_FISCAL_TXT_v1.R", encoding = "UTF-8")
source("utils/makefile/gera_dep_PRODEMGE_PDF_v1.R", encoding = "UTF-8")


source("volume1/R/T8_DCGF_RECEITA_CORRENTE_LIQUIDA.R", encoding = "UTF-8")
args <- c("T8_DCGF_RECEITA_CORRENTE_LIQUIDA")
source("utils/Rnw2Tex.R", encoding = "UTF-8")





#volume1/data/T28_DCGF_PT1_Receita_prevista_e_realizada.txt: volume1/R/T28_DCGF_PT1_Receita_prevista_e_realizada.R volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R bancos/SISOR/exec_rec.xlsx
#@echo "Atualizando volume1/data/T28_DCGF_PT1_Receita_prevista_e_realizada.txt..."
#@Rscript --encoding=utf-8 volume1/R/T28_DCGF_PT1_Receita_prevista_e_realizada.R 2>> logs/logv1.Rout

source("volume1/R/T28_DCGF_PT1_Receita_prevista_e_realizada.R", encoding = "UTF-8") 
source("volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R", encoding = "UTF-8")
source("volume1/R/T28_DCGF_PT1_Receita_prevista_e_realizada.R", encoding = "UTF-8")



#volume1/data/T28_DCGF_PT2_Despesa_prevista_e_realizada.txt: volume1/R/T28_DCGF_PT2_Despesa_prevista_e_realizada.R volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R bancos/SISOR/exec_desp_realizada.xlsx
#@echo "Atualizando volume1/data/T28_DCGF_PT2_Despesa_prevista_e_realizada.txt..."
#@Rscript --encoding=utf-8 volume1/R/T28_DCGF_PT2_Despesa_prevista_e_realizada.R 2>> logs/logv1.Rout

source("volume1/R/T28_DCGF_PT2_Despesa_prevista_e_realizada.R", encoding = "UTF-8") 
source("volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R", encoding = "UTF-8")
source("volume1/R/T28_DCGF_PT2_Despesa_prevista_e_realizada.R", encoding = "UTF-8")


#volume1/data/T28_DCGF_PT3_Receita_prevista_LOA.txt: volume1/R/T28_DCGF_PT3_Receita_prevista_LOA.R volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R bancos/SISOR/exec_desp_realizada.xlsx
#@echo "Atualizando volume1/data/T28_DCGF_PT3_Receita_prevista_LOA.txt..."
#@Rscript --encoding=utf-8 volume1/R/T28_DCGF_PT3_Receita_prevista_LOA.R 2>> logs/logv1.Rout


source("volume1/R/T28_DCGF_PT3_Receita_prevista_LOA.R", encoding = "UTF-8")
source("volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R", encoding = "UTF-8")
source("volume1/R/T28_DCGF_PT3_Receita_prevista_LOA.R", encoding = "UTF-8")


#volume1/data/T28_DCGF_PT4_Despesa_prevista_LOA.txt: volume1/R/T28_DCGF_PT4_Despesa_prevista_LOA.R volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R bancos/SISOR/exec_desp_realizada.xlsx
#@echo "Atualizando volume1/data/T28_DCGF_PT3_Despesa_prevista_LOA.txt..."
#@Rscript --encoding=utf-8 volume1/R/T28_DCGF_PT3_Despesa_prevista_LOA.R 2>> logs/logv1.Rout


source("volume1/R/T28_DCGF_PT4_Despesa_prevista_LOA.R", encoding = "UTF-8") 
source("volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R", encoding = "UTF-8")
source("volume1/R/T28_DCGF_PT3_Despesa_prevista_LOA.R", encoding = "UTF-8")












args <- c(1)
source("utils/Rnw2Tex.R", encoding = "UTF-8")
#' $(DEP_PRODEMGE_PDF_V1): pdf/%.pdf: volume1/Rnw/%.Rnw volume1/data/%.txt
#' @Rscript utils/Rnw2Tex.R $*
#'   @echo "---------------------------------------------------------------"


volume1/data/T28_DCGF_PT4_Despesa_prevista_LOA.txt: volume1/R/T28_DCGF_PT4_Despesa_prevista_LOA.R volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R bancos/SISOR/exec_desp_realizada.xlsx
cat("Atualizando volume1/data/T28_DCGF_PT3_Despesa_prevista_LOA.txt...")
@Rscript --encoding=utf-8 volume1/R/T28_DCGF_PT3_Despesa_prevista_LOA.R 2>> logs/logv1.Rout

volume1/R/T28_DCGF_PT4_Despesa_prevista_LOA.R 
volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R

volume1/R/T28_DCGF_PT3_Despesa_prevista_LOA.R



pdf/T31_INVESTIMENTOS_SEGUNDO_FUNCOES_SUBFUNCOES_PROGRAMAS_POR_PROJETOS_ATIVIDADES.pdf: volume3/data/consolidado/T3_INVESTIMENTOS_SEGUNDO_FUNCOES_SUB_PROGRAMAS_PROJETOS_ATIVIDADES.txt
@Rscript utils/Rnw2Tex.R T31_INVESTIMENTOS_SEGUNDO_FUNCOES_SUBFUNCOES_PROGRAMAS_POR_PROJETOS_ATIVIDADES
@echo "---------------------------------------------------------------"

pdf/T32_INVESTIMENTOS_POR_EMPRESA_SEGUNDO_FONTES_RECURSO.pdf: volume3/data/consolidado/T1_INVESTIMENTO_POR_EMPRESA.txt
@Rscript utils/Rnw2Tex.R T32_INVESTIMENTOS_POR_EMPRESA_SEGUNDO_FONTES_RECURSO
@echo "---------------------------------------------------------------"

pdf/T33_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO_INVESTIMENTOS.pdf: volume3/data/consolidado/T2_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO.txt
@Rscript utils/Rnw2Tex.R T33_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO_INVESTIMENTOS
@echo "---------------------------------------------------------------"

$(DEP_DCGF_PDF_V1): pdf/%.pdf: volume1/Rnw/%.Rnw volume1/data/%.txt
@Rscript utils/Rnw2Tex.R $*
  @echo "---------------------------------------------------------------"

$(DEP_QDD_FISCAL_TXT_V1): volume1/data/%.txt: volume1/R/%.R bancos/SISOR/BASE_QDD_FISCAL.xlsx volume2/data/sumario.txt bancos/manual/desc_grupos_de_despesa.xlsx bancos/manual/desc_funcao.xlsx bancos/manual/desc_subfuncao.xlsx
@echo "Atualizando volume1/data/$*.txt..."
@Rscript --encoding=utf-8 volume1/R/$*.R 2>> logs/logv1.Rout

$(DEP_RECEITA_TXT_V1): volume1/data/%.txt: volume1/R/%.R bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx bancos/manual/desc_classificacao_receita.xlsx
@echo "Atualizando volume1/data/$*.txt..."
@Rscript --encoding=utf-8 volume1/R/$*.R 2>> logs/logv1.Rout

$(DEP_REC_QDD_TXT_V1): volume1/data/%.txt: volume1/R/%.R bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx bancos/manual/desc_classificacao_receita.xlsx bancos/SISOR/BASE_QDD_FISCAL.xlsx volume2/data/sumario.txt bancos/manual/desc_subfuncao.xlsx
@echo "Atualizando volume1/data/$*.txt..."
@Rscript --encoding=utf-8 volume1/R/$*.R 2>> logs/logv1.Rout


volume1/data/T28_DCGF_PT1_Receita_prevista_e_realizada.txt: volume1/R/T28_DCGF_PT1_Receita_prevista_e_realizada.R volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R bancos/SISOR/exec_rec.xlsx
@echo "Atualizando volume1/data/T28_DCGF_PT1_Receita_prevista_e_realizada.txt..."
@Rscript --encoding=utf-8 volume1/R/T28_DCGF_PT1_Receita_prevista_e_realizada.R 2>> logs/logv1.Rout


volume1/data/T28_DCGF_PT3_Receita_prevista_LOA.txt: volume1/R/T28_DCGF_PT3_Receita_prevista_LOA.R volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R bancos/SISOR/exec_desp_realizada.xlsx
@echo "Atualizando volume1/data/T28_DCGF_PT3_Receita_prevista_LOA.txt..."
@Rscript --encoding=utf-8 volume1/R/T28_DCGF_PT3_Receita_prevista_LOA.R 2>> logs/logv1.Rout



volume1/data/T5_DEMONSTRATIVO_CONSOLIDADO_CATEGORIA_PESSOAL.txt: volume1/R/T5_DEMONSTRATIVO_CONSOLIDADO_CATEGORIA_PESSOAL.R bancos/SISOR/BASE_QDD_FISCAL.xlsx bancos/SISOR/BASE_CATEGORIA_PESSOAL.xlsx
@echo "Atualizando volume1/data/T5_DEMONSTRATIVO_CONSOLIDADO_CATEGORIA_PESSOAL.txt..."
@Rscript --encoding=utf-8 $< 2>> logs/logv2.Rout

volume1/data/T30_INVESTIMENTOS_SEGUNDO_FUNCOES.txt: volume1/R/T30_INVESTIMENTOS_SEGUNDO_FUNCOES.R bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx $(acoes_planejamento)
@echo "Atualizando volume1/data/T30_INVESTIMENTOS_SEGUNDO_FUNCOES.txt..."
@Rscript --encoding=utf-8 $< 2>> logs/logv2.Rout



volume1/data/T28_DCGF_PT2_Despesa_prevista_e_realizada.txt: volume1/R/T28_DCGF_PT2_Despesa_prevista_e_realizada.R volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R bancos/SISOR/exec_desp_realizada.xlsx
@echo "Atualizando volume1/data/T28_DCGF_PT2_Despesa_prevista_e_realizada.txt..."
@Rscript --encoding=utf-8 volume1/R/T28_DCGF_PT2_Despesa_prevista_e_realizada.R 2>> logs/logv1.Rout





volume1/data/T20A_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_LRF.txt: volume1/R/T20A_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_LRF.R bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx
@echo "Atualizando volume1/data/T20A_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_LRF.txt..."
@Rscript --encoding=utf-8 volume1/R/T20A_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_LRF.R 2>> logs/logv1.Rout


# volume1/data/T20B_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_TCE.txt: volume1/R/T20B_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_TCE.R bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx
# 	@echo "Atualizando volume1/data/T20B_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_TCE.txt..."
# 	@Rscript --encoding=utf-8 volume1/R/T20B_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_TCE.R 2>> logs/logv1.Rout

volume1/data/T1_DEMONSTRATIVO_CONSOLIDADO_ORCAMENTO_FISCAL.csv: volume1/R/T1_DCGF_Demonstrativo_Consolidado_Orcamento_Fiscal.R bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx bancos/SISOR/BASE_QDD_FISCAL.xlsx utils/suporte/V1/demonstr_consolidado.R
@echo "Atualizando volume1/data/T1_DEMONSTRATIVO_CONSOLIDADO_ORCAMENTO_FISCAL.csv"
@echo "<Gerar pdf manualmente utilizando 'volume1/docs/01. Demonstrativo Consolidado do Orçamento Fiscal2018.xlsx' >"
@echo "------------------------------------------------------------------------"
@Rscript --encoding=utf-8 volume1/R/T1_DCGF_Demonstrativo_Consolidado_Orcamento_Fiscal.R 2>> logs/logv1.Rout

volume1/data/T8_DCGF_RECEITA_CORRENTE_LIQUIDA.txt: volume1/R/T8_DCGF_RECEITA_CORRENTE_LIQUIDA.R bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx utils/suporte/V1/demonstr_rcl.R
@echo "Atualizando volume1/data/T8_DCGF_RECEITA_CORRENTE_LIQUIDA.txt..."
@Rscript --encoding=utf-8 $< 2>> logs/logv1.Rout

volume1/data/T38_DCGF_DEMONSTRATIVO_RECEITAS_DESPESAS_PREVIDENCIARIAS_RPPS.txt: volume1/R/T38_DCGF_DEMONSTRATIVO_RECEITAS_DESPESAS_PREVIDENCIARIAS_RPPS.R bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx utils/suporte/V1/demonstr_despesas_previdenciarias.R utils/suporte/V1/demonstr_receitas_previdenciarias.R bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx
@echo "Atualizando volume1/data/T38_DCGF_DEMONSTRATIVO_RECEITAS_DESPESAS_PREVIDENCIARIAS_RPPS.txt..."
@Rscript --encoding=utf-8 $< 2>> logs/logv1.Rout

volume1/data/T39_DCGF_DEMONSTRATIVO_CUMPRIMENTO_LIMITACAO_CRESCIMENTO_DESPESA.txt: volume1/R/T39_DCGF_DEMONSTRATIVO_CUMPRIMENTO_LIMITACAO_CRESCIMENTO_DESPESA.R bancos/SISOR/BASE_QDD_FISCAL.xlsx bancos/manual/codigosPoder.xlsx
@echo "Atualizando volume1/data/T39_DCGF_DEMONSTRATIVO_CUMPRIMENTO_LIMITACAO_CRESCIMENTO_DESPESA.txt..."
@Rscript --encoding=utf-8 $< 2>> logs/logv1.Rout


