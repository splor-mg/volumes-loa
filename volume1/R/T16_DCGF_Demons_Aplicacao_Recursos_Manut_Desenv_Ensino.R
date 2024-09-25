# =================================================================================================
# Organização de T16. Demonstrativo da Aplicação de Recursos na Manutenção e no Desenvolvimento do Ensino
options(warn = 1, scipen = 999)

suppressMessages(require(relatorios))
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("utils/suporte/V1/demonstr_mde_rec.R", encoding = "UTF-8")


# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Elemento_Item.R", encoding = "UTF-8")

loa_desp = trataQDD_Elemento_Item("bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx", F)
setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

#andrey #apagar #receitas mudança governo aqui deve ser a forma que é tratada quando a forma das receitas muda
receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", F)
# receita = trataReceita_Fiscal_antigo("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL_2017.xlsx", F)

loa_rec = geraLoa_rec(receita)
# loa_rec[, RECEITA_COD_2 := RECEITA_COD]

sumario = data.table(read.table("volume2/data/sumario.txt", header=T, sep="\t",stringsAsFactors =F))

mde = demonstr_mde_rec(loa_rec)

total_receita_liquida = mde[nvl==1 & !grepl("^3.+", espec), sum(VL_LOA)] - 
  mde[nvl==1 & grepl("^3 - DEDUÇÕES.+", espec), sum(VL_LOA)]

if(total_receita_liquida!= loa_rec[is_mde_rec(loa_rec), sum(VL_LOA_REC)]){
  warning("T16_DCGF_Demons_Aplicacao_Recursos_Manut_Desenv_Ensino: Receita mde via demonstr_mde_rec ",
          formatarNum(total_receita_liquida), " é diferente do apresentado em relatorios ",
          loa_rec[is_mde_rec(loa_rec), formatarNum(sum(VL_LOA_REC))], "\n")
}

mde = rbind(mde, data.table(espec = "A. TOTAL DA RECEITA LÍQUIDA (1 + 2 - 3)",
                            nvl = 0,
                            VL_LOA = total_receita_liquida))
mde = mde[, cod:= NA]

# =============== E - DESPESA COM MANUTENÇÃO E DESENVOLVIMENTO DE ENSINO ===
parteE_desc = "B - DESPESAS COM MANUTENÇÃO E DESENVOLVIMENTO DE ENSINO CUSTEADAS COM RECURSOS DE IMPOSTOS"

parteE = loa_desp[is_mde_desp(loa_desp) & FONTE_COD %in% c(10, 71) , ]
parteE = mergeDT(parteE, sumario, by.x="UO_COD", by.y="COD_UO", all.x=T)

if(length(parteE[, unique(merge)])>1){
  stop("T16_DCGF_Demons_Aplicacao_Recursos_Manut_Desenv_Ensino: Há UO's que não possuem seu descritivo ",
       "em volume2/data/sumario.txt. É o caso de:",
       paste(parteE[merge!="Em ambos os bancos", unique(UO_COD)], collapse=", "), "\n")
}

parteE = parteE[, list(VL_LOA = sum(VL_DESP), nvl = 1), 
                by=list(cod = paste0(UO_COD, " . ", FUNCAO_COD), espec = UO)]

#vl_perda_fundeb = abs(loa_rec[is_perda_fundeb(loa_rec), sum(VL_LOA_REC)])

vl_transf_fundeb = abs(loa_rec[FONTE_COD == 23 & nat(RECEITA_COD, 9), sum(VL_LOA_REC)])


#adicionado para LOA 2021.
#vl_perda_fundeb = vl_perda_fundeb + loa_rec[RECEITA_COD %in% c(1758011103005,1758011107005, 1758011108005) , sum(VL_LOA_REC)]


#parametro de correção retirar em 2022-2023 (#apagar)
#vl_perda_fundeb = vl_perda_fundeb + 752396916

#vl_perda_fundeb = vl_perda_fundeb


#vl_perda_fundeb = abs(loa_rec[is_perda_fundeb_3(loa_rec), sum(VL_LOA_REC)])

# 
# perda_fundeb = data.table(espec ="PERDA DO ESTADO COM O FUNDEB PARA O MUNICÍPIO", 
#                           VL_LOA = vl_perda_fundeb,
#                           nvl = 0,
#                           cod = NA)

transf_fundeb = data.table(espec ="C - TRANSFERÊNCIAS DO ESTADO AO FUNDEB", 
                          VL_LOA = vl_transf_fundeb,
                          nvl = 0,
                          cod = NA)

vl_mde = parteE[,sum(VL_LOA)]


despesas_lmc_desc = "D - TOTAL DAS DESPESAS PARA FINS DE LIMITE MÍNIMO CONSTITUCIONAL (B+C)"

despesas_lmc = data.table(espec =despesas_lmc_desc, 
                           VL_LOA = vl_mde + vl_transf_fundeb,
                           nvl = 0,
                           cod = NA)

parteE = rbind(data.table(espec = parteE_desc, 
                          VL_LOA = parteE[,sum(VL_LOA)],
                          nvl = 0, cod=NA), 
               parteE)

parteE = rbind(parteE, transf_fundeb)
parteE = rbind(parteE, despesas_lmc )



#====================== F ========================

parteF_desc = "E - Percentual de aplicação da receita resultante de impostos e de transferência na manutenção e desenvolvimento do ensino - B/A aplicação mínima 25%"

valorE = round(parteE[espec ==despesas_lmc_desc, VL_LOA]*100 / total_receita_liquida,2)
parteF = data.table(cod = NA, espec = parteF_desc, nvl = 0, VL_LOA = paste0(format(valorE, 
                                                                                   big.mark=".", 
                                                                                   scientific = FALSE, 
                                                                                   decimal.mark = ",", 
                                                                                   nsmall = 2), "\\%"))

# ============== Agregando... ===================

demonstr = rbindlist(list(mde, parteE), use.names = T)
demonstr = demonstr[,lapply(.SD, formatarNum)]

demonstr = rbind(demonstr, parteF, use.names = T)

setcolorder(demonstr, c("cod", "nvl", "espec", "VL_LOA"))

demonstr[, espec := correcaoCaracteresEspeciais(espec, caracteres)]

write.table(demonstr, "volume1/data/T16_DCGF_Demons_Aplicacao_Recursos_Manut_Desenv_Ensino.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)

