# Organização do banco DETALHAMENTO DA CATEGORIA DE PESSOAL CASO FUNFIP - Volume 2
options(warn=1)
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataPessoal.R", encoding = "UTF-8")

# ============================================================================
# Definir parâmetros
codigo_desconsiderar = c(7008, 7023, 7016)
cod_funfip = 4711
desconsiderar_uo = c(9207, 1111, 1461, 2391, 2401, 2451)
codigo_inativos = c(7007, 7006)
uo_militar_com_civis_inativos = c(1251, 1401) #criado para tratar a excessão dos das UO em códigos_inativos que tem inativos civis (PMMG e CBMMG)
# ============================================================================

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
pessoal = trataPessoal("bancos/SISOR/BASE_CATEGORIA_PESSOAL.xlsx", realizarTeste = F)
codigo_poderes = data.table(read_excel("bancos/manual/codigosPoder.xlsx", sheet=1))

uo_inativos_folha = unique(qdd[ACAO %in% codigo_inativos, COD_UO])

#retira PMMG e e CBMMG da relação de uo
uo_inativos_folha <- uo_inativos_folha[!uo_inativos_folha %in% uo_militar_com_civis_inativos]

#criar regra para retirar as UO 1251 e 1401 de uo_inativos_folha


lista_uo = qdd[, list(x=1),
               by=list(COD_UO, nome_uo = paste0(substr(COD_UO,1,1), ".", substr(COD_UO,2,3), ".",
                                                substr(COD_UO,4,4), " - ", toupper(UO)), PODER)]

lista_uo = mergeDT(lista_uo, codigo_poderes, by.x="PODER", by.y="cod_poder", all=T)


if("Apenas no Banco Y" %in% lista_uo[, unique(merge)]){
  warning(paste("V2_Tabela3_FUNFIP_DETALHAMENTO_DE_PESSOAL_INATIVO_CIVIL: Não há UO's para o poder ",
                    lista_uo[merge=="Apenas no Banco Y", unique(poder)]))
}
lista_uo = lista_uo[, c("x", "merge") := NULL]


nomes_antigos = read_excel("bancos/manual/Nome_UO_antigas.xlsx", sheet=1)

qdd = qdd[COD_UO==cod_funfip & GRUPO_DESPESA==1 & IPU!=9, ]

cod_orgao = qdd[1, COD_ORGAO]
nome_orgao = qdd[1, ORGAO]
funfip_uo = qdd[1, UO]

qdd = qdd[!(ACAO %in% codigo_desconsiderar), ]
qdd = qdd[,list(valor=sum(valor, na.rm=T)), by=list(ACAO, NOME_ACAO)]

#write.csv2(qdd, paste(dir_banco, "funfip.csv", sep="/" ), row.names=F)

acoes_funfip = read_excel("bancos/manual/FFP_acoes.xlsx", sheet=1)

qdd = mergeDT(qdd, acoes_funfip, by.x="ACAO", by.y="ACAO", all=T)

if("Apenas no Banco X" %in% qdd[, unique(merge)]){

  warning(paste("V2_Tabela3_FUNFIP_DETALHAMENTO_DE_PESSOAL_INATIVO_CIVIL: Há códigos no banco BASE_QDD_FISCAL",
                "(com filtro para UO FUNFIP, GRUPO de despesa =1 e IPU diferente de 9)",
                "que não econtraram correspondência na planilha FUNFIP ações.xlsx.",
                "É o caso da ação código", paste(qdd[merge=="Apenas no Banco X", unique(ACAO)], collapse=", "),
                ". Atualizar o banco FUNFIP_acoes.xlsx com as ações presentes em /manual/novasAcoes_FUNFIP.csv",
                "e em sequência DELETAR /manual/novasAcoes_FUNFIP.csv"))

  novas_acoes = qdd[merge=="Apenas no Banco X", list(COD_UO), list(ACAO, DESCRITIVO_ACAO = NOME_ACAO)]
  novas_acoes[, list(COD_UO, ACAO, DESCRITIVO_ACAO)]

  write.csv2(novas_acoes, "bancos/manual/novasAcoes_FUNFIP.csv", row.names = F)
}

if("Apenas no Banco Y" %in% qdd[, unique(merge)]){
  warning(paste("V2_Tabela3_FUNFIP_DETALHAMENTO_DE_PESSOAL_INATIVO_CIVIL: Há códigos",
                "no banco FUNFIP ações.xlsx que não econtraram correspondência em ",
                "BASE_QDD_FISCAL (com filtro para UO FUNFIP, GRUPO de despesa =1",
                "e IPU diferente de 9). É o caso da ação código",
                 paste(qdd[merge=="Apenas no Banco Y", unique(ACAO)], collapse=", "),
                 ". A expectativa era que esses códigos aparececem em QDD_FISCAL?\n."))
}

nomes_acao_diff = which(!(qdd[merge=="Em ambos os bancos", NOME_ACAO==DESCRITIVO_ACAO]))

if(length(nomes_acao_diff)>0){

  warning(paste("V2_Tabela3_FUNFIP_DETALHAMENTO_DE_PESSOAL_INATIVO_CIVIL: Há nomes de ações",
                "que diferem entre o banco BASE_QDD_FISCAL (com filtro para UO FUNFIP, GRUPO",
                "de despesa =1 e IPU diferente de 9) que traz o nome atual e o banco FUNFIP",
                "ações.xlsx que traz o nome esperado. Analisar os seguintes casos:\n",
                "qdd_fiscal: NOME_ACAO == ", qdd[merge=="Em ambos os bancos", NOME_ACAO][nomes_acao_diff],
                "---- FUNFIP ações.xlsx : NOME ACAO ==",
                qdd[merge=="Em ambos os bancos", DESCRITIVO_ACAO][nomes_acao_diff],"\n"))
}

# CATEGORIA PESSOAL

pessoal = pessoal[grepl("INATIVO CIVIL", pessoal$categoria, ignore.case = T) & !(cod_uo %in% uo_inativos_folha) ,]



pessoal = pessoal[!(cod_uo %in% desconsiderar_uo),
                  list(quantidade = sum(quantidade, na.rm=T)), by=list(cod_uo)]

if(file.exists("bancos/manual/PESSOAL_INATIVO_AUSENTE_SISOR.xlsx")){
  p_inativo_ausente_sisor = data.table(read_excel("bancos/manual/PESSOAL_INATIVO_AUSENTE_SISOR.xlsx", sheet=1))
  pessoal = rbind(pessoal, p_inativo_ausente_sisor)
}

pessoal$cod_uo = as.numeric(pessoal$cod_uo)
pessoal = mergeDT(pessoal, qdd, by.x="cod_uo", by.y="COD_UO", all=T)

# Caso o valor seja 1.000, considerar como sendo simplesmente a abertura de uma conta. Nesse caso a quantidade
# pode ser considerada como "-"

if("Apenas no Banco X" %in% pessoal[, unique(merge)]){
  warning(paste("V2_Tabela3_FUNFIP_DETALHAMENTO_DE_PESSOAL_INATIVO_CIVIL: As seguintes",
                "UO's não possuem valores em ações da FUNFIP:",
                paste(pessoal[merge=="Apenas no Banco X", cod_uo], collapse = " ")))
}

if(nrow(pessoal[merge=="Apenas no Banco Y" & valor>1000,])>0){
  warning(paste("V2_Tabela3_FUNFIP_DETALHAMENTO_DE_PESSOAL_INATIVO_CIVIL: As seguintes UO's não possuem um",
                "quantitativo de inativos, porém apresentam valores superiores a R$ 1.000 nas ações da FUNFIP: \n",
                paste(pessoal[merge=="Apenas no Banco Y" & valor>1000, cod_uo], collapse = " "),
                "\nCaso seja necessário inserir o quantitativo de inativos manualmente, criar em",
                "bancos/manual/PESSOAL_INATIVO_AUSENTE_SISOR.xlsx. \nBanco com apenas duas variáveis:",
                "cod_uo e quantidade"))
}

pessoal = pessoal[,list(cod_uo, quantidade, valor)]
pessoal[, quantidade := ifelse(is.na(quantidade) & valor==1000, 0 ,quantidade)] # 0 será substituído por "-"

linha_total = pessoal[,lapply(.SD, function(x){if(is.numeric(x)){sum(x, na.rm=T)}}), .SDcols=2:3]
setnames(linha_total, c("quantidade", "valor"),  c("qtdePoder", "valorPoder"))
linha_total[, poder := "TOTAL"]

pessoal = mergeDT(pessoal, lista_uo, by.x="cod_uo", by.y="COD_UO", all=T)
pessoal = pessoal[merge!="Apenas no Banco Y",]

if(4291 %in% pessoal[, unique(cod_uo)]){
  warning(paste("V2_Tabela3_FUNFIP_DETALHAMENTO_DE_PESSOAL_INATIVO_CIVIL: 4291 FUNDO ESTADUAL DE SAÚDE",
                "(UO) será considerado como 1.32.0 - SECRETARIA DE ESTADO DE SAÚDE - SES (Órgão)\n"))

  pessoal[cod_uo==4291, c("cod_uo", "nome_uo") := list(1320, NA)]
  pessoal[cod_uo==1320, poder := "PODER EXECUTIVO"]

}

pessoal = mergeDT(pessoal, nomes_antigos, by.x="cod_uo", by.y="cod_uo", all=T)
pessoal = pessoal[merge!="Apenas no Banco Y",]

pessoal[is.na(nome_uo) & !is.na(nome), nome_uo := paste0(substr(cod_uo,1,1), ".", substr(cod_uo,2,3), ".",
                                                         substr(cod_uo,4,4), " - ", toupper(nome))]

if(TRUE %in% is.na(pessoal$nome_uo)){
  warning(paste("V2_Tabela3_FUNFIP_DETALHAMENTO_DE_PESSOAL_INATIVO_CIVIL: O codigo uo",
                paste(pessoal[is.na(nome_uo), unique(cod_uo)], collapse=", "),
                "não está em BASE_QDD_FISCAL e no arquivo bancos/manual/Nome_UO_antigas.xlsx \n"))

  pessoal[is.na(nome_uo), nome_uo := paste0(cod_uo, " - ", toupper(nome))]
}

pessoal[, c("merge", "nome"):= NULL]
pessoal[, poder := ifelse(poder=="PODER EXECUTIVO" & !is.na(poder), "PODER EXECUTIVO", "OUTROS PODERES")]

pessoal[, adm := ifelse(grepl("1\\.\\d{2}\\.\\d{1}.+", nome_uo), "ADMINISTRAÇÃO DIRETA",
                        "ADMINISTRAÇÃO INDIRETA")]

pessoal[poder!="PODER EXECUTIVO", adm :=NA]

pessoal_adm = pessoal[!is.na(adm), list(poder = "PODER EXECUTIVO",
                                        quantidade = sum(quantidade, na.rm=T),
                                        valor = sum(valor, na.rm=T)), by=list(nome_uo=adm)]

pessoal_adm[, cod_uo := ifelse(grepl("(.+) DIRETA", nome_uo), 1000, 2000)]

pessoal_poder = pessoal[,list(qtdePoder = sum(quantidade, na.rm=T), valorPoder = sum(valor, na.rm=T)),
                         by=list(poder)]

pessoal = mergeDT(pessoal, pessoal_poder, by.x="poder", by.y="poder", all=T)
pessoal = rbind(pessoal, pessoal_adm, fill=T)

pessoal = pessoal[order(-poder, cod_uo)]

pessoal[,c("merge", "PODER", "adm"):=NULL]

pessoal$qtdePoder[1] = pessoal$qtdePoder[2]
pessoal$valorPoder[1] = pessoal$valorPoder[2]

linhas_na = union(which(pessoal[, poder=="PODER EXECUTIVO"])[-1],
                  (max(which(pessoal[, poder=="PODER EXECUTIVO"]))+2):length(pessoal$poder))

pessoal[linhas_na, c("poder", "qtdePoder", "valorPoder"):=NA]

pessoal[, c("uo_funfip", "nome_orgao") := NA_character_]
pessoal$uo_funfip[1] = paste0(substr(cod_funfip,1,1), ".", substr(cod_funfip,2,3), ".",
                              substr(cod_funfip,4,4), " - ", toupper(funfip_uo))

pessoal$nome_orgao[1] = paste0(substr(cod_orgao,1,1), ".", substr(cod_orgao,2,3), ".",
                               substr(cod_orgao,4,4), " - ",  toupper(nome_orgao))

pessoal = rbind(pessoal, linha_total, fill=T)

pessoal = pessoal[,lapply(.SD, formatarNum)]

pessoal[, nome_uo := correcaoCaracteresEspeciais(nome_uo, caracteres)]
pessoal[, nome_orgao := correcaoCaracteresEspeciais(nome_orgao, caracteres)]
pessoal[, uo_funfip := correcaoCaracteresEspeciais(uo_funfip, caracteres)]
pessoal[, poder := correcaoCaracteresEspeciais(poder, caracteres)]

pessoal[as.numeric(quantidade)==0, quantidade := "-"]

write.csv2(pessoal, paste0("volume2/data/tabela3/", cod_funfip,".csv"),  na = "", row.names = FALSE)
