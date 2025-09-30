
## Receita prevista e realizada em 2016
options(warn=1, scipen = 999)

suppressMessages(require(relatorios))

source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====================================================================================
# Parâmetros
ano_exercicio = as.numeric(readLines("utils/ano.txt", warn = F)) - 1
mes = 8
fontes_uniao = c(1:8,
                 16,17,
                 21, 22, 24, 36, 37, 38, 56, 57,
                 62:65,
                 73, 84, 85, 86, 87, 88, 92, 93, 97, 98
                 )

# ====================================================================================

meses = c("8"="Agosto", "9"="Setembro")
mes_executado = meses[[as.character(mes)]]

excluir =  c(22,84,85,86,87,88)
fontes_relatorio = setdiff(fontes_uniao, excluir)
FONTES_CONSIDERADAS = gsub("(.+\\d{2})\\, (\\d{2})$", "\\1 e \\2",  paste(fontes_relatorio, collapse=", "))
