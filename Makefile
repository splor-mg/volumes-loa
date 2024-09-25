.PHONY: help volumes v1 v2 v3 v4 v5 v6 clean format rm docker v1_dcgf v1_prodemge validate check rm-all

include config.mk

#====================================================================
# PHONY TARGETS

help: 
	@grep -E '^[a-zA-Z_0-9]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'

validate:
	python3 -m frictionless validate datapackage.yaml

volumes: v1 v2 v3 v4 v5 v6 ## Gera todos os volumes

v1: v1_prodemge v1_dcgf ## Gera tabelas do volume 1 de responsabilidade da PRODEMGE e DCGF

v1_prodemge: $(DEP_PRODEMGE_PDF_V1) pdf/T31_INVESTIMENTOS_SEGUNDO_FUNCOES_SUBFUNCOES_PROGRAMAS_POR_PROJETOS_ATIVIDADES.pdf pdf/T32_INVESTIMENTOS_POR_EMPRESA_SEGUNDO_FONTES_RECURSO.pdf pdf/T33_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO_INVESTIMENTOS.pdf pdf/T39_DCGF_DEMONSTRATIVO_DA_POLITICA_DE_ATENDIMENTO_A_MULHER_VITIMA_DE_VIOLENCIA_NO_ESTADO.pdf ## Gera tabelas do volume 1 de responsabilidade da PRODEMGE

v1_dcgf: $(DEP_DCGF_PDF_V1) volume1/data/T1_DEMONSTRATIVO_CONSOLIDADO_ORCAMENTO_FISCAL.csv ## Gera tabelas do volume 1 de responsabilidade da DCGF

v2: pdf/Projeto_volume2A.pdf pdf/Projeto_volume2B.pdf ## Gera volume 2

v3: pdf/Projeto_volume3.pdf ## Gera volume 3

v4: pdf/Projeto_volume4.pdf ## Gera volume 4

v5: pdf/Projeto_volume5.pdf ## Gera volume 5

v6: pdf/Projeto_volume6A.pdf ## Gera volume 6

v7: pdf/Projeto_volume7.pdf ## Gera volume 7

clean: ## Organiza os arquivos auxiliares e outputs da compilação latex. Ex. argumento vol=5. origem=1 limpa o dir principal.
	@Rscript $(VERBOSE) utils/limpaDir.R $(vol) $(origem)

format: ## Formata bancos brutos .xls, html e .txt
	@python3 utils/read_html_sisor.py
	@python3 utils/read_txt_sigplan.py
	@python3 utils/copy_xslx_apoio.py
	@python3 utils/unicode_replace.py
	@Rscript $(VERBOSE) utils/formataBancos.R

rm: ## Remove todos os arquivos de um volume Ex. argumento vol=logs
	@Rscript $(VERBOSE) utils/removeArquivos.R $(vol)

rm-all: ## Remove todos os arquivos de todos os volumes incluindo logs
	@Rscript $(VERBOSE) utils/removeArquivos.R $(vol) 2
	@Rscript $(VERBOSE) utils/removeArquivos.R $(vol) 3
	@Rscript $(VERBOSE) utils/removeArquivos.R $(vol) 4
	@Rscript $(VERBOSE) utils/removeArquivos.R $(vol) 5
	@Rscript $(VERBOSE) utils/removeArquivos.R $(vol) logs

docker:
	@if [ TRUE ]; then \
		$(DOCKER_RUN_CMD); \
	fi

rstudio: ## Inicia sessão do Rstudio em http://localhost:8787/ (usuário: rstudio, senha: splor)
	@docker exec -d -e PASSWORD=splor volumes-loa /init

check:
	python3 -m pytest

# ===================================================================
# TARGETS

# Volume 6
pdf/Projeto_volume6A.pdf: volume6/data/receita_fonte_stn.txt volume6/data/QUADRO_DETALHAMENTO_DESPESA_porUO.txt volume6/Rnw/ANEXOS.Rnw volume6/Rnw/capaLOA.pdf \
						 volume6/Rnw/load_bibliotecas.tex volume6/Rnw/Projeto_volume6A.Rnw volume6/Rnw/QUADRO_DETALHAMENTO_DESPESA.Rnw \
						 bancos/manual/desc_grupos_de_despesa.xlsx bancos/manual/desc_fontes_de_recursos_stn.xlsx bancos/manual/desc_IAG.xlsx bancos/manual/desc_IPU.xlsx
	@echo "- Gera logs/warningsV6A.Rout"
	@touch logs/warningsV6A.Rout
	@Rscript $(VERBOSE) utils/Rnw2Tex.R 6A
	@echo "---------------------------------------------------------------"

volume6/data/QUADRO_DETALHAMENTO_DESPESA_porUO.txt: volume6/R/volume6A.R bancos/SISOR/BASE_QDD_FISCAL_FONTE_STN.xlsx bancos/manual/codigosPoder.xlsx bancos/manual/desc_classificacao_economica_despesa.xlsx
	@echo "Atualizando $@..."
	@Rscript $(VERBOSE) $< 2>> logs/logv6.Rout

volume6/data/receita_fonte_stn.txt: volume6/R/volume6B.R bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL_FONTE_STN.xlsx
	@echo "Atualizando $@..."
	@Rscript $(VERBOSE) $< 2>> logs/logv6.Rout

bancos/SISOR/BASE_QDD_FISCAL_FONTE_STN.xlsx: utils/trataBancos/trataQDD_Fiscal_Fonte_STN.R bancos/SISOR/BASE_QDD_FISCAL.xlsx
	@echo "Atualizando $@..."
	@Rscript $(VERBOSE) $< 2>> logs/logv6.Rout

bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL_FONTE_STN.xlsx: utils/trataBancos/trataReceita_Fiscal_Fonte_STN.R bancos/manual/desc_fontes_de_recursos_stn.xlsx
	@echo "Atualizando $@..."
	@Rscript $(VERBOSE) $< 2>> logs/logv6.Rout

bancos/manual/desc_fontes_de_recursos_stn.xlsx: utils/trataBancos/trataDescFonte_STN.R bancos/manual/fonte_stn.csv utils/ano.txt
	@echo "Atualizando $@..."
	@Rscript $(VERBOSE) $< 2>> logs/logv6.Rout

# Volume 7
pdf/Projeto_volume7.pdf: $(DEPENDENCIAS_V7)
	@echo "- Gera logs/warningsV7.Rout"
	@python3 volume7/checks/check_qdd_fonte_95.py 2> logs/logv7.Rout
	@Rscript $(VERBOSE) volume7/Rnw/CodigosR/Projeto_volume7.R 2> logs/warningsV7.Rout >&-
	@Rscript $(VERBOSE) utils/Rnw2Tex.R 7
	@echo "---------------------------------------------------------------"

volume7/data/*.txt: volume7/R/volume7.R bancos/SISOR/BASE_QDD_FISCAL_FONTE_95.xlsx bancos/manual/codigosPoder.xlsx bancos/manual/desc_classificacao_economica_despesa.xlsx
	@echo "Atualizando v7/data/ consolidado.txt e QUADRO_DETALHAMENTO_DESPESA_porUO.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv7.Rout

# Volume 5
pdf/Projeto_volume5.pdf: $(DEPENDENCIAS_V5)
	@echo "- Gera logs/warningsV5.Rout"
	@Rscript $(VERBOSE) volume5/Rnw/CodigosR/Projeto_volume5.R 2> logs/warningsV5.Rout >&-
	@Rscript $(VERBOSE) utils/Rnw2Tex.R 5
	@echo "---------------------------------------------------------------"

volume5/data/*.txt: volume5/R/volume5.R bancos/SISOR/BASE_QDD_FISCAL.xlsx bancos/manual/codigosPoder.xlsx bancos/manual/desc_classificacao_economica_despesa.xlsx
	@echo "Atualizando v5/data/ consolidado.txt e QUADRO_DETALHAMENTO_DESPESA_porUO.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv5.Rout


# Volume 4
pdf/Projeto_volume4.pdf: $(DEPENDENCIAS_V4)
	@echo "- Gera logs/warningsV4.Rout"
	@Rscript $(VERBOSE) volume4/Rnw/CodigosR/Projeto_volume4.R 2> logs/warningsV4.Rout >&-
	@Rscript $(VERBOSE) utils/Rnw2Tex.R 4
	@echo "---------------------------------------------------------------"

volume4/data/sumario_v4.txt: volume4/R/sumario_v4.R bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx bancos/manual/codigosPoder.xlsx bancos/SISOR/BASE_QDD_FISCAL.xlsx bancos/SISOR/BASE_DETALHAMENTO_OBRAS.xlsx
	@echo "Atualizando volume4/data/sumario_v4.csv..."
	@Rscript $(VERBOSE) $< 2>> logs/logv4.Rout

volume4/data/tabela1/*.txt: volume4/R/T1_OBRAS_POR_UNIDADE_ORCAMENTARIA.R bancos/SISOR/BASE_DETALHAMENTO_OBRAS.xlsx volume4/data/sumario_v4.txt
	@echo "Atualizando volume4/data/tabela1/*.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv4.Rout

volume4/data/tabela2/*.txt: volume4/R/T2_DETALHAMENTO_INVESTIMENTOS_POR_TERRITORIOS_PLANEJAMENTO_MUNICIPIOS.R $(acoes_planejamento) volume4/data/sumario_v4.txt bancos/SISOR/BASE_DETALHAMENTO_OBRAS.xlsx
	@echo "Atualizando volume4/data/tabela2/*.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv4.Rout


# Volume 3
pdf/Projeto_volume3.pdf: $(DEPENDENCIAS_V3)
	@echo "- Gera logs/warningsV3.Rout"
	@Rscript $(VERBOSE) volume3/Rnw/CodigosR/Projeto_volume3.R 2> logs/warningsV3.Rout >&-
	@Rscript $(VERBOSE) utils/Rnw2Tex.R 3
	@echo "---------------------------------------------------------------"

volume3/data/consolidado/*.txt: volume3/R/V3_bancos_consolidados.R bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx $(acoes_planejamento)
	@echo "Atualizando volume3/data/consolidado/*.txt ..."
	@Rscript $(VERBOSE) $< 2>> logs/logv3.Rout

volume3/data/tabela1/*.txt: volume3/R/V3_T1_PROGRAMA_DE_INVESTIMENTO.R bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx $(acoes_planejamento)
	@echo "Atualizando volume3/data/tabela1/*.txt ..."
	@Rscript $(VERBOSE) $< 2>> logs/logv3.Rout

volume3/data/tabela2/*.txt: volume3/R/V3_T2_ORIGENS_RECURSOS_INVESTIMENTOS.R bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx bancos/R/V3*.txt
	@echo "Atualizando volume3/data/tabela2/*.txt ..."
	@Rscript $(VERBOSE) $< 2>> logs/logv3.Rout

bancos/R/V3*.txt: volume3/R/V3_T2_SUPORTE_CORRESPONDENCIA_DE_NIVEIS_E_SUA_ORDEM.R bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx
	@echo "Atualizando bancos/R/V3_Niveis_de_Referencia_tabela2.txt ..."
	@Rscript $(VERBOSE) $< 2>> logs/logv3.Rout

volume3/data/tabela3/*.txt: volume3/R/V3_T3_RECURSOS_FINANCEIROS_FONTE_RECURSOS_APLICACAO_INVESTIMENTO.R bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx
	@echo "Atualizando volume3/data/tabela3/*.txt ..."
	@Rscript $(VERBOSE) $< 2>> logs/logv3.Rout

volume3/data/tabela4/*.txt: volume3/R/V3_T4_DETALHAMENTO_DOS_INVESTIMENTOS.R bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx
	@echo "Atualizando volume3/data/tabela4/*.txt ..."
	@Rscript $(VERBOSE) $< 2>> logs/logv3.Rout

volume3/data/tabela5/*.txt: volume3/R/V3_T5_QUADRO_DE_DETALHAMENTO_INVESTIMENTO.R bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx
	@echo "Atualizando volume3/data/tabela5/*.txt ..."
	@Rscript $(VERBOSE) $< 2>> logs/logv3.Rout


# Volume 2
pdf/Projeto_volume2A.pdf: $(DEPENDENCIAS_V2)
	@Rscript $(VERBOSE) utils/Rnw2Tex.R 2A 2> logs/warningsV2A.Rout
	@echo "---------------------------------------------------------------"

pdf/Projeto_volume2B.pdf: $(DEPENDENCIAS_V2)
	@Rscript $(VERBOSE) utils/Rnw2Tex.R 2B 2> logs/warningsV2B.Rout
	@echo "---------------------------------------------------------------"

volume2/data/sumario.txt: volume2/R/sumario.R bancos/SISOR/BASE_QDD_FISCAL.xlsx bancos/manual/codigosPoder.xlsx
	@echo "Atualizando volume2/data/sumario.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv2.Rout

volume2/data/tabela1/*.txt: volume2/R/V2_Tabela1_PROGRAMA_DE_TRABALHO.R bancos/SISOR/BASE_QDD_FISCAL.xlsx $(acoes_planejamento) bancos/manual/desc_grupos_de_despesa.xlsx
	@echo "Atualizando volume2/data/tabela1/*.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv2.Rout

volume2/data/tabela2/*.txt: volume2/R/V2_Tabela2_FONTE_RECURSOS_GRUPOS_DESPESA_FISCAL.R bancos/SISOR/BASE_QDD_FISCAL.xlsx bancos/manual/desc_grupos_de_despesa.xlsx bancos/manual/desc_fontes_de_recursos.xlsx bancos/manual/desc_IAG.xlsx bancos/manual/desc_IPU.xlsx
	@echo "Atualizando volume2/data/tabela2/*.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv2.Rout

volume2/data/tabela3/*.txt: volume2/R/V2_Tabela3_DETALHAMENTO_DA_CATEGORIA_DE_PESSOAL.R bancos/SISOR/BASE_QDD_FISCAL.xlsx bancos/SISOR/BASE_CATEGORIA_PESSOAL.xlsx
	@echo "Atualizando volume2/data/tabela3/*.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv2.Rout

volume2/data/tabela3/4461.csv: volume2/R/V2_Tabela3_FUNFIP_DETALHAMENTO_DE_PESSOAL_INATIVO_CIVIL.R bancos/SISOR/BASE_QDD_FISCAL.xlsx bancos/SISOR/BASE_CATEGORIA_PESSOAL.xlsx bancos/manual/codigosPoder.xlsx bancos/manual/Nome_UO_antigas.xlsx bancos/manual/FFP_acoes.xlsx
	@echo "Atualizando Pessoal FUNFIP volume2/data/tabela3/4461.csv..."
	@Rscript $(VERBOSE) $< 2>> logs/logv2.Rout

volume2/data/tabela4/*.txt: volume2/R/V2_Tabela4_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS.R bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx volume2/data/sumario.txt bancos/SISOR/BASE_REPASSE_RECURSOS.xlsx bancos/manual/desc_classificacao_receita.xlsx
	@echo "Atualizando volume2/data/tabela4/*.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv2.Rout

volume2/data/tabela5/*.txt: volume2/R/V2_Tabela5_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS.R bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx volume2/data/sumario.txt bancos/SISOR/BASE_REPASSE_RECURSOS.xlsx bancos/SISOR/BASE_QDD_FISCAL.xlsx volume2/R/lib/*.R
	@echo "Atualizando volume2/data/tabela5/*.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv2.Rout

# Volume 1
$(DEP_PRODEMGE_PDF_V1): pdf/%.pdf: volume1/Rnw/%.Rnw volume1/data/%.txt
	@Rscript $(VERBOSE) utils/Rnw2Tex.R $*
	@echo "---------------------------------------------------------------"

pdf/T31_INVESTIMENTOS_SEGUNDO_FUNCOES_SUBFUNCOES_PROGRAMAS_POR_PROJETOS_ATIVIDADES.pdf: volume3/data/consolidado/T3_INVESTIMENTOS_SEGUNDO_FUNCOES_SUB_PROGRAMAS_PROJETOS_ATIVIDADES.txt volume1/Rnw/T31_INVESTIMENTOS_SEGUNDO_FUNCOES_SUBFUNCOES_PROGRAMAS_POR_PROJETOS_ATIVIDADES.Rnw
	@Rscript $(VERBOSE) utils/Rnw2Tex.R T31_INVESTIMENTOS_SEGUNDO_FUNCOES_SUBFUNCOES_PROGRAMAS_POR_PROJETOS_ATIVIDADES
	@echo "---------------------------------------------------------------"

pdf/T32_INVESTIMENTOS_POR_EMPRESA_SEGUNDO_FONTES_RECURSO.pdf: volume3/data/consolidado/T1_INVESTIMENTO_POR_EMPRESA.txt volume1/Rnw/T32_INVESTIMENTOS_POR_EMPRESA_SEGUNDO_FONTES_RECURSO.Rnw
	@Rscript $(VERBOSE) utils/Rnw2Tex.R T32_INVESTIMENTOS_POR_EMPRESA_SEGUNDO_FONTES_RECURSO
	@echo "---------------------------------------------------------------"

pdf/T33_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO_INVESTIMENTOS.pdf: volume3/data/consolidado/T2_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO.txt volume1/Rnw/T33_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO_INVESTIMENTOS.Rnw
	@Rscript $(VERBOSE) utils/Rnw2Tex.R T33_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO_INVESTIMENTOS
	@echo "---------------------------------------------------------------"

$(DEP_DCGF_PDF_V1): pdf/%.pdf: volume1/Rnw/%.Rnw volume1/data/%.txt bancos/manual/desc_base_legal_demonstrativos.xlsx
	@Rscript $(VERBOSE) utils/Rnw2Tex.R $*
	@echo "---------------------------------------------------------------"

$(DEP_QDD_FISCAL_TXT_V1): volume1/data/%.txt: volume1/R/%.R bancos/SISOR/BASE_QDD_FISCAL.xlsx volume2/data/sumario.txt bancos/manual/desc_grupos_de_despesa.xlsx bancos/manual/desc_funcao.xlsx bancos/manual/desc_subfuncao.xlsx
	@echo "Atualizando volume1/data/$*.txt..."
	@Rscript $(VERBOSE) volume1/R/$*.R 2>> logs/logv1.Rout

$(DEP_RECEITA_TXT_V1): volume1/data/%.txt: volume1/R/%.R bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx bancos/manual/desc_classificacao_receita.xlsx
	@echo "Atualizando volume1/data/$*.txt..."
	@Rscript $(VERBOSE) volume1/R/$*.R 2>> logs/logv1.Rout

$(DEP_REC_QDD_TXT_V1): volume1/data/%.txt: volume1/R/%.R bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx bancos/manual/desc_classificacao_receita.xlsx bancos/SISOR/BASE_QDD_FISCAL.xlsx volume2/data/sumario.txt bancos/manual/desc_subfuncao.xlsx
	@echo "Atualizando volume1/data/$*.txt..."
	@Rscript $(VERBOSE) volume1/R/$*.R 2>> logs/logv1.Rout

volume1/data/T5_DEMONSTRATIVO_CONSOLIDADO_CATEGORIA_PESSOAL.txt: volume1/R/T5_DEMONSTRATIVO_CONSOLIDADO_CATEGORIA_PESSOAL.R bancos/SISOR/BASE_QDD_FISCAL.xlsx bancos/SISOR/BASE_CATEGORIA_PESSOAL.xlsx
	@echo "Atualizando volume1/data/T5_DEMONSTRATIVO_CONSOLIDADO_CATEGORIA_PESSOAL.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv2.Rout

volume1/data/T30_INVESTIMENTOS_SEGUNDO_FUNCOES.txt: volume1/R/T30_INVESTIMENTOS_SEGUNDO_FUNCOES.R bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx $(acoes_planejamento)
	@echo "Atualizando volume1/data/T30_INVESTIMENTOS_SEGUNDO_FUNCOES.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv2.Rout

volume1/data/T28_DCGF_PT1_Receita_prevista_e_realizada.txt: volume1/R/T28_DCGF_PT1_Receita_prevista_e_realizada.R volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R bancos/SISOR/exec_rec.xlsx
	@echo "Atualizando volume1/data/T28_DCGF_PT1_Receita_prevista_e_realizada.txt..."
	@Rscript $(VERBOSE) volume1/R/T28_DCGF_PT1_Receita_prevista_e_realizada.R 2>> logs/logv1.Rout

volume1/data/T28_DCGF_PT2_Despesa_prevista_e_realizada.txt: volume1/R/T28_DCGF_PT2_Despesa_prevista_e_realizada.R volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R bancos/SISOR/exec_desp_realizada.xlsx
	@echo "Atualizando volume1/data/T28_DCGF_PT2_Despesa_prevista_e_realizada.txt..."
	@Rscript $(VERBOSE) volume1/R/T28_DCGF_PT2_Despesa_prevista_e_realizada.R 2>> logs/logv1.Rout

volume1/data/T28_DCGF_PT3_Receita_prevista_LOA.txt: volume1/R/T28_DCGF_PT3_Receita_prevista_LOA.R volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R bancos/SISOR/exec_desp_realizada.xlsx
	@echo "Atualizando volume1/data/T28_DCGF_PT3_Receita_prevista_LOA.txt..."
	@Rscript $(VERBOSE) volume1/R/T28_DCGF_PT3_Receita_prevista_LOA.R 2>> logs/logv1.Rout

volume1/data/T28_DCGF_PT4_Despesa_prevista_LOA.txt: volume1/R/T28_DCGF_PT4_Despesa_prevista_LOA.R volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R bancos/SISOR/exec_desp_realizada.xlsx
	@echo "Atualizando volume1/data/T28_DCGF_PT3_Despesa_prevista_LOA.txt..."
	@Rscript $(VERBOSE) volume1/R/T28_DCGF_PT4_Despesa_prevista_LOA.R 2>> logs/logv1.Rout

volume1/data/T20A_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_LRF.txt: volume1/R/T20A_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_LRF.R bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx
	@echo "Atualizando volume1/data/T20A_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_LRF.txt..."
	@Rscript $(VERBOSE) volume1/R/T20A_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_LRF.R 2>> logs/logv1.Rout

volume1/data/T1_DEMONSTRATIVO_CONSOLIDADO_ORCAMENTO_FISCAL.csv: volume1/R/T1_DCGF_Demonstrativo_Consolidado_Orcamento_Fiscal.R bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx bancos/SISOR/BASE_QDD_FISCAL.xlsx utils/suporte/V1/demonstr_consolidado.R
	@echo "Atualizando volume1/data/T1_DEMONSTRATIVO_CONSOLIDADO_ORCAMENTO_FISCAL.csv"
	@echo "<Gerar pdf manualmente utilizando 'volume1/docs/01. Demonstrativo Consolidado do Orçamento Fiscal2018.xlsx' >"
	@echo "------------------------------------------------------------------------"
	@Rscript $(VERBOSE) volume1/R/T1_DCGF_Demonstrativo_Consolidado_Orcamento_Fiscal.R 2>> logs/logv1.Rout

volume1/data/T8_DCGF_RECEITA_CORRENTE_LIQUIDA.txt: volume1/R/T8_DCGF_RECEITA_CORRENTE_LIQUIDA.R bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx utils/suporte/V1/demonstr_rcl.R
	@echo "Atualizando volume1/data/T8_DCGF_RECEITA_CORRENTE_LIQUIDA.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv1.Rout

volume1/data/T38_DCGF_DEMONSTRATIVO_RECEITAS_DESPESAS_PREVIDENCIARIAS_RPPS.txt: volume1/R/T38_DCGF_DEMONSTRATIVO_RECEITAS_DESPESAS_PREVIDENCIARIAS_RPPS.R bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx utils/suporte/V1/demonstr_despesas_previdenciarias.R utils/suporte/V1/demonstr_receitas_previdenciarias.R bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx
	@echo "Atualizando volume1/data/T38_DCGF_DEMONSTRATIVO_RECEITAS_DESPESAS_PREVIDENCIARIAS_RPPS.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv1.Rout

