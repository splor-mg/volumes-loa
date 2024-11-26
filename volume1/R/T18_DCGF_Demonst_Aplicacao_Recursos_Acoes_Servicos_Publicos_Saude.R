# ========================================================================================================
# Organização de T18. Demonstrativo da Aplicação de Recursos em Ações e Serviços Públicos de Saúde
options(warn=1, scipen = 999)

suppressMessages(require(relatorios))

source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("utils/suporte/V1/demonstr_asps_rec.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

sumario = data.table(read.table("volume2/data/sumario.txt", header=T, sep="\t",stringsAsFactors =F))

# receita = trataReceita_Fiscal_antigo("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL_2017.xlsx", F)
receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", F)
loa_rec = geraLoa_rec(receita)
# loa_rec[, RECEITA_COD_2 := RECEITA_COD]

asps = demonstr_asps_rec(loa_rec)

total_receita_liquida = asps[nvl==1 & grepl("^(I|II) -.+", espec), sum(VL_LOA)] - 
  asps[nvl==1 & grepl("III - DEDUÇÕES.+", espec), sum(VL_LOA)]

if(total_receita_liquida!= loa_rec[is_asps_rec(loa_rec), sum(VL_LOA_REC)]){
  warning("T18_DCGF_Demonst_Aplicacao_Recursos_Acoes_Servicos_Publicos_Saude: Receita asps via ",
          "demonstr_asps_rec ", formatarNum(total_receita_liquida), 
          " é diferente do apresentado em relatorios ",
          loa_rec[is_asps_rec(loa_rec), formatarNum(sum(VL_LOA_REC))], "\n")
}

asps = rbind(data.table(espec = "A. TOTAL DAS RECEITAS PARA APURAÇÃO DA ASPS (I + II - III)",
                        nvl = 0,
                        VL_LOA = total_receita_liquida),
             asps)

asps = asps[, cod:= NA]


qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
loa_desp = geraLoa_desp(qdd)
setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

loa_desp = mergeDT(loa_desp, sumario, by.x="UO_COD", by.y="COD_UO", all.x=T)

if(length(loa_desp[, unique(merge)])>1){
  
  stop("T18_DCGF_Demonst_Aplicacao_Recursos_Acoes_Servicos_Publicos_Saude: Há UO's que não possuem seu descritivo ",
       "em volume2/data/sumario.txt. É o caso de:",
       paste(loa_desp[merge!="Em ambos os bancos", unique(UO_COD)], collapse=", "), "\n")
  
}


# =============== B. DESPESA COM SAÚDE ============
parteB_desc =  "B. DESPESA COM SAÚDE"

loa_desp = loa_desp[is_asps_desp(loa_desp, "ELEMENTO_ITEM_COD"),]
loa_desp = loa_desp[!(MODALIDADE_COD==91 & ELEMENTO_COD == 41)]

parteB = loa_desp[, list(VL_LOA = sum(VL_DESP), nvl=1), 
                  by= list(cod = paste0(UO_COD,".", FUNCAO_COD), espec = UO)][order(cod)]

parteB = rbind(data.table(cod=NA, 
                          espec = parteB_desc, 
                          VL_LOA = parteB[, sum(VL_LOA)], nvl=0),
               parteB)

# =============== C. Aplicação em (%) =======================================

parteC_desc = "C - Percentual de Aplicação de Recursos nas Ações e Serviços Públicos de Saúde - B/A Aplicação Mínima 12,00%"

valorC = round(parteB[espec ==parteB_desc, VL_LOA]*100 / total_receita_liquida,2)

parteC = data.table(cod=NA,
                    nvl = 0,
                    espec = parteC_desc, 
                    VL_LOA = paste0(paste0(format(valorC, 
                                                  big.mark=".", 
                                                  scientific = FALSE, 
                                                  decimal.mark = ",", 
                                                  nsmall = 2), "\\%")))

# ============== Agregando... ===================

demonstr = rbindlist(list(asps, parteB), use.names = T)

demonstr = demonstr[,lapply(.SD, formatarNum)]

demonstr = rbind(demonstr, parteC, use.names = T)

demonstr[, espec:= correcaoCaracteresEspeciais(espec, caracteres)]

write.table(demonstr, "volume1/data/T18_DCGF_Demonst_Aplicacao_Recursos_Acoes_Servicos_Publicos_Saude.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)

