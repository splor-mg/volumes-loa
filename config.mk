#====================================================================
# Gera dependências para os volumes
DEP_PRODEMGE_PDF_V1 := $(shell Rscript --verbose utils/makefile/gera_dep_PRODEMGE_PDF_v1.R 2> logs/log.Rout)
DEP_DCGF_PDF_V1 := $(shell Rscript --verbose utils/makefile/gera_dep_DCGF_PDF_v1.R 2> logs/log.Rout)
DEP_QDD_FISCAL_TXT_V1 := $(shell Rscript --verbose utils/makefile/gera_dep_QDD_FISCAL_TXT_v1.R 2> logs/log.Rout)
DEP_RECEITA_TXT_V1 := $(shell Rscript --verbose utils/makefile/gera_dep_RECEITA_TXT_v1.R 2> logs/log.Rout)
DEP_REC_QDD_TXT_V1 := $(shell Rscript --verbose utils/makefile/gera_dep_RECEITA-QDD_FISCAL_TXT_v1.R 2> logs/log.Rout)
DEPENDENCIAS_V2 := $(shell Rscript --verbose utils/makefile/gera_dependencias_v2.R 2> logs/log.Rout)
DEPENDENCIAS_V3 := $(shell Rscript --verbose utils/makefile/gera_dependencias_v3.R 2> logs/log.Rout)
DEPENDENCIAS_V4 := $(shell Rscript --verbose utils/makefile/gera_dependencias_v4.R 2> logs/log.Rout)
DEPENDENCIAS_V5 := $(shell Rscript --verbose utils/makefile/gera_dependencias_v5.R 2> logs/log.Rout)

acoes_planejamento := $(shell Rscript --verbose utils/makefile/ultimo_banco_mod.R bancos/SISOR/acoes_planejamento 2> logs/log.Rout)

#check if the terminal is cmd power
ifeq ($(shell uname | head -c 5) , MINGW)
# using mingwin, probably git bash for windows
DIR :=${PWD}
# add winpty to work on git bash
CMD_DOCKER = $(shell echo winpty docker run --rm -ti -p 8787:8787 --mount type=bind,source="$(DIR)",target=/home/rstudio --name volumes-loa fjuniorr/volumes:ploa2023)
else
DIR :="c:${CURDIR}"
# command for cmd and powershell
CMD_DOCKER = $(shell echo docker run --rm -ti -p 8787:8787 --mount type=bind,source=$(DIR),target=/home/rstudio --name volumes-loa fjuniorr/volumes:ploa2023)
endif