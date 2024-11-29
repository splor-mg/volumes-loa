# Organização do banco ORIGENS DE RECURSOS PARA INVESTIMENTOS por UO - Volume 3
options(warn = 1)
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Investimento.R", encoding = "UTF-8")

qdd = trataQDD_Investimento("bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx")

ref_niveis = read.table("bancos/R/V3_Niveis_de_Referencia_tabela2.txt", sep = "\t", header=T)
ref_ordem = read.table("bancos/R/V3_Niveis_Ref_Ordem_tabela2.txt", sep = "\t", header=T)

qdd = mergeDT(qdd, ref_niveis, by.x="FONTE", by.y="n4_banco", all=T)

if(T %in% is.na(qdd$COD_UO)){
  stop("V3_T2_ORIGENS_RECURSOS_INVESTIMENTOS: O banco qdd possui NA em COD_UO. Verificar")
}

for(codigo_uo in qdd[, unique(COD_UO)]){

  #codigo_uo = 5251

  uo = qdd[COD_UO==codigo_uo,]

  uo_n1 = uo[n1!="",list(total = sum(valor, na.rm = T)), by=list(n1)]
  uo_n1[, nivel := 1]
  setnames(uo_n1, "n1", "especificacao")

  total = uo_n1[,list(total = sum(total))]
  total[, c("especificacao", "nivel") := list("TOTAL",1)]
  uo_n1 = rbind(uo_n1, total)

  uo_n2 = uo[n2!="", list(total = sum(valor, na.rm = T)), by= list(n2)]
  uo_n2[, nivel := 2]
  setnames(uo_n2, "n2", "especificacao")

  uo_n3 = uo[n3!="", list(valor = sum(valor, na.rm = T)), by=list(n3)]
  uo_n3[, nivel := 3]
  setnames(uo_n3, "n3", "especificacao")

  uo_n4 = uo[n4_label!="", list(valor = sum(valor, na.rm = T)), by=list(n4_label)]
  uo_n4[, nivel := 4]
  setnames(uo_n4, "n4_label", "especificacao")

  uo_final = rbindlist(list(uo_n1, uo_n2, uo_n3, uo_n4), use.names = T, fill=T)

  uo_final = mergeDT(uo_final, ref_ordem, by.x="especificacao", by.y="fonte", all=T)
  # Apenas no Banco X: No máximo 3 (Recursos Próprios (2x) e Total)

  uo_final = uo_final[merge!="Apenas no Banco Y",]

  # O valor da variável ordem para RECURSOS PRÓPRIOS e Total podem ser flexíveis, dado que esses valores
  # devem aparecer no final

  uo_final[is.na(ordem), ordem := 0]
  max_ordem = uo_final[, max(ordem, na.rm=T)]

  uo_final[, ordem := ifelse(especificacao=="RECURSOS PRÓPRIOS" & nivel==1, max_ordem + 1,
                      ifelse(especificacao=="RECURSOS PRÓPRIOS" & nivel==4, max_ordem + 2,
                      ifelse(especificacao=="TOTAL", max_ordem + 3,  ordem)))]

  uo_final = uo_final[order(ordem)]

  uo_final[1, orgao := paste0(substr(uo$COD_ORGAO[1],1,1), ".", substr(uo$COD_ORGAO[1],2,3), ".",
                              substr(uo$COD_ORGAO[1],4,4), " - ", toupper(uo$ORGAO[1]))]


  uo_final[1, uo := paste0(substr(uo$COD_UO[1],1,1), ".", substr(uo$COD_UO[1],2,3), ".",
                           substr(uo$COD_UO[1],4,4), " - ",  toupper(uo$UO[1]))]

  uo_final[2:nrow(uo_final), c("orgao", "uo"):=NA]
  uo_final[, c("ordem", "merge"):=NULL]

  uo_final[, especificacao := correcaoCaracteresEspeciais(especificacao, caracteres)]
  uo_final[, orgao := correcaoCaracteresEspeciais(orgao, caracteres)]
  uo_final[, uo := correcaoCaracteresEspeciais(uo, caracteres)]

  uo_final = uo_final[,lapply(.SD, formatarNum)]

  write.table(uo_final, paste0("volume3/data/tabela2/", codigo_uo,".txt"), quote = FALSE, sep = "\t",
              na = "", dec = ",", row.names = FALSE)

}
