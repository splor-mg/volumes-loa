# =================================================================================================
# Organização de T3 Demonstrativo da Receita e Despesa Segundo as Categorias Econômicas
options(warn = 1, scipen = 999)
suppressMessages(require(relatorios))

source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")

class_receita = ler_novaReceita("bancos/manual/desc_classificacao_receita.xlsx")

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
loa_desp = geraLoa_desp(qdd)
#loa_desp[, ANO:=2017]

receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx")
loa_rec = geraLoa_rec(receita)

# ======= Banco LOA DESPESA ==========================================================
loa_desp = adiciona_desc_volumes(loa_desp, column = "GRUPO")

loa_gd = loa_desp[MODALIDADE_COD!=91, list(vl_desp=sum(VL_LOA_DESP, na.rm=T)), 
                  by=list(DESPESA_DESC = paste0(CATEGORIA_COD, GRUPO_COD, ". ", GRUPO_DESC))]

loa_desp[, CATEGORIA_DESC := ifelse(CATEGORIA_COD==3, "Despesas Correntes", 
                             ifelse(CATEGORIA_COD==4, "Despesas de Capital",
                             ifelse(CATEGORIA_COD==9, "Reserva de Contigência", "ign")))]

loa_cat = loa_desp[MODALIDADE_COD!=91, list(vl_desp_total=sum(VL_LOA_DESP, na.rm=T)), 
                   by=list(DESPESA_DESC = paste0(CATEGORIA_COD, 0, ". ", CATEGORIA_DESC))]

painel_desp = rbind(loa_gd, loa_cat, fill=T)
painel_desp = painel_desp[order(DESPESA_DESC)]
painel_desp = painel_desp[!grepl("^99.+", DESPESA_DESC),]

painel_desp[, ordem:=ifelse(grepl("^3.+", DESPESA_DESC), 0, 4)]
painel_desp[, ordem2:= sequence(.N), by=list(ordem)]
painel_desp[, ordem:=paste0(ordem, ordem2)]
painel_desp[, ordem2:=NULL]

# Insere parte de deducao em desp
total_receita_corrente = loa_rec[nat(RECEITA_COD, 1, 9), sum(VL_LOA_REC, na.rm=T)]
total_despesa_corrente = loa_desp[MODALIDADE_COD!=91 & CATEGORIA_COD==3, sum(VL_LOA_DESP, na.rm=T)]

deficit_corrente = total_receita_corrente - total_despesa_corrente

painel_desp = rbind(painel_desp, 
                    data.table(DESPESA_DESC="Resultado do Orçamento Corrente", 
                               vl_desp_total = deficit_corrente,
                               ordem="10"),fill=T)

# Insere total da despesa corrente
painel_desp = rbind(painel_desp, 
                    data.table(DESPESA_DESC="TOTAL", 
                               vl_desp_total = total_despesa_corrente + deficit_corrente,
                               ordem="20"), fill=T)

# Insere total da despesa capital
total_despesa_capital = loa_desp[MODALIDADE_COD!=91 & CATEGORIA_COD==4, sum(VL_LOA_DESP, na.rm=T)]
total_despesa_reserva = loa_desp[MODALIDADE_COD!=91 & CATEGORIA_COD==9, sum(VL_LOA_DESP, na.rm=T)]

painel_desp = rbind(painel_desp, 
                    data.table(DESPESA_DESC="TOTAL", 
                               vl_desp_total = total_despesa_capital + total_despesa_reserva,
                               ordem="50"), fill=T)
                    
painel_desp[, DESPESA_DESC:= toupper(gsub("\\d{2}\\.(.+)", "\\1", DESPESA_DESC))]
painel_desp = painel_desp[order(ordem)]

# ======= Banco LOA RECEita ==========================================================

loa_rec = loa_rec[!nat(RECEITA_COD, 7),]

loa_rec_categoria = loa_rec[, list(vl_rec_total = sum(VL_LOA_REC, na.rm = T)), 
                            by=list(RECEITA_COD1 = substr(RECEITA_COD,1,1))]

loa_rec_origem = loa_rec[!nat(RECEITA_COD, 9), list(vl_rec = sum(VL_LOA_REC, na.rm = T)), 
                         by=list(RECEITA_COD1 = substr(RECEITA_COD,1,2))]

painel_rec = rbind(loa_rec_categoria, loa_rec_origem, fill=T)

painel_rec[, RECEITA_COD:=ifelse(nchar(RECEITA_COD1)==1, 
                                 as.numeric(paste0(RECEITA_COD1, paste0(rep(0,12), collapse=""))),
                                 as.numeric(paste0(RECEITA_COD1, paste0(rep(0,11), collapse=""))))]

painel_rec = painel_rec[order(RECEITA_COD)]

painel_rec[nat(RECEITA_COD,1), ordem:=0]
painel_rec[nat(RECEITA_COD,2), ordem:=4]
painel_rec[nat(RECEITA_COD,9), ordem:=1]

painel_rec[, ordem2:= sequence(.N), by=list(ordem)]
painel_rec[, ordem:=paste0(ordem, ordem2)]
painel_rec[, c("ordem2", "RECEITA_COD1"):=NULL]

painel_rec = mergeDT(painel_rec, class_receita, by="RECEITA_COD", all.x=T)

nome_deducao = "DEDUÇÃO DA RECEITA CORRENTE"
painel_rec[nat(RECEITA_COD, 9), c("RECEITA_DESC", "ordem"):=list(nome_deducao, "10")]

painel_rec = rbind(painel_rec,
                   data.table(RECEITA_DESC ="TOTAL",
                              vl_rec_total = loa_rec[nat(RECEITA_COD, 1, 9), sum(VL_LOA_REC, na.rm=T)],
                              ordem="20"), fill=T)

painel_rec = rbind(painel_rec,
                   data.table(RECEITA_DESC ="Resultado do Orçamento Corrente", 
                              vl_rec_total = deficit_corrente,
                              ordem="30"), fill=T)

painel_rec = rbind(painel_rec,
                   data.table(RECEITA_DESC ="TOTAL", 
                              vl_rec_total = loa_rec[nat(RECEITA_COD, 2), sum(VL_LOA_REC, na.rm=T)] + deficit_corrente,
                              ordem="50"), fill=T)

painel_rec = painel_rec[, list(ordem, RECEITA_DESC, vl_rec, vl_rec_total)]

# Gera demonstrativo final

demonstrativo = mergeDT(painel_rec, painel_desp, by="ordem", all=T)

demonstrativo[, merge := NULL]
demonstrativo[, RECEITA_DESC:=correcaoCaracteresEspeciais(RECEITA_DESC, caracteres)]
demonstrativo[, DESPESA_DESC:=correcaoCaracteresEspeciais(DESPESA_DESC, caracteres)]

demonstrativo = demonstrativo[, lapply(.SD, formatarNum)]
demonstrativo[is.na(demonstrativo)] = ""

write.table(demonstrativo, "volume1/data/T3_DCGF_Demonstrativo_Receita_Despesa_Segundo_Categorias_Economicas.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)

# Quadro Resumo


loa_cat = rbind(loa_cat, data.table(DESPESA_DESC="99.TOTAL", vl_desp_total = loa_cat[, sum(vl_desp_total)]))
loa_cat[, ordem:=seq(1:.N)]
loa_cat[, DESPESA_DESC:=toupper(gsub("\\d{2}\\.(.+)", "\\1", DESPESA_DESC))]

resumo_rec = data.table(RECEITA_DESC=c("RECEITAS CORRENTES", "RECEITAS DE CAPITAL", "TOTAL"),
                        vl_rec_total = c(loa_rec[nat(RECEITA_COD, 1, 9), sum(VL_LOA_REC, na.rm=T)],
                                         loa_rec[nat(RECEITA_COD, 2), sum(VL_LOA_REC, na.rm=T)],
                                         loa_rec[, sum(VL_LOA_REC, na.rm=T)]),
                        ordem=c(1,2,4))

deficit = resumo_rec[RECEITA_DESC=="TOTAL", vl_rec_total] - loa_cat[DESPESA_DESC=="TOTAL", vl_desp_total]

resumo_rec = rbind(resumo_rec, data.table(RECEITA_DESC="DÉFICIT",
                                          vl_rec_total = deficit, 
                                          ordem=5))

resumo = mergeDT(resumo_rec, loa_cat, by="ordem", all=T)
resumo[, merge:=NULL]

resumo[, DESPESA_DESC := correcaoCaracteresEspeciais(DESPESA_DESC, caracteres)]
resumo[, RECEITA_DESC := correcaoCaracteresEspeciais(RECEITA_DESC, caracteres)]
resumo = resumo[, lapply(.SD, formatarNum)]

resumo[is.na(resumo)] = ""

write.table(resumo, "volume1/data/T3_DCGF_Resumo_Demonst_Receita_Despesa_Segundo_Categorias.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)

