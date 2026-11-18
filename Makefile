.PHONY: help volumes v1 v2 v3 v4 v5 v6 clean rm docker check diff rm-all reset

include config.mk

PPO := datapackages/ppo/data
SIAFI_RECEITA := $(wildcard datapackages/siafi_*/data/receita.csv.gz)
SIAFI_EXECUCAO := $(wildcard datapackages/siafi_*/data/execucao.csv.gz)

#====================================================================
# PHONY TARGETS

help:
	@grep -E '^[a-zA-Z_0-9]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'

snapshot: ## Cria snapshot dos volumes gerados para conferência posterior via pytest
	python3 checks/utils.py snapshot
	@echo "Arquivos pdf e .tex copiados para checks/assets/"


volumes: v7 v6 v5 v4 v3 v2 v1 ## Gera todos os volumes

v1: $(PDF_R_V1) $(PDF_PYTHON_V1) pdf/tabela3.pdf pdf/tabela25.pdf pdf/tabela31.pdf pdf/tabela32.pdf pdf/tabela33.pdf pdf/tabela40.pdf ## Gera as tabelas do volume 1

v2: pdf/volume2.pdf ## Gera volume 2

v3: pdf/volume3.pdf ## Gera volume 3

v4: pdf/volume4.pdf ## Gera volume 4

v5: pdf/volume5.pdf ## Gera volume 5

v6: pdf/volume6.pdf ## Gera volume 6

v7: pdf/volume7.pdf ## Gera volume 7

clean: ## Organiza os arquivos auxiliares e outputs da compilação latex. Ex. argumento vol=5. origem=1 limpa o dir principal.
	@Rscript $(VERBOSE) utils/limpaDir.R $(vol) $(origem)

rm: ## Remove todos os arquivos de um volume Ex. argumento vol=logs
	@Rscript $(VERBOSE) utils/removeArquivos.R $(vol)

rm-all: ## Remove todos os arquivos de todos os volumes incluindo logs
	@Rscript $(VERBOSE) utils/removeArquivos.R $(vol) 2
	@Rscript $(VERBOSE) utils/removeArquivos.R $(vol) 3
	@Rscript $(VERBOSE) utils/removeArquivos.R $(vol) 4
	@Rscript $(VERBOSE) utils/removeArquivos.R $(vol) 5
	@Rscript $(VERBOSE) utils/removeArquivos.R $(vol) logs

reset: ### Remove todos os arquivos (de datapackages/ até pdf/)
	@python3 utils/reset.py

docker:
	@if [ TRUE ]; then \
		$(DOCKER_RUN_CMD); \
	fi

rstudio: ## Inicia sessão do Rstudio em http://localhost:8787/ (usuário: rstudio, senha: splor)
	@docker exec -d -e PASSWORD=splor volumes-loa /init

check:
	python3 -m pytest

diff:
	python3 checks/utils.py diff

# ===================================================================
# TARGETS

# Volume 7
pdf/volume7.pdf: $(DEPENDENCIAS_V7)
	@python3 -m volume7.jinja2.volume7 2> logs/warningsV7.Rout
	@echo "---------------------------------------------------------------"

volume7/data/*.txt: volume7/python/*.py utils/python/*.py volume7/checks/check_orcamento_despesa_fonte_80_95.py $(PPO)/orcamento_despesa.csv datapackages/fonte_80_95/data/orcamento_despesa_fonte_80_95.csv $(PPO)/classificacao_despesa.csv
	@echo "Atualizando volume7/data/ consolidado.txt e qdd.txt..."
	@python3 volume7/checks/check_orcamento_despesa_fonte_80_95.py 2> logs/logv7.Rout
	@python3 -m volume7.python.volume7 2>> logs/logv7.Rout


# Volume 6
pdf/volume6.pdf: $(DEPENDENCIAS_V6)
	@python3 -m volume6.jinja2.volume6 2> logs/warningsV6.Rout
	@echo "---------------------------------------------------------------"

volume6/data/QUADRO_DETALHAMENTO_DESPESA_porUO.txt: volume6/R/volume6A.R volume6/data/orcamento_despesa_fonte_stn.csv
	@echo "Atualizando $@..."
	@Rscript $(VERBOSE) $< 2>> logs/logv6.Rout

volume6/data/receita_fonte_stn.txt: volume6/R/volume6B.R volume6/data/orcamento_receita_fonte_stn.csv
	@echo "Atualizando $@..."
	@Rscript $(VERBOSE) $< 2>> logs/logv6.Rout

volume6/data/orcamento_despesa_fonte_stn.csv: utils/trataBancos/trataQDD_Fiscal_Fonte_STN.R $(PPO)/orcamento_despesa.csv
	@echo "Atualizando $@..."
	@Rscript $(VERBOSE) $< 2>> logs/logv6.Rout

volume6/data/orcamento_receita_fonte_stn.csv: utils/trataBancos/trataReceita_Fiscal_Fonte_STN.R $(PPO)/orcamento_receita.csv volume6/data/desc_fontes_de_recursos_stn.xlsx
	@echo "Atualizando $@..."
	@Rscript $(VERBOSE) $< 2>> logs/logv6.Rout

volume6/data/desc_fontes_de_recursos_stn.xlsx: utils/trataBancos/trataDescFonte_STN.R datapackages/fonte_stn/data/fonte_stn.csv utils/ano.txt
	@echo "Atualizando $@..."
	@Rscript $(VERBOSE) $< 2>> logs/logv6.Rout


# Volume 5
pdf/volume5.pdf: $(DEPENDENCIAS_V5)
	@python3 -m volume5.jinja2.volume5 2> logs/warningsV5.Rout
	@echo "---------------------------------------------------------------"

volume5/data/*.txt: volume5/python/*.py utils/python/*.py $(PPO)/orcamento_despesa.csv $(PPO)/classificacao_despesa.csv
	@echo "Atualizando volume5/data/ consolidado.txt e qdd.txt..."
	@python3 -m volume5.python.volume5 2> logs/logv5.Rout


# Volume 4
pdf/volume4.pdf: $(DEPENDENCIAS_V4)
	@python3 -m volume4.jinja2.volume4 2> logs/warningsV4.Rout
	@echo "---------------------------------------------------------------"

volume4/data/*.txt: volume4/python/*.py utils/python/*.py $(PPO)/orcamento_obras.csv $(PPO)/planejamento_acao.csv
	@echo "Atualizando volume4/data/ sumario.txt, tabela1/*.txt e tabela2/*.txt..."
	@python3 -m volume4.python.volume4 2> logs/logv4.Rout


# Volume 3
pdf/volume3.pdf: $(DEPENDENCIAS_V3)
	@python3 -m volume3.jinja2.volume3 2> logs/warningsV3.Rout
	@echo "---------------------------------------------------------------"

volume3/data/*.txt: volume3/python/*.py utils/python/*.py $(PPO)/orcamento_despesa_investimento.csv $(PPO)/planejamento_acao.csv
	@echo "Atualizando volume3/data/ consolidado/*.txt e tabela1/*.txt a tabela5/*.txt..."
	@python3 -m volume3.python.volume3 2> logs/logv3.Rout


# Volume 2
pdf/volume2.pdf: $(DEPENDENCIAS_V2)
	@python3 -m volume2.jinja2.volume2 2> logs/warningsV2.Rout
	@echo "---------------------------------------------------------------"

volume2/data/*.txt: volume2/python/*.py utils/python/*.py $(PPO)/orcamento_despesa.csv $(PPO)/planejamento_acao.csv $(PPO)/orcamento_pessoal.csv $(PPO)/orcamento_receita.csv $(PPO)/orcamento_repasse.csv $(PPO)/classificacao_receita.csv datapackages/apoio/data-raw/FFP_acoes.xlsx
	@echo "Atualizando volume2/data/ sumario.txt e tabela1/*.txt a tabela5/*.txt..."
	@python3 -m volume2.python.volume2 2> logs/logv2.Rout


# Volume 1
$(PDF_PYTHON_V1) $(PDF_R_V1): pdf/%.pdf: volume1/jinja2/%.tex.j2 volume1/data/%.txt $(DEPENDENCIAS_V1)
	@python3 -m volume1.jinja2.volume1 $* 2>> logs/warningsV1.Rout
	@echo "---------------------------------------------------------------"

pdf/tabela3.pdf: volume1/data/tabela3a.txt volume1/data/tabela3b.txt volume1/jinja2/tabela3.tex.j2 $(DEPENDENCIAS_V1)
	@python3 -m volume1.jinja2.volume1 tabela3 2>> logs/warningsV1.Rout
	@echo "---------------------------------------------------------------"

pdf/tabela25.pdf: volume1/data/tabela25a.txt volume1/data/tabela25b.txt volume1/jinja2/tabela25.tex.j2 $(DEPENDENCIAS_V1)
	@python3 -m volume1.jinja2.volume1 tabela25 2>> logs/warningsV1.Rout
	@echo "---------------------------------------------------------------"

pdf/tabela31.pdf: volume3/data/consolidado/t3_investimentos_projeto_atividade.txt volume1/jinja2/tabela31.tex.j2 $(DEPENDENCIAS_V1)
	@python3 -m volume1.jinja2.volume1 tabela31 2>> logs/warningsV1.Rout
	@echo "---------------------------------------------------------------"

pdf/tabela32.pdf: volume3/data/consolidado/t1_investimentos_empresa.txt volume1/jinja2/tabela32.tex.j2 $(DEPENDENCIAS_V1)
	@python3 -m volume1.jinja2.volume1 tabela32 2>> logs/warningsV1.Rout
	@echo "---------------------------------------------------------------"

pdf/tabela33.pdf: volume3/data/consolidado/t2_investimentos_empresa_detalhamento.txt volume1/jinja2/tabela33.tex.j2 $(DEPENDENCIAS_V1)
	@python3 -m volume1.jinja2.volume1 tabela33 2>> logs/warningsV1.Rout
	@echo "---------------------------------------------------------------"

pdf/tabela40.pdf: datapackages/apoio/data-raw/demonstrativo_despesas_obrigatorias.csv volume1/jinja2/tabela40.tex.j2 $(DEPENDENCIAS_V1)
	@python3 -m volume1.jinja2.volume1 tabela40 2>> logs/warningsV1.Rout
	@echo "---------------------------------------------------------------"

$(subst volume1/data/,volume1/%/,$(TXT_PYTHON_V1)): volume1/python/*.py utils/python/*.py $(PPO)/orcamento_despesa.csv $(PPO)/orcamento_despesa_investimento.csv $(PPO)/orcamento_pessoal.csv $(PPO)/orcamento_receita.csv $(PPO)/classificacao_receita.csv $(PPO)/planejamento_acao.csv datapackages/apoio/data-raw/memoria_calculo.xlsx utils/volume1/indice_crianca_adolescente.txt
	@echo "Atualizando volume1/data/ tabelas em Python..."
	@python3 -m volume1.python.volume1 2>> logs/logv1.Rout

$(TXT_QDD_V1): volume1/data/%.txt: volume1/R/%.R $(PPO)/orcamento_despesa.csv volume2/data/sumario.txt
	@echo "Atualizando volume1/data/$*.txt..."
	@Rscript $(VERBOSE) volume1/R/$*.R 2>> logs/logv1.Rout

$(TXT_RECEITA_V1): volume1/data/%.txt: volume1/R/%.R $(PPO)/orcamento_receita.csv $(PPO)/classificacao_receita.csv
	@echo "Atualizando volume1/data/$*.txt..."
	@Rscript $(VERBOSE) volume1/R/$*.R 2>> logs/logv1.Rout

$(TXT_RECEITA_QDD_V1): volume1/data/%.txt: volume1/R/%.R $(PPO)/orcamento_receita.csv $(PPO)/classificacao_receita.csv $(PPO)/orcamento_despesa.csv volume2/data/sumario.txt
	@echo "Atualizando volume1/data/$*.txt..."
	@Rscript $(VERBOSE) volume1/R/$*.R 2>> logs/logv1.Rout

volume1/%/tabela25a.txt volume1/%/tabela25b.txt: volume1/R/tabela25.R $(PPO)/orcamento_receita.csv $(PPO)/classificacao_receita.csv $(PPO)/orcamento_despesa.csv volume2/data/sumario.txt
	@echo "Atualizando volume1/data/tabela25a.txt e tabela25b.txt..."
	@Rscript $(VERBOSE) volume1/R/tabela25.R 2>> logs/logv1.Rout

volume1/data/tabela6.txt: $(SIAFI_RECEITA)

volume1/data/tabela12.txt: $(SIAFI_EXECUCAO)

volume1/data/tabela28a.txt: volume1/R/tabela28a.R volume1/R/tabela28_comum.R $(SIAFI_RECEITA)
	@echo "Atualizando volume1/data/tabela28a.txt..."
	@Rscript $(VERBOSE) volume1/R/tabela28a.R 2>> logs/logv1.Rout

volume1/data/tabela28b.txt: volume1/R/tabela28b.R volume1/R/tabela28_comum.R $(SIAFI_EXECUCAO)
	@echo "Atualizando volume1/data/tabela28b.txt..."
	@Rscript $(VERBOSE) volume1/R/tabela28b.R 2>> logs/logv1.Rout

volume1/data/tabela20a.txt: volume1/R/tabela20a.R $(PPO)/orcamento_despesa.csv $(PPO)/orcamento_receita.csv
	@echo "Atualizando volume1/data/tabela20a.txt..."
	@Rscript $(VERBOSE) volume1/R/tabela20a.R 2>> logs/logv1.Rout

volume1/data/tabela1.txt: volume1/R/tabela1.R $(PPO)/orcamento_receita.csv $(PPO)/orcamento_despesa.csv utils/suporte/V1/demonstr_consolidado.R
	@echo "Atualizando volume1/data/tabela1.txt..."
	@echo "------------------------------------------------------------------------"
	@Rscript $(VERBOSE) volume1/R/tabela1.R 2>> logs/logv1.Rout

volume1/data/tabela8.txt: volume1/R/tabela8.R $(PPO)/orcamento_receita.csv utils/suporte/V1/demonstr_rcl.R
	@echo "Atualizando volume1/data/tabela8.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv1.Rout

volume1/data/tabela38.txt: volume1/R/tabela38.R $(PPO)/orcamento_receita.csv utils/suporte/V1/demonstr_despesas_previdenciarias.R utils/suporte/V1/demonstr_receitas_previdenciarias.R $(PPO)/orcamento_despesa.csv
	@echo "Atualizando volume1/data/tabela38.txt..."
	@Rscript $(VERBOSE) $< 2>> logs/logv1.Rout
