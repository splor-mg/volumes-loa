# =================================================================================================
# Organização de T1. Demonstrativo Consolidado do Orçamento Fiscal
options(warn=1, scipen = 999)

suppressMessages(require(relatorios))

source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("utils/suporte/V1/demonstr_consolidado.R", encoding = "UTF-8")
source("utils/suporte/V1/checa_demonstrativo_consolidado.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

rec_ordinario = c(10,11,12,15)

receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", F)
loa_rec = geraLoa_rec(receita)

classificacao = data.table(read_excel("bancos/manual/desc_classificacao_receita.xlsx"))
classificacao = classificacao[RECEITA_COD=="DETALHE", 
                              list(RECEITA_COD = RECEITA_COD_2, RECEITA_DESC = RECEITA_DESC_2)]
classificacao$RECEITA_COD = as.numeric(as.character(classificacao$RECEITA_COD))

loa_rec = rbind(loa_rec, classificacao, fill=T)
loa_rec[is.na(loa_rec)] = 0

loa_rec[, ANO:=max(loa_rec$ANO)]

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
loa_desp = geraLoa_desp(qdd)
loa_desp[, ANO:=max(loa_rec$ANO) - 1]

rm(receita, qdd)

## ============================================================================
## Demonstrativo 1 apresentando apenas as despesas e receitas previdenciarias
## As demais despesas serão zeradas
#
# source("utils/trataBancos/trataQDD_Elemento_Item.R", encoding = "UTF-8")
# loa_desp = trataQDD_Elemento_Item("bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx", F)
# loa_desp[, ANO:=2017]
# loa_desp[!is_despesas_previdenciarias(loa_desp), VL_LOA_DESP:=0]
# loa_rec[!is_receitas_previdenciarias(loa_rec), VL_LOA_REC:=0]


# ============ Banco LOA Receita =====================================================
loa_rec[FONTE_COD %in% rec_ordinario, recurso := "ordinaria_rec"]
loa_rec[!FONTE_COD %in% rec_ordinario, recurso := "vinculada_rec"]

loa_rec = demonstrativo_consolidado_rec(loa_rec)

#### =============== Agrega pelo Niveis =======================================
nivel1 = loa_rec[!is.na(nvl1), list(valor=sum(VL_LOA_REC, na.rm=T)), by=list(nvl1, receita = desc1, recurso)]

nivel2 = loa_rec[!is.na(nvl2), 
                 list(valor=sum(VL_LOA_REC, na.rm=T)), 
                 by=list(nvl1, nvl2, receita = paste0(strrep(" ",2), desc2), recurso)]

nivel3 = loa_rec[!is.na(nvl3), 
                 list(valor=sum(VL_LOA_REC, na.rm=T)), 
                 by=list(nvl1, nvl2, nvl3, receita = paste0(strrep(" ",4), desc3), recurso)]

nivel4 = loa_rec[!is.na(nvl4), 
                 list(valor=sum(VL_LOA_REC, na.rm=T)), 
                 by=list(nvl1, nvl2, nvl3, nvl4, receita = paste0(strrep(" ",6), desc4), recurso)]

painel_rec = rbindlist(list(nivel1, nivel2, nivel3, nivel4), fill=T)

painel_rec[is.na(painel_rec)] = 0

painel_rec[, ordem_rec := paste(nvl1, formatC(nvl2, width = 2, flag = "0"), 
                            formatC(nvl3, width = 2, flag = "0"), nvl4, sep="-")]

painel_rec = dcast(painel_rec, ordem_rec + receita ~ recurso, value.var = "valor", fill=0)

painel_rec[, total_rec:= ordinaria_rec + vinculada_rec]

# Adiciona linha de total sem intra
painel_rec = rbind(painel_rec, painel_rec[grepl("^[1-9]-00-00-0$", ordem_rec), lapply(.SD, sum), .SDcols = 3:5], fill=T)
painel_rec[nrow(painel_rec), 
           c("ordem_rec", "receita"):= list("10-00-00-0","TOTAL DA RECEITA FISCAL (EXCETO INTRA-ORÇAMENTÁRIAS)")]

# Adiciona linha de intra
intra_rec = loa_rec[nat(RECEITA_COD, 7), list(valor=sum(VL_LOA_REC, na.rm=T), 
                                              receita = "TOTAL DA RECEITA INTRA-ORÇAMENTÁRIA",
                                              ordem_rec= "10-01-00-0"), by=list(recurso)]

intra_rec = dcast(intra_rec, ordem_rec + receita ~ recurso, value.var = "valor", fill=0)
intra_rec[, total_rec := vinculada_rec + ordinaria_rec ]
painel_rec = rbind(painel_rec, intra_rec)

# Adiciona o total considerando o intra
painel_rec = rbind(painel_rec, painel_rec[grepl("^10.+", ordem_rec), lapply(.SD, sum), .SDcols = 3:5], fill=T)
painel_rec[nrow(painel_rec), c("ordem_rec", "receita"):= list("10-02-00-0","TOTAL DA RECEITA FISCAL")]

painel_rec[, part_ord_rec:= round(ordinaria_rec*100 / painel_rec[ordem_rec=="10-00-00-0", ordinaria_rec],2)]
painel_rec[, part_vinc_rec:= round(vinculada_rec*100 / painel_rec[ordem_rec=="10-00-00-0", vinculada_rec],2)]
painel_rec[, part_total_rec:= round(total_rec*100 / painel_rec[ordem_rec=="10-00-00-0", total_rec],2)]

painel_rec[grepl("10-0[1-2].+", ordem_rec), c("part_ord_rec", "part_vinc_rec", "part_total_rec"):=100]

setcolorder(painel_rec, c("ordem_rec", "receita", "ordinaria_rec", "part_ord_rec", 
                          "vinculada_rec", "part_vinc_rec", "total_rec", "part_total_rec"))

# Organiza painel_rec com linhas em branco para facilitar a montagem do excel com o demonstrativo

painel_rec = painel_rec[, lapply(.SD, formatarNum)]

painel_rec_final = painel_rec[grepl("^10.+", ordem_rec), ]
painel_rec = painel_rec[!grepl("^10.+", ordem_rec), ]

nova_linha = data.table(ordem_rec="", receita="", ordinaria_rec="", part_ord_rec="", 
                        vinculada_rec="", part_vinc_rec="", total_rec="", part_total_rec="")

painel_rec1 = rbind(painel_rec[1, ], nova_linha)

for(i in 2:nrow(painel_rec)){
  if(grepl("^(2|9)-00-00-0$", painel_rec[i, ordem_rec])){
    painel_rec1 = rbindlist(list(painel_rec1, nova_linha, painel_rec[i, ]))
  }  else{
    painel_rec1 = rbind(painel_rec1, painel_rec[i, ])
  }
}

painel_rec1 = rbind(painel_rec1, nova_linha)
painel_rec1[, ordem_rec:=1:nrow(painel_rec1)]

# Salva painel_rec para testes
painel_rec_para_teste = rbind(painel_rec1, painel_rec_final, fill=T)
write.csv2(painel_rec_para_teste, paste0("utils/suporte/V1/painel_rec", loa_rec[, max(ANO)], ".csv"),
           row.names=F)

# ======= Banco LOA DESPESA ==========================================================
loa_desp = adiciona_desc(loa_desp, "GRUPO")

loa_desp[FONTE_COD %in% rec_ordinario, recurso := "ordinaria"]
loa_desp[!FONTE_COD %in% rec_ordinario, recurso := "vinculada"]

# === Nivel 3 =====
loa_desp = loa_desp[, c("poder_tipo", "nvl3"):= list(paste0(strrep(" ",4), "EXECUTIVO"), 1)]

loa_desp = loa_desp[relatorios::is_outros_poderes(loa_desp), 
                    c("poder_tipo", "nvl3"):= list(paste0(strrep(" ",4), "OUTROS PODERES"), 2)]

# === Nivel 4 =====
loa_desp = loa_desp[substr(UO_COD, 1,1)=="1", 
                    c("adm_tipo", "nvl4"):= list(paste0(strrep(" ",5), "ADMINISTRAÇÃO DIRETA"), 1)]

loa_desp = loa_desp[substr(UO_COD, 1,1)!="1", 
                    c("adm_tipo", "nvl4"):= list(paste0(strrep(" ",5), "ADMINISTRAÇÃO INDIRETA"), 2)]

# === Nivel 5 =====
loa_desp = loa_desp[substr(UO_COD, 1,1)=="2", 
                    c("adm_ind_tipo", "nvl5") := list(paste0(strrep(" ",6), "AUTARQUIAS E FUNDAÇÕES"), 1)]

loa_desp = loa_desp[substr(UO_COD, 1,1)=="3", 
                    c("adm_ind_tipo", "nvl5") := list(paste0(strrep(" ",6), "EMPRESAS ESTATAIS DEPENDENTES"), 2)]

loa_desp = loa_desp[substr(UO_COD, 1,1)=="4", 
                    c("adm_ind_tipo", "nvl5") := list(paste0(strrep(" ",6), "FUNDOS"), 3)]

loa_desp[, CATEGORIA_DESC := ifelse(CATEGORIA_COD==3, "DESPESAS CORRENTES", 
                             ifelse(CATEGORIA_COD==4, "DESPESAS DE CAPITAL",
                             ifelse(CATEGORIA_COD==9, "RESERVA DE CONTIGÊNCIA", "ign")))]

# ============== CATEGORIA ====================================================================
cat = loa_desp[MODALIDADE_COD!=91, list(valor=sum(VL_LOA_DESP, na.rm=T)),
               by=list(nvl1 = CATEGORIA_COD, despesa = CATEGORIA_DESC, recurso)]

# ============== GRUPO DE DESPESA =============================================================
gd = loa_desp[MODALIDADE_COD!=91 & ACAO_COD!=7844, 
              list(valor=sum(VL_LOA_DESP, na.rm=T)),
              by=list(nvl1 = CATEGORIA_COD, 
                      nvl2 = GRUPO_COD, 
                      despesa = paste0(strrep(" ",3), GRUPO_DESC), 
                      recurso)]

gd = rbind(gd, loa_desp[MODALIDADE_COD!=91 & ACAO_COD==7844, 
                        list(valor=sum(VL_LOA_DESP, na.rm=T), nvl2 = 4, 
                             despesa = paste0(strrep(" ",3), "REC. CONSTITUCIONAIS VINC. MUNICÍPIOS")),
                        by=list(nvl1 = CATEGORIA_COD, recurso)])

# ============== Poder ========================================================================
pd = loa_desp[MODALIDADE_COD!=91 & ACAO_COD!=7844, list(valor=sum(VL_LOA_DESP, na.rm=T)), 
              by=list(nvl1 = CATEGORIA_COD, nvl2 = GRUPO_COD, nvl3, despesa = poder_tipo, recurso)]

# ============== Tipo de Administração ========================================================
adm = loa_desp[MODALIDADE_COD!=91 & ACAO_COD!=7844, list(valor=sum(VL_LOA_DESP, na.rm=T)), 
              by=list(nvl1 = CATEGORIA_COD, nvl2 = GRUPO_COD, nvl3, nvl4, despesa = adm_tipo, recurso)]

# ============== Tipo de Administração Indireta ========================================================
adm_ind = loa_desp[MODALIDADE_COD!=91 & !is.na(nvl5) & ACAO_COD!=7844, list(valor=sum(VL_LOA_DESP, na.rm=T)), 
              by=list(nvl1 = CATEGORIA_COD, nvl2 = GRUPO_COD, nvl3, nvl4, nvl5, despesa = adm_ind_tipo, recurso)]

# ============== Agregando..===========================

painel_desp = rbindlist(list(cat, gd, pd, adm, adm_ind), use.names = T, fill=T)
painel_desp[is.na(painel_desp)] = 0
painel_desp[, ordem:= paste(nvl1, nvl2, nvl3, nvl4, nvl5, sep="-")]
painel_desp[, c("nvl1", "nvl2", "nvl3", "nvl4", "nvl5"):=NULL]
painel_desp = dcast(painel_desp, ordem + despesa ~ recurso, value.var = "valor", fill=0)
painel_desp[, total := vinculada + ordinaria ]

painel_desp = painel_desp[!grepl("9-9.+", ordem),]

# Total da despesa exceto intra
painel_desp = rbind(painel_desp, painel_desp[grepl("^[0-9]-0.+", ordem), lapply(.SD, sum), .SDcols = 3:5], fill=T)
painel_desp[nrow(painel_desp),c("ordem","despesa"):= list("9-1-0-0-0","TOTAL DA DESPESA FISCAL (EXCETO INTRA - ORÇAMENTÁRIAS)")]

# Adiciona intra
intra = loa_desp[MODALIDADE_COD==91, list(valor=sum(VL_LOA_DESP, na.rm=T), 
                                          despesa = "TOTAL DA DESPESA INTRA - ORÇAMENTÁRIA", 
                                          ordem= "9-2-0-0-0"), by=list(recurso)]

intra = dcast(intra, ordem + despesa ~ recurso, value.var = "valor", fill=0)
intra[, total := vinculada + ordinaria ]
painel_desp = rbind(painel_desp, intra)

# Adiciona despesa total
painel_desp = rbind(painel_desp, painel_desp[grepl("^9-[1-2].+", ordem), lapply(.SD, sum), .SDcols = 3:5], fill=T)
painel_desp[nrow(painel_desp), c("ordem", "despesa"):= list("9-3-0-0-0","TOTAL DA DESPESA FISCAL")]

painel_desp[, part_ord:= round(ordinaria*100 / painel_desp[ordem=="9-1-0-0-0", ordinaria],2)]
painel_desp[, part_vinc:= round(vinculada*100 / painel_desp[ordem=="9-1-0-0-0", vinculada],2)]
painel_desp[, part_total:= round(total*100 / painel_desp[ordem=="9-1-0-0-0", total],2)]

painel_desp[grepl("^9-[2-3].+", ordem), c("part_ord", "part_vinc", "part_total"):=100]

setcolorder(painel_desp, c("ordem", "despesa", "ordinaria", "part_ord", "vinculada", "part_vinc", "total", "part_total"))


# Organiza painel_rec com linhas em branco para facilitar a montagem do excel com o demonstrativo

painel_desp = painel_desp[, lapply(.SD, formatarNum)]

painel_desp_final = painel_desp[grepl("^9-[1-3].+", ordem), ]
painel_desp = painel_desp[!grepl("^9-[1-3].+", ordem), ]

nova_linha = data.table(ordem = "", despesa = "", ordinaria = "", part_ord = "", 
                        vinculada = "", part_vinc = "", total = "", part_total = "")

painel_desp1 = rbind(painel_desp[1, ], nova_linha)

for(i in 2:nrow(painel_desp)){
  if(grepl("^4-0.+", painel_desp[i, ordem])){
    painel_desp1 = rbindlist(list(painel_desp1, nova_linha, painel_desp[i, ], nova_linha))
  } else{
    painel_desp1 = rbind(painel_desp1, painel_desp[i, ])
  }
}

painel_desp1 = rbind(painel_desp1, nova_linha)

# Salva painel_desp para testes
painel_desp_para_teste = rbind(painel_desp1, painel_desp_final, fill=T)
setnames(painel_desp_para_teste, "ordem", "ordem_desp")
write.csv2(painel_desp_para_teste, paste0("utils/suporte/V1/painel_desp", loa_rec[, max(ANO)], ".csv"), 
           row.names=F)

painel_desp1[, ordem:=1:nrow(painel_desp1)]


# ======================================
# Monta o demonstrativo receita e despesa

demonstr = mergeDT(painel_rec1, painel_desp1, by.x="ordem_rec", by.y="ordem", all=T)
demonstr[, c("ordem_rec", "merge"):=NULL]

parte_final = cbind(painel_rec_final, painel_desp_final)

parte_final[, c("ordem_rec", "ordem"):=NULL]
demonstr = rbind(demonstr, parte_final, fill=T)


## REALIZA TESTE PARA OS VALORES
# Caso seja de interesse alterar o limiar modificar o parâmetro limiar abaixo


checa_demonstrativo_consolidado(caminho_rec_ref = "utils/suporte/V1/painel_rec2019.csv",
                                caminho_desp_ref = "utils/suporte/V1/painel_desp2019.csv",
                                limiar = 0.7)



write.csv2(demonstr, "volume1/data/T1_DEMONSTRATIVO_CONSOLIDADO_ORCAMENTO_FISCAL.csv", row.names=F, na="")
