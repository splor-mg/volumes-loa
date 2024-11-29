# =================================================================================================
# Organização de T26. DEMONSTRATIVO DE RECURSOS A SEREM APLICADOS DIRETA OU INDIRETAMENTE EM AÇÕES
# VOLTADAS PRA A CRIANÇA E O ADOLESCENTE
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

# Identificar as ações voltadas para criança e adolescente
memoria = readxl::read_excel('bancos/manual/memoria_calculo.xlsx', sheet = 'criança e adolescente')
memoria =  dplyr::select(memoria, FUNCAO_COD, SUBFUNCAO_COD, `NE/E`)
memoria =  dplyr::rename(memoria, EXCLUSIVA = `NE/E`)

loa_desp = dplyr::left_join(loa_desp, memoria, by = c("FUNCAO_COD", "SUBFUNCAO_COD"))
loa_desp = as.data.table(loa_desp)

loa_desp[, ACOES_CRIANCA := FALSE]
loa_desp[!is.na(EXCLUSIVA), ACOES_CRIANCA := TRUE]

loa_desp = loa_desp[ACOES_CRIANCA==T, list(VL_DESP = sum(VL_DESP)),
                    by=list(UO_COD, FUNCAO_COD, SUBFUNCAO_COD, PROGRAMA_COD, ACAO_COD, ACAO_DESC, EXCLUSIVA)]

# ==============================================================================
# Ações não exclusivas
# esse indice sendo multiplicado precisa ser corrigido todo ano (Andrey)
#===============================================================================
loa_desp[EXCLUSIVA == "NE", VL_DESP := VL_DESP *  0.233493163019708]

loa_desp[, FUNCIONAL:= paste(FUNCAO_COD, formatC(SUBFUNCAO_COD, width = 3, flag="0"),
                             formatC(PROGRAMA_COD, width = 3, flag="0"),
                             substr(ACAO_COD, 1,1),
                             substr(ACAO_COD, 2,4), sep=".")]

setorderv(loa_desp, cols = c('EXCLUSIVA', 'UO_COD', 'FUNCAO_COD',
                             'SUBFUNCAO_COD', 'PROGRAMA_COD', 'ACAO_COD'))

loa_desp = loa_desp[, list(UO_COD, FUNCIONAL, ACAO_DESC, VL_DESP, EXCLUSIVA)]

loa_desp = rbind(loa_desp, data.table(UO_COD="TOTAL", VL_DESP = loa_desp[, sum(VL_DESP)]), fill=T)
loa_desp[, VL_DESP:=formatarNum(round(VL_DESP, 0))]

loa_desp[, ACAO_DESC := correcaoCaracteresEspeciais(ACAO_DESC, caracteres)]

write.table(loa_desp, "volume1/data/T26_DCGF_DEMONSTRATIVO_RECURSOS_APLICADOS_ACOES_PARA_CRIANCA_E_ADOLESCENTE.txt",
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)
