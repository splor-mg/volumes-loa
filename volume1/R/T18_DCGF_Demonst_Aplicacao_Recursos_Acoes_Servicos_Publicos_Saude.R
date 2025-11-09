# ========================================================================================================
# Organização de T18. Demonstrativo da Aplicação de Recursos em Ações e Serviços Públicos de Saúde
options(warn=1, scipen = 999)

suppressMessages(require(relatorios))

source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("utils/suporte/V1/demonstr_asps_rec.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")
#source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Elemento_Item.R", encoding = "UTF-8")


sumario = data.table(read.table("volume2/data/sumario.txt", header=T, sep="\t",stringsAsFactors =F))

# receita = trataReceita_Fiscal_antigo("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL_2017.xlsx", F)
receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", F)
loa_rec = geraLoa_rec(receita)
# loa_rec[, RECEITA_COD_2 := RECEITA_COD]

setnames(loa_rec, tolower(names(loa_rec)))
asps = demonstr_asps_rec(loa_rec)

total_receita_liquida = asps[nvl==1 & grepl("^(I|II) -.+", espec), sum(vl_loa)] - 
  asps[nvl==1 & grepl("III - DEDUÇÕES.+", espec), sum(vl_loa)]

if(total_receita_liquida!= loa_rec[is_asps_rec(loa_rec), sum(vl_loa_rec)]){
  warning("T18_DCGF_Demonst_Aplicacao_Recursos_Acoes_Servicos_Publicos_Saude: Receita asps via ",
          "demonstr_asps_rec ", formatarNum(total_receita_liquida), 
          " é diferente do apresentado em relatorios ",
          loa_rec[is_asps_rec(loa_rec), formatarNum(sum(vl_loa_rec))], "\n")
}

asps = rbind(data.table(espec = "A. TOTAL DAS RECEITAS PARA APURAÇÃO DA ASPS (I + II - III)",
                        nvl = 0,
                        vl_loa = total_receita_liquida),
             asps)

asps = asps[, cod:= NA]

loa_desp = trataQDD_Elemento_Item("bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx", FALSE)

#loa_desp = geraLoa_item_desp(qdd)

setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

loa_desp = mergeDT(loa_desp, sumario, by.x="UO_COD", by.y="COD_UO", all.x=T)

if(length(loa_desp[, unique(merge)])>1){
  
  stop("T18_DCGF_Demonst_Aplicacao_Recursos_Acoes_Servicos_Publicos_Saude: Há UO's que não possuem seu descritivo ",
       "em volume2/data/sumario.txt. É o caso de:",
       paste(loa_desp[merge!="Em ambos os bancos", unique(UO_COD)], collapse=", "), "\n")
  
}


# =============== B. DESPESA COM SAÚDE ============
parteB_desc =  "B. DESPESA COM SAÚDE"

setnames(loa_desp, tolower(names(loa_desp)))
loa_desp = loa_desp[is_asps_desp(loa_desp, "elemento_item_cod"),]


parteB = loa_desp[, list(vl_loa = sum(vl_desp), nvl=1), 
                  by= list(cod = paste0(uo_cod,".", funcao_cod), espec = uo)][order(cod)]

parteB = rbind(data.table(cod=NA, 
                          espec = parteB_desc, 
                          vl_loa = parteB[, sum(vl_loa)], nvl=0),
               parteB)

# =============== C. Aplicação em (%) =======================================

parteC_desc = "C - Percentual de Aplicação de Recursos nas Ações e Serviços Públicos de Saúde - B/A Aplicação Mínima 12,00%"

valorC = round(parteB[espec ==parteB_desc, vl_loa]*100 / total_receita_liquida,2)

parteC = data.table(cod=NA,
                    nvl = 0,
                    espec = parteC_desc, 
                    vl_loa = paste0(paste0(format(valorC, 
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

