# ========================================================================================================
# Organização de T17. Demonstrativo da Aplicação de Recursos em Programas de Saúde e em Investimentos
# em Transporte e Sistema Viário
options(warn = 1, scipen = 999)

suppressMessages(require(relatorios))
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

sumario = data.table(read.table("volume2/data/sumario.txt", header=T, sep="\t", stringsAsFactors =F))

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
loa_desp = geraLoa_desp(qdd)
setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

loa_desp = mergeDT(loa_desp, sumario, by.x="UO_COD", by.y="COD_UO", all.x=T)

if(length(loa_desp[, unique(merge)])>1){

  stop("T17_DCGF_Demonst_Aplicacao_Recursos_Progr_Saude_Investim: Há UO's que não possuem seu descritivo ",
       "em volume2/data/sumario.txt. É o caso de:",
       paste(loa_desp[merge!="Em ambos os bancos", unique(UO_COD)], collapse=", "), "\n")

}


# =============== A. Programa de Saúde =======================================
parteA_desc =  "A. Programa de Saúde"

#desp = loa_desp[is_asps_desp(loa_desp, detalhe = "ACAO_COD"),]

parteA = loa_desp[FUNCAO_COD==10, ]

parteA = parteA[, list(valor = sum(VL_DESP)), by=list(cod = paste0(UO_COD,".", FUNCAO_COD), espec = UO)][order(cod)]

parteA = rbind(data.table(cod=NA,
                          espec = parteA_desc,
                          valor = parteA[, sum(valor)]),
               parteA)


# =============== B. Investimento em Transportes e Sistema Viário ============
parteB_desc =  "B. Investimento em Transportes e Sistema Viário"

complemento_espec = "(GRUPO DE DESPESA: 4 - INVESTIMENTO, 5 - INVERSÕES FINANCEIRAS DE ATIVIDADES E PROJETOS)"

parteB = loa_desp[FUNCAO_COD==26 & GRUPO_COD %in% c(4,5), ]

parteB = parteB[, list(valor = sum(VL_DESP)),
                by=list(cod = paste0(UO_COD,".", FUNCAO_COD), espec = paste(UO, complemento_espec))][order(cod)]

parteB = rbind(data.table(cod=NA,
                          espec = parteB_desc,
                          valor = parteB[,sum(valor)]),
               parteB)

# =============== C. Aplicação em (%) =======================================

parteC_desc = "C - Aplicação dos recursos em programas de saúde em relação aos investimentos em transporte e sistema viário (A/B)"

valorC = round(parteA[espec ==parteA_desc, valor] / parteB[espec == parteB_desc, valor],2)

parteC = data.table(cod=NA,
                    espec = parteC_desc,
                    valor = paste0(formatarNum(valorC), ""))

# ============== Agregando... ===================

demonstr = rbindlist(list(parteA, parteB), use.names = T)

demonstr = demonstr[,lapply(.SD, formatarNum)]
demonstr = rbind(demonstr, parteC, use.names = T)

demonstr[, espec:=correcaoCaracteresEspeciais(espec, caracteres)]

write.table(demonstr, "volume1/data/T17_DCGF_Demonst_Aplicacao_Recursos_Progr_Saude_Investim.txt",
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)
