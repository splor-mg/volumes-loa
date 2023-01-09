# ========================================================================================================
# Organização de T20B.Demonstrativo da Participação Percentual de Pessoal na Receita Corrente Líquida A – TCE

# 1. Alterar as funções utilizadas de dbp e dbt
# 2. Alterar a função da receita

options(warn=1, scipen = 999)

suppressMessages(require(relatorios))

source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Elemento_Item.R", encoding = "UTF-8")

is_deducoes_tce = function(base){
  base$deducao_tce = FALSE
  
  base[ELEMENTO_COD %in% c(1,3,59) & 
       FONTE_COD %in% c(10,60,27) & 
       !UO_COD %in% c(2361, 4431, 4711), deducao_tce := TRUE ]
  
  return(base$deducao_tce)
}

geraPerc = function(x) return(round(x*100,2))

# receita = trataReceita_Fiscal_antigo("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL_2017.xlsx", F)
receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", F)
loa_rec = geraLoa_rec(receita)
#loa_rec[, RECEITA_COD_2 := RECEITA_COD]
setnames(loa_rec, "VL_LOA_REC", "VL_REC")

loa_desp = trataQDD_Elemento_Item("bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx", T)
loa_desp[, ANO := receita[1, ANO]]
setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

# =============== A - Receita Corrente Líquida =========================
parteA_desc =  "A - Receita Corrente Líquida"
vl_rcl = sum(loa_rec[is_rcl(loa_rec), VL_REC])
parteA = data.table(cod=1, espec = parteA_desc, perc = NA, valor= vl_rcl)


# =============== B - Limite das Despesas com Pessoal, Disciplinado pela Lei 101/2000 ========
parteB_desc =  "B - Limite das Despesas com Pessoal, Disciplinado pela Lei 101/2000 E INSTRUÇÃO Nº  5/2001 - TCMG"
percent_orc = "Percentual do Orçamento"
parteB = data.table(cod=2, espec = parteB_desc, perc = NA, valor=NA)

# =============== B - Legislativo e TCE ===============================================
desc_legisl = "Poder Legislativo (inclusive Tribunal de Contas)"
vl_legisl = loa_desp[is_dtp(loa_desp) & !is_deducoes_tce(loa_desp)  & (is_legislativo(loa_desp) | is_tce(loa_desp)), 
                     sum(VL_DESP)]
perc_legisl = 0.03
parte_legisl = data.table(cod=c(3,4), 
                          espec=c(desc_legisl, percent_orc), 
                          perc = c(geraPerc(perc_legisl), geraPerc(vl_legisl / vl_rcl)),
                          valor = c(perc_legisl*vl_rcl, vl_legisl)
                          )

# =============== B - Judiciário ======================================================
desc_jud = "Poder Judiciário"
vl_jud = loa_desp[is_dtp(loa_desp) & !is_deducoes_tce(loa_desp) & (is_judiciario(loa_desp)), sum(VL_DESP)]
perc_jud = 0.06

parte_jud = data.table(cod=c(5,6),
                       espec=c(desc_jud, percent_orc), 
                       perc = c(geraPerc(perc_jud), geraPerc(vl_jud / vl_rcl)),
                       valor = c(perc_jud*vl_rcl, vl_jud)
                      )

# =============== B - Ministério Público ===============================================
desc_pgj = "Poder Ministério Público"
vl_pgj = loa_desp[is_dtp(loa_desp) & !is_deducoes_tce(loa_desp) & (is_pgj(loa_desp)), sum(VL_DESP)]
perc_pgj = 0.02

parte_pgj = data.table(cod=c(7,8),
                       espec=c(desc_pgj, percent_orc), 
                       perc = c(geraPerc(perc_pgj), geraPerc(vl_pgj / vl_rcl)),
                       valor = c(perc_pgj*vl_rcl, vl_pgj)
                      )

# =============== B - Poder Executivo ==================================================
desc_executivo = "Poder Executivo"
vl_executivo = loa_desp[is_dtp(loa_desp) & !is_deducoes_tce(loa_desp) & !(is_pgj(loa_desp) | is_legislativo(loa_desp) | 
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
vl_total = loa_desp[is_dtp(loa_desp) & !is_deducoes_tce(loa_desp) , sum(VL_DESP)]
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

write.table(demonstr, "volume1/data/T20B_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_TCE.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)
