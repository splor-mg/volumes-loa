# =================================================================================================
# Organização de T8 Receita corrente liquida
options(warn=1, scipen = 999)

suppressMessages(require(relatorios))

source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("utils/suporte/V1/demonstr_rcl.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")

# ============================================================
# Codificação antiga da receita
# receita = trataReceita_Fiscal_antigo("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL_2017.xlsx", F)
# rec = geraLoa_rec(receita)
# rcl = demonstr_rcl_classificacao_antiga(rec)
# vl_rcl_relatorios = rec[is_rcl(rec), sum(VL_LOA_REC)]

# ============================================================
# Nova codificação da receita

receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", F)
rec = geraLoa_rec(receita)
rec[, RECEITA_COD_2 := RECEITA_COD]
rcl = demonstr_rcl(rec)
vl_rcl_relatorios = rec[is_rcl_pessoal(rec), sum(VL_LOA_REC)]


if(vl_rcl_relatorios!=rcl[nrow(rcl), VL_LOA_REC]){
  warning("Valor de RCL pelo pkg relatorios (", formatarNum(vl_rcl_relatorios), 
          ") é diferente do apresentado no demonstrativo (", formatarNum(rcl[nrow(rcl), VL_LOA_REC]), 
          "). Avaliar o demonstrativo em utils/rcl.R")
}

rcl = rcl[,lapply(.SD, formatarNum)]
rcl[, espec := correcaoCaracteresEspeciais(espec, caracteres, is_maiscula = F)]
rcl[, nvl := as.numeric(nvl)]

write.table(rcl, "volume1/data/T8_DCGF_RECEITA_CORRENTE_LIQUIDA.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)

