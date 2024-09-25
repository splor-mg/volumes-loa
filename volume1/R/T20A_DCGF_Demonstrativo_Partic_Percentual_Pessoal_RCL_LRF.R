# ========================================================================================================
# Organização de T20A.Demonstrativo da Participação Percentual de Pessoal na Receita Corrente Líquida A – LRF

# Neste demonstrativo NÃO são deduzidas as despesas com a Fonte 58
# 2022 T20B não faz mais sentido, nao existe mais fonte 58, usar is_dtp :: relatorios

options(warn=1, scipen = 999)


suppressMessages(require(relatorios))

source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("utils/suporte/V1/DTP.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Elemento_Item.R", encoding = "UTF-8")

# =====================================================================================
# Formula da Despesa Bruta com pessoal utilizada na LOA 2016
# Nessa fórmula, para 2016, não há a condição:
# base[ANO == 2016 & GRUPO_COD == 1 & ELEMENTO_ITEM_COD %in% c(1204, 1605), `:=`(DBP, FALSE)]
#
# is_dbp2016 = function(base){
#   base$DBP <- FALSE
#   base[GRUPO_COD == 1 & ELEMENTO_COD != 93, `:=`(DBP, TRUE)]
#   base[IPU_COD == 5 & ACAO_COD != 7016 & !ELEMENTO_COD %in% c(5, 93), `:=`(DBP, TRUE)]
#     return(base$DBP)
# }

# =====================================================================================
# Formula da Despesa Total com pessoal utilizada na LOA 2016
#
# is_dtp_loa2016, deduz_f58 = FALSE = function(base){
#   base$DTP <- FALSE
#   base[is_dbp2016(base), `:=`(DTP, TRUE)]
#   base[ELEMENTO_COD == 94, `:=`(DTP, FALSE)]
#   base[ANO != 2013 & IPU_COD == 9, `:=`(DTP, FALSE)]
#   base[ANO != 2013 & ELEMENTO_COD == 92, `:=`(DTP, FALSE)]
#   base[ANO >= 2014 & FONTE_COD %in% c(30, 75) & ELEMENTO_COD == 1, `:=`(DTP, FALSE)]
#   base[ANO >= 2014 & FONTE_COD %in% c(42, 43, 44, 58, 60, 81) & IPU_COD == 5, `:=`(DTP, FALSE)]
#   base[ANO >= 2014 & UO_COD == 2361 & FONTE_COD == 60 & ELEMENTO_COD %in% c(1, 3, 59), `:=`(DTP, FALSE)]
#   base[ANO >= 2014 & UO_COD == 4431 & FONTE_COD == 60, `:=`(DTP, FALSE)]
#   base[ANO >= 2016 & UO_COD == 2121 & FONTE_COD %in% c(49, 50) & ACAO_COD == 4016, `:=`(DTP, FALSE)]
#   return(base$DTP)
# }

geraPerc = function(x) return(round(x*100,2))

#receita = trataReceita_Fiscal_antigo("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL_2017.xlsx", F)
receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", F)
loa_rec = geraLoa_rec(receita)
#loa_rec[, RECEITA_COD_2 := RECEITA_COD]
setnames(loa_rec, "VL_LOA_REC", "VL_REC")

loa_desp = trataQDD_Elemento_Item("bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx", T)

setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

# =============== A - Receita Corrente Líquida =========================
parteA_desc =  "A - Receita Corrente Líquida para Cálculo de Despesa de Pessoal"
vl_rcl = sum(loa_rec[is_rcl_pessoal(loa_rec), VL_REC])
parteA = data.table(cod=1, espec = parteA_desc, perc = NA, valor= vl_rcl)

# =============== B - Limite das Despesas com Pessoal, Disciplinado pela Lei 101/2000 ========
parteB_desc =  "B - Limite das Despesas com Pessoal, Disciplinado pela Lei 101/2000"
percent_orc = "Percentual do Orçamento"
parteB = data.table(cod=2, espec = parteB_desc, perc = NA, valor=NA)

# =============== B - Legislativo e TCE ===============================================
desc_legisl = "Poder Legislativo (inclusive Tribunal de Contas)"
vl_legisl = loa_desp[is_dtp(loa_desp) & 
            (is_legislativo(loa_desp) | is_tce(loa_desp)), 
             sum(VL_DESP)]
perc_legisl = 0.03

parte_legisl = data.table(cod=c(3,4), 
                          espec=c(desc_legisl, percent_orc), 
                          perc = c(geraPerc(perc_legisl), geraPerc(vl_legisl / vl_rcl)),
                          valor = c(perc_legisl*vl_rcl, vl_legisl)
                          )

# =============== B - Judiciário ======================================================
desc_jud = "Poder Judiciário"
vl_jud = loa_desp[is_dtp(loa_desp) & 
                    (is_judiciario(loa_desp)), sum(VL_DESP)]
perc_jud = 0.06

parte_jud = data.table(cod=c(5,6),
                       espec=c(desc_jud, percent_orc), 
                       perc = c(geraPerc(perc_jud), geraPerc(vl_jud / vl_rcl)),
                       valor = c(perc_jud*vl_rcl, vl_jud)
                      )

# =============== B - Ministério Público ===============================================
desc_pgj = "Poder Ministério Público"
vl_pgj = loa_desp[is_dtp(loa_desp) & (is_pgj(loa_desp)), sum(VL_DESP)]
perc_pgj = 0.02

parte_pgj = data.table(cod=c(7,8),
                       espec=c(desc_pgj, percent_orc), 
                       perc = c(geraPerc(perc_pgj), geraPerc(vl_pgj / vl_rcl)),
                       valor = c(perc_pgj*vl_rcl, vl_pgj)
                      )


# =============== B - Poder Executivo ==================================================
desc_executivo = "Poder Executivo (inclusive Defensoria Pública)"
vl_executivo = loa_desp[is_dtp(loa_desp) & !(is_pgj(loa_desp) | is_legislativo(loa_desp) | 
                                               is_tce(loa_desp) | is_judiciario(loa_desp)), sum(VL_DESP)]
perc_executivo = 0.49
parte_executivo = data.table(cod=c(9,10),
                             espec=c(desc_executivo, percent_orc),
                             perc = c(geraPerc(perc_executivo), geraPerc(vl_executivo / vl_rcl)),
                             valor = c(perc_executivo*vl_rcl, vl_executivo)
                             )

# =============== B - Total de pessoal do Estado =======================================
desc_total_pessoal = "Total Pessoal do Estado"
desc_lrf = "Lei de Responsabilidade Fiscal"
vl_total = loa_desp[is_dtp(loa_desp), sum(VL_DESP)]
perc_total = 0.6

parte_total = data.table(cod = c(11, 12, 13),
                         espec = c(desc_total_pessoal, desc_lrf, percent_orc),
                         perc = c(NA, geraPerc(perc_total), geraPerc(vl_total / vl_rcl)),
                         valor = c(NA, perc_total*vl_rcl, vl_total)
                         )


# ============== Agregando... ===========================================================================
demonstr = rbindlist(list(parteA, 
                          parteB, 
                          parte_legisl, 
                          parte_jud, 
                          parte_pgj, 
                          parte_executivo, 
                          parte_total), use.names = T)

demonstr = demonstr[,lapply(.SD, formatarNum)]
demonstr[, espec := correcaoCaracteresEspeciais(espec, caracteres)]

write.table(demonstr, "volume1/data/T20A_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_LRF.txt",
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)
