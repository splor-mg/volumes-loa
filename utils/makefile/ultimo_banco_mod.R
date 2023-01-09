# Identifica qual arquivo foi modificado por último na geração das dependências do Makefile

args = commandArgs(trailingOnly=TRUE)

source("utils/funcoes.R")
ultimo_arquivo = ultimo_banco_modificado(args[1])

write(ultimo_arquivo, file = stdout())  
