# =================================================================================================
# Organização de T38. Demonstrativo das Receitas e Despesas Previdenciárias do Regime Próprio de 
# Previdência dos Servidores
options(warn = 1, scipen = 999)

suppressMessages(require(relatorios))
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("utils/suporte/V1/demonstr_despesas_previdenciarias.R", encoding = "UTF-8")
source("utils/suporte/V1/demonstr_receitas_previdenciarias.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Elemento_Item.R", encoding = "UTF-8")
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")

loa_desp = trataQDD_Elemento_Item("bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx", F)

desp_prev = demonstr_despesas_previdenciarias(loa_desp)

total_despesas = desp_prev[nvl==1, sum(VL_LOA)]

if(total_despesas!=loa_desp[is_despesas_previdenciarias(loa_desp), sum(VL_LOA_DESP)]){
  warning("T38_DCGF_DEMONSTRATIVO_RECEITAS_DESPESAS_PREVIDENCIARIAS_RPPS.R Valor de despesas",
          "previdenciarias em funcoes.R ", 
          loa_desp[is_despesas_previdenciarias(loa_desp), formatarNum(sum(VL_LOA_DESP))],
          " diferente do valor calculado em demonstr_despesas_previdenciarias ",
          formatarNum(total_despesas), "\n")
}

desp_prev = rbind(data.table(espec = "DESPESAS PREVIDENCIÁRIAS - RPPS", 
                             nvl = 0,
                             VL_LOA = total_despesas),
                  desp_prev)

receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", F)
# receita = trataReceita_Fiscal_antigo("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL_2017.xlsx", F)
loa_rec = geraLoa_rec(receita)
loa_rec[, RECEITA_COD_2 := RECEITA_COD]

rec_prev = demonstr_receitas_previdenciarias(loa_rec)

total_receitas = rec_prev[nvl==1, sum(VL_LOA)]

if(total_receitas!=loa_rec[is_receitas_previdenciarias(loa_rec), sum(VL_LOA_REC)]){
  warning("T38_DCGF_DEMONSTRATIVO_RECEITAS_DESPESAS_PREVIDENCIARIAS_RPPS.R Valor de receitas",
          "previdenciarias em funcoes.R ", 
          loa_rec[is_receitas_previdenciarias(loa_rec), formatarNum(sum(VL_LOA_REC))],
          " diferente do valor calculado em demonstr_receitas_previdenciarias ",
          formatarNum(total_receitas), "\n")
}


rec_prev = rbind(data.table(espec = "RECEITAS PREVIDENCIÁRIAS - RPPS", 
                             nvl = 0,
                             VL_LOA = total_receitas),
                  rec_prev)

demonstrativo = rbind(rec_prev, desp_prev)

demonstrativo = rbind(demonstrativo,
                      data.table(espec = "RESULTADO PREVIDENCIÁRIO - DÉFICIT",
                                 nvl=0,
                                 VL_LOA = total_receitas - total_despesas))

demonstrativo[, espec := correcaoCaracteresEspeciais(espec, caracteres)]
demonstrativo[, VL_LOA := negativoContabil(formatarNum(VL_LOA))]

write.table(demonstrativo, 
            "volume1/data/T38_DCGF_DEMONSTRATIVO_RECEITAS_DESPESAS_PREVIDENCIARIAS_RPPS.txt",
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)

