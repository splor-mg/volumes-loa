# Organização do banco DETALHAMENTO DOS INVESTIMENTOS por UO - Volume 3
options(warn = 1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Investimento.R", encoding = "UTF-8")

qdd = trataQDD_Investimento("bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx")

#### Criação do banco de apoio ordem, para auxiliar na ordenação dos valores em CAtegoria e Natureza, Primeiro e Segundo
# nível respectivamente.
# Especificações: Ordenar as categorias segundo seu código e cada NAtureza dentro da categoria em ordem alfabética
# Necessário: Que o campo categoria tenha o formato exemplo <4510 - PARTICIPAÇÃO SOCIETÁRIA> Sem isso o código quebra!

if(FALSE %in% qdd[, grepl("(\\d+) *- *(.+)", CATEGORIA)]){
  stop(paste0("V3_T4_DETALHAMENTO_DOS_INVESTIMENTOS: Variável CATEGORIA não segue um padrão \\d{4} - DESCRIÇÃO ",
              "(Ex.: 4510 - PARTICIPAÇÃO SOCIETÁRIA)\nCasos: ", 
              paste0(qdd[!grepl("(\\d+) *- *(.+)", CATEGORIA), CATEGORIA], collapse = ",\n ")))
}

ordem = qdd[,.N, by=list(CATEGORIA, NATUREZA)]
ordem = ordem[, list(r=rank(NATUREZA), NATUREZA), by=list(CATEGORIA)]

ordem[, cod1 := as.numeric(gsub("(\\d+) *- *(.+)", "\\1", CATEGORIA))]
ordem[, cod2 := cod1 + r] # Codigo que acompanhará as naturezas

#ordem[, label1 := gsub("(\\d+) *- *(.+)", "\\2", CATEGORIA)]
ordem[, especificacao := gsub("(\\d+) *- *(.+)", "\\2", CATEGORIA)]

ordem_temp = copy(ordem)

ordem = rbindlist(list(
                      ordem_temp[, list(nivel=1), by=list(especificacao, id=cod1)],
                      ordem_temp[, list(nivel=2), by=list(especificacao=NATUREZA, id=cod2)],
                      data.table(especificacao="TOTAL", id=9999, nivel=1)), use.names=T)

# ordem1 = data.table(unique(cbind(ordem$label1, ordem$cod1, 1)))
# ordem1 = rbind(ordem1, data.table(unique(cbind(ordem$NATUREZA, ordem$cod2, 2))))
# ordem1 = rbind(ordem1, data.table(cbind("TOTAL", 9999, 1)))

# names(ordem1) = c("especificacao", "id", "nivel")
# ordem = data.table(ordem1)
# ordem$especificacao = as.character(ordem$especificacao)
# ordem$id = as.numeric(as.character(ordem$id))
# ordem$nivel = as.numeric(as.character(ordem$nivel))

ordem = ordem[order(id)]


for(codigo_uo in qdd[, unique(COD_UO)]){
  
  uo = qdd[COD_UO==codigo_uo,]

  uo_nat = uo[, list(valor=sum(valor, na.rm=T)), by=list(NATUREZA)]
  setnames(uo_nat, "NATUREZA", "especificacao")

  uo_cat = uo[,list(total=sum(valor, na.rm=T)), by=list(CATEGORIA)]
  setnames(uo_cat, "CATEGORIA", "especificacao")
  uo_cat[, especificacao := gsub("(\\d+) *- *(.+)", "\\2", especificacao)]

  total = uo_cat[,list(total = sum(total))]
  total[, especificacao := "TOTAL"]

  uo_cat = rbind(uo_cat, total)

  uo_total = rbind(uo_cat, uo_nat, fill=T)

  uo_total = mergeDT(uo_total, ordem, by.x="especificacao", by.y="especificacao", all=T)
  # Apenas no Banco Y - Aceitável dado que as UO podem não ter valor para determinada NATUREZA ou CATEGORIA

  if("Apenas no Banco X" %in% uo_total[, unique(merge)]){
  
    warning(paste0("V3_T4_DETALHAMENTO_DOS_INVESTIMENTOS: Especificação ",
                   uo_total[merge=="Apenas no Banco X", paste(unique(especificacao), collapse=", ")],
                    " no banco de uo_total não encontrada no banco de ordem. Verificar a origem do ERRO na UO "))
  }

  uo_total = uo_total[merge!="Apenas no Banco Y",]
  
  uo_total = uo_total[!(especificacao=="OUTRAS APLICAÇÕES" & !is.na(total) & nivel==2), ]
  uo_total = uo_total[!(especificacao=="OUTRAS APLICAÇÕES" & !is.na(valor) & nivel==1), ]
  
  uo_total[, merge:=NULL]
  uo_total = uo_total[order(id)]

  uo_total[1, orgao := paste0(substr(uo$COD_ORGAO[1],1,1), ".", substr(uo$COD_ORGAO[1],2,3), ".", 
                              substr(uo$COD_ORGAO[1],4,4), " - ",  toupper(uo$ORGAO[1]))]
  
  uo_total[1, uo := paste0(substr(uo$COD_UO[1],1,1), ".", substr(uo$COD_UO[1],2,3), ".", 
                           substr(uo$COD_UO[1],4,4), " - ",  toupper(uo$UO[1]))]
  
  uo_total[2:nrow(uo_total), c("uo", "orgao"):=NA]
  uo_total$id=NULL

  uo_total[, especificacao := correcaoCaracteresEspeciais(especificacao, caracteres)]
  uo_total[, orgao := correcaoCaracteresEspeciais(orgao, caracteres)]
  uo_total[, uo := correcaoCaracteresEspeciais(uo, caracteres)]

  uo_total = uo_total[,lapply(.SD, formatarNum)]

   write.table(uo_total, paste0("volume3/data/tabela4/", codigo_uo,".txt"), quote = FALSE, 
               sep = "\t", na = "", dec = ",", row.names = FALSE)

}
