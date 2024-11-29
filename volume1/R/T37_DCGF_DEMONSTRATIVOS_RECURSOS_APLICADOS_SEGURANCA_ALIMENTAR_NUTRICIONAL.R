# =================================================================================================
# Organização de T37. DEMONSTRATIVOS DE RECURSOS A SEREM APLICADOS DIRETA OU INDIRETAMENTE NA
# EXECUÇÃO DA POLÍTICA ESTADUAL DE SEGURANÇA ALIMENTAR E NUTRICIONAL SUSTENTÁVEL
options(warn=1, scipen = 999)
suppressMessages(require(relatorios))

source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Investimento.R", encoding = "UTF-8")

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
loa_desp = geraLoa_desp(qdd)
setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

qdd_inv = trataQDD_Investimento("bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx")

novas_vars_inv = c("ANO","UO_COD", "FUNCAO_COD", "SUBFUNCAO_COD", "PROGRAMA_COD", "ACAO_COD", "ACAO_DESC")

setnames(qdd_inv, c(c("ANO","COD_UO", "FUNCAO", "SUB_FUNCAO", "PROGRAMA", "ACAO", "NOME_ACAO"), "valor"),
                  c(novas_vars_inv, "VL_DESP"))

loa_desp = rbind(loa_desp, qdd_inv, fill=T)


# Identificar as ações voltadas para Segurança alimentar e nutricional
memoria = readxl::read_excel('bancos/manual/memoria_calculo.xlsx', sheet = 'segurança alimentar')
loa_desp[, SEGURANCA_ALIMENTAR := FALSE]
loa_desp[ACAO_COD %in% memoria$ACAO_COD, SEGURANCA_ALIMENTAR := TRUE]

loa_desp = loa_desp[SEGURANCA_ALIMENTAR==T, list(VL_DESP = sum(VL_DESP)),
                    by=list(FUNCAO_COD, SUBFUNCAO_COD, PROGRAMA_COD, ACAO_COD, ACAO_DESC)]


loa_desp[, FUNCIONAL:= paste(formatC(FUNCAO_COD, width = 2, flag = "0"),
                             formatC(SUBFUNCAO_COD, width = 3, flag="0"),
                             formatC(PROGRAMA_COD, width = 3, flag="0"),
                             substr(ACAO_COD, 1,1),
                             substr(ACAO_COD, 2,4), sep=".")]

loa_desp = loa_desp[, list(FUNCIONAL, ACAO_DESC, VL_DESP)][order(FUNCIONAL)]

loa_desp = rbind(loa_desp, data.table(FUNCIONAL="TOTAL", VL_DESP = loa_desp[, sum(VL_DESP)]), fill=T)
loa_desp[, VL_DESP:=formatarNum(round(VL_DESP, 0))]

loa_desp[, ACAO_DESC := correcaoCaracteresEspeciais(ACAO_DESC, caracteres)]

write.table(loa_desp, "volume1/data/T37_DCGF_DEMONSTRATIVOS_RECURSOS_APLICADOS_SEGURANCA_ALIMENTAR_NUTRICIONAL.txt",
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)
