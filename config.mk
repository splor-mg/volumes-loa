# .env must exist otherwise we get ".env: No such file or directory" error
$(shell touch .env )
include .env

#====================================================================
# Gera dependências para os volumes
DEP_PRODEMGE_PDF_V1 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dep_PRODEMGE_PDF_v1.R 2> logs/log.Rout)
DEP_DCGF_PDF_V1 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dep_DCGF_PDF_v1.R 2> logs/log.Rout)
DEP_QDD_FISCAL_TXT_V1 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dep_QDD_FISCAL_TXT_v1.R 2> logs/log.Rout)
DEP_RECEITA_TXT_V1 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dep_RECEITA_TXT_v1.R 2> logs/log.Rout)
DEP_REC_QDD_TXT_V1 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dep_RECEITA-QDD_FISCAL_TXT_v1.R 2> logs/log.Rout)
DEPENDENCIAS_V2 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v2.R 2> logs/log.Rout)
DEPENDENCIAS_V3 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v3.R 2> logs/log.Rout)
DEPENDENCIAS_V4 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v4.R 2> logs/log.Rout)
DEPENDENCIAS_V5 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v5.R 2> logs/log.Rout)

acoes_planejamento := $(shell Rscript $(VERBOSE) utils/makefile/ultimo_banco_mod.R bancos/SISOR/acoes_planejamento 2> logs/log.Rout)

# variaveis utilizadas pelo target make docker
# vide https://github.com/splor-mg/volumes-loa/issues/24
DOCKER_SRC_DIR := $(CURDIR)
WINPTY := ''

ifeq ($(shell uname), Darwin)
# default works
else ifeq ($(shell uname), Linux)
# default works
else ifeq ($(shell uname | head -c 5) , MINGW)
# git bash needs prefixing with winpty
	WINPTY := 'winpty '
else
# for cmd and powershell
	DOCKER_SRC_DIR := "c:$(DOCKER_SRC_DIR)"
endif

DOCKER_RUN_CMD = $(shell echo $(WINPTY) docker run --rm -ti -p 8787:8787 --mount type=bind,source=$(DOCKER_SRC_DIR),target=/home/rstudio --name volumes-loa fjuniorr/volumes:ploa2025 bash)