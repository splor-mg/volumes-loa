# .env must exist otherwise we get ".env: No such file or directory" error
$(shell touch .env )
include .env

#====================================================================
# Gera dependências para os volumes
PDF_R_V1 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v1.R pdf_r 2> logs/log.Rout)
PDF_PYTHON_V1 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v1.R pdf_python 2> logs/log.Rout)
TXT_PYTHON_V1 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v1.R txt_python 2> logs/log.Rout)
TXT_QDD_V1 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v1.R txt_qdd 2> logs/log.Rout)
TXT_RECEITA_V1 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v1.R txt_receita 2> logs/log.Rout)
TXT_RECEITA_QDD_V1 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v1.R txt_receita_qdd 2> logs/log.Rout)
DEPENDENCIAS_V1 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v1.R jinja2 2> logs/log.Rout)
DEPENDENCIAS_V2 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v2.R 2> logs/log.Rout)
DEPENDENCIAS_V3 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v3.R 2> logs/log.Rout)
DEPENDENCIAS_V4 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v4.R 2> logs/log.Rout)
DEPENDENCIAS_V5 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v5.R 2> logs/log.Rout)
DEPENDENCIAS_V7 := $(shell Rscript $(VERBOSE) utils/makefile/gera_dependencias_v7.R 2> logs/log.Rout)

# variaveis utilizadas pelo target make docker
# vide https://github.com/splor-mg/volumes-loa/issues/24
DOCKER_SRC_DIR := $(CURDIR)
WINPTY := ''
DOCKER_USER_FLAGS := ''

ifeq ($(shell uname), Darwin)
# default works
else ifeq ($(shell uname), Linux)
# on Linux, bind mounts preserve host uids: run as the host user so files
# created inside the container aren't owned by root on the host
	DOCKER_USER_FLAGS := '--user $(shell id -u):$(shell id -g)'
else ifeq ($(shell uname | head -c 5) , MINGW)
# git bash needs prefixing with winpty
	WINPTY := 'winpty '
else
# for cmd and powershell
	DOCKER_SRC_DIR := "c:$(DOCKER_SRC_DIR)"
endif

DOCKER_RUN_CMD = $(shell echo $(WINPTY) docker run --rm -ti -p 8787:8787 $(DOCKER_USER_FLAGS) --mount type=bind,source=$(DOCKER_SRC_DIR),target=/home/rstudio --name volumes-loa aidsplormg/volumes:loa2027.4 bash)
