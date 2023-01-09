# Organização do banco QUADRO DE DETALHAMENTO DE INVESTIMENTO por UO - Volume 3 
options(warn = 1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Investimento.R", encoding = "UTF-8")

qdd = trataQDD_Investimento("bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx")

for(codigo_uo in qdd[, unique(COD_UO)]){
  
  uo = qdd[COD_UO==codigo_uo,]

  uo_acao = uo[, list(total = sum(valor, na.rm=T)), 
               by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, PROJ_ATIV, IAG, DESC_PROJETO_ATIV)]


  total = uo_acao[,list(FUNCAO=(max(FUNCAO)+1), 
                        SUB_FUNCAO=max(SUB_FUNCAO), 
                        PROGRAMA=max(PROGRAMA),
                        IDENT_PROJATIV=max(IDENT_PROJATIV), 
                        PROJ_ATIV=max(PROJ_ATIV), 
                        IAG=max(IAG),
                        total=sum(total), 
                        DESC_PROJETO_ATIV="TOTAL")]

  uo_acao = rbind(uo_acao, total)

  uo_acao[, cod_numerico := paste0(formatC(na2zero(FUNCAO), width = 2, flag = "0"), 
                                   formatC(na2zero(SUB_FUNCAO), width = 3, flag = "0"), 
                                   formatC(na2zero(PROGRAMA), width = 3, flag = "0"), 
                                   na2zero(IDENT_PROJATIV), 
                                   formatC(na2zero(PROJ_ATIV), width = 3, flag = "0"), "00")]



  uo_nat = uo[, list(total = sum(valor, na.rm=T)), 
              by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, PROJ_ATIV, IAG, NATUREZA)]

  uo_nat = uo_nat[, r:=rank(NATUREZA), by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, PROJ_ATIV, IAG)]

  uo_nat[, cod_numerico := paste0(formatC(na2zero(FUNCAO), width = 2, flag = "0"),
                                  formatC(na2zero(SUB_FUNCAO), width = 3, flag = "0"), 
                                  formatC(na2zero(PROGRAMA), width = 3, flag = "0"), 
                                  na2zero(IDENT_PROJATIV), 
                                  formatC(na2zero(PROJ_ATIV), width = 3, flag = "0"), 
                                  r ,"0")]



  uo_fonte = uo[, list(valor = sum(valor, na.rm=T)), 
                by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, PROJ_ATIV, IAG, NATUREZA, FONTE)]

  uo_fonte = uo_fonte[, r_fonte:=rank(FONTE), 
                      by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, PROJ_ATIV, IAG, NATUREZA)]

  uo_fonte = mergeDT(uo_fonte, uo_nat[, list(FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, PROJ_ATIV, IAG, r, NATUREZA)], 
                     by=c("FUNCAO", "SUB_FUNCAO", "PROGRAMA", "IDENT_PROJATIV", "PROJ_ATIV", "IAG", "NATUREZA"), 
                     all=T)

  uo_fonte[, cod_numerico := paste0(formatC(na2zero(FUNCAO), width = 2, flag = "0"),
                                    formatC(na2zero(SUB_FUNCAO), width = 3, flag = "0"), 
                                    formatC(na2zero(PROGRAMA), width = 3, flag = "0"), 
                                    na2zero(IDENT_PROJATIV), 
                                    formatC(na2zero(PROJ_ATIV), width = 3, flag = "0"), 
                                    r, r_fonte)]

  uo_fonte = uo_fonte[,(1:7):=NA]
  uo_nat = uo_nat[, (1:6):=NA]

  uo_fonte = uo_fonte[,(10:12):=NULL]

  uo_total = rbind(uo_acao, uo_nat, fill=T)
  uo_total = rbind(uo_total, uo_fonte, fill=T)

  uo_total = uo_total[order(cod_numerico)]

  uo_total = uo_total[, list(FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, PROJ_ATIV, IAG, 
                             DESC_PROJETO_ATIV, NATUREZA, FONTE, valor, total, cod_numerico)]

  #uo_total = uo_total[DESC_PROJETO_ATIV=="TOTAL", (1:6):=NA]
  
  uo_total[1, orgao := paste0(substr(uo$COD_ORGAO[1],1,1), ".", substr(uo$COD_ORGAO[1],2,3), ".", 
                              substr(uo$COD_ORGAO[1],4,4), " - ",  toupper(uo$ORGAO[1]))]
  
  uo_total[1, uo := paste0(substr(uo$COD_UO[1],1,1), ".", substr(uo$COD_UO[1],2,3), ".", 
                           substr(uo$COD_UO[1],4,4), " - ",  toupper(uo$UO[1]))]

  uo_total[2:nrow(uo_total), c("uo", "orgao") := NA]
  
  uo_total[, cod_numerico :=NULL]

  uo_total[, DESC_PROJETO_ATIV := correcaoCaracteresEspeciais(DESC_PROJETO_ATIV, caracteres)]
  uo_total[, NATUREZA := correcaoCaracteresEspeciais(NATUREZA, caracteres)]
  uo_total[, FONTE := correcaoCaracteresEspeciais(FONTE, caracteres)]
  uo_total[, orgao := correcaoCaracteresEspeciais(orgao, caracteres)]
  uo_total[, uo := correcaoCaracteresEspeciais(uo, caracteres)]
  
  uo_total = uo_total[,lapply(.SD, formatarNum)]

  setnames(uo_total, c("FUNCAO", "SUB_FUNCAO", "PROGRAMA", "IDENT_PROJATIV", "PROJ_ATIV", 
                       "IAG", "DESC_PROJETO_ATIV",  "NATUREZA", "FONTE"), 
                     c("funcao",	"subfuncao", "prog", "id", "proj", 
                       "iag", "especificacao", "detalhamento", "fontes"))

  write.table(uo_total, paste0("volume3/data/tabela5/", codigo_uo,".txt"), quote = FALSE, sep = "\t",
              na = "", dec = ",", row.names = FALSE)

}
