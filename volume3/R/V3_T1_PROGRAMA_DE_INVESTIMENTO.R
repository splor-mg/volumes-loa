# Organização do banco PROGRAMA DE INVESTIMENTO por UO - Volume 3
#
# Apresenta os investimentos para cada UO de Função até Ação, destacando a finalidade e Produtos das ações
# Os .txt gerados alimentam volume3/Rnw/T1_relatorio_por_empresa.Rnw

options(warn = 1, scipen = 999)
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Investimento.R", encoding = "UTF-8")
source("utils/trataBancos/trataAcoesPlanejamento.R", encoding = "UTF-8")

ANO_ANALISE = as.numeric(readLines("utils/ano.txt", warn = F))

acoes = trataAcoesPlanejamento("bancos/SISOR/acoes_planejamento", ANO_ANALISE)
qdd = trataQDD_Investimento("bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx")

for(codigo_uo in qdd[, unique(COD_UO)]){
  # codigo_uo = 5401
  uo = qdd[COD_UO==codigo_uo, ]

  uo_funcao = uo[, list(valor = sum(valor, na.rm = T)),  by=list(FUNCAO)]

  uo_funcao = mergeDT(uo_funcao, acoes[, list(x=1), by=list(cod_funcao, especificacao = nome_funcao)], 
                      by.x="FUNCAO", by.y="cod_funcao", all.x=T)
  
  if("Apenas no Banco X" %in% uo_funcao[, unique(merge)]) {
    warning(paste("V3_T1_PROGRAMA_DE_INVESTIMENTO.R: Código(s) da função ", 
                  paste(uo_funcao[merge=="Apenas no Banco X", unique(FUNCAO)], collapse=", "),
                  "não encontrado na variável cod_funcao no banco de ações. Verificar o problema!\n\n"))
  }
  
  uo_funcao = rbind(uo_funcao, data.table(FUNCAO=999,
                                          valor=uo_funcao[, sum(valor)], 
                                          especificacao = "TOTAL GERAL"), fill=T)
  
  
  uo_funcao$tipo = ifelse(grepl("^TOTAL GERAL$", uo_funcao$especificacao), 2, 0)
  
  # Insere nome da UO e Órgão
  uo_funcao[1, nome_uo := paste0(substr(uo[1, COD_UO], 1, 1), ".", substr(uo[1, COD_UO],2,3), ".", 
                                 substr(uo[1, COD_UO],4,4), " - ",toupper(uo[1, UO]))]
  
  uo_funcao[2:nrow(uo_funcao), nome_uo :=NA]
  
  uo_funcao[1, nome_orgao := paste0(substr(uo[1, COD_ORGAO],1,1), ".", substr(uo[1, COD_ORGAO],2,3), ".", 
                                    substr(uo[1, COD_ORGAO],4,4), " - ", toupper(uo[1, ORGAO]))]

  uo_funcao[2:nrow(uo_funcao), nome_orgao :=NA]
  
  
  uo_subfuncao = uo[, list(valor = sum(valor, na.rm = T)),  
                    by=list(FUNCAO, SUB_FUNCAO)]

  uo_subfuncao = mergeDT(uo_subfuncao, 
                         acoes[, list(x=1), by=list(cod_funcao, cod_subfuncao, especificacao = nome_subfuncao)], 
                         by.x=c("FUNCAO", "SUB_FUNCAO"), by.y=c("cod_funcao", "cod_subfuncao"), all.x=T)
  
  if("Apenas no Banco X" %in% uo_subfuncao[, unique(merge)]) {
    warning(paste("V3_T1_PROGRAMA_DE_INVESTIMENTO.R: Código(s) da subfunção ", 
                  paste(uo_subfuncao[merge=="Apenas no Banco X", unique(SUB_FUNCAO)], collapse=", "),
                  "não encontrado na variável cod_subfuncao no banco de ações. Verificar o problema!\n\n"))
  }
  
  uo_prog = uo[, list(valor = sum(valor, na.rm = T)),  
               by=list(FUNCAO, SUB_FUNCAO, PROGRAMA)]
  
  uo_prog[, valor := NA]
  
  uo_prog = mergeDT(uo_prog, 
                    acoes[, list(x=1), by=list(cod_prog, especificacao = nome_prog)], 
                         by.x="PROGRAMA", by.y="cod_prog", all.x=T)
  
  if("Apenas no Banco X" %in% uo_prog[, unique(merge)]) {
    warning(paste("V3_T1_PROGRAMA_DE_INVESTIMENTO.R: Código(s) do programa ", 
                  paste(uo_prog[merge=="Apenas no Banco X", unique(PROGRAMA)], collapse=", "),
                  "não encontrado na variável cod_prog no banco de ações. Verificar o problema!\n\n"))
  }
  
  uo_iag = uo[, list(valor = sum(valor, na.rm = T)),  
              by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV,PROJ_ATIV, IAG, NOME_ACAO)]
  
  setnames(uo_iag, "NOME_ACAO", "especificacao")

  # Gera as linhas de Finalidade e Produto
  recorte_acoes = acoes[, list(FUNCAO = cod_funcao, SUB_FUNCAO=cod_subfuncao, PROGRAMA = cod_prog,
                               cod_acao, IAG = cod_iag, final_acao, Produto, prod_acao, unid_med_prod, 
                               valor_prod)]
  
  recorte_acoes = recorte_acoes[FUNCAO %in% uo_iag[, unique(FUNCAO)] &
                                SUB_FUNCAO %in% uo_iag[, unique(SUB_FUNCAO)] &
                                PROGRAMA %in% uo_iag[, unique(PROGRAMA)] &
                                cod_acao %in% uo_iag[, as.numeric(paste0(IDENT_PROJATIV,
                                                                         formatC(PROJ_ATIV, width = 3, flag = "0")))] &
                                IAG %in% uo_iag[, unique(IAG)], ]
  
  recorte_acoes = recorte_acoes[, c("IDENT_PROJATIV", "PROJ_ATIV") := list(as.numeric(substr(cod_acao,1,1)),
                                                                           as.numeric(substr(cod_acao, 2, 4)))]
  
  if(nrow(recorte_acoes)!=nrow(uo_iag)){
    warning(paste0("V3_T1_PROGRAMA_DE_INVESTIMENTO.R: Necessário nova abordagem para o caso em que, filtrando até IAG,",
                   "temos mais de um registro no banco de acoes. A expectativa é que exista apenas uma linha.",
                   "Vide UO", codigo_uo, "\n"))
    
  }
  
  # Linhas Finalidade
  
  uo_finalidade = copy(recorte_acoes)
  uo_finalidade[, c("IAG", "tipo") := list((IAG + 0.5), 3)]
  uo_finalidade[, c("valor", "id_meta", "unidade_meta", "meta_valor") := NA]
  uo_finalidade[, c("cod_acao", "Produto", "prod_acao", "unid_med_prod", "valor_prod") := NULL]
  setnames(uo_finalidade, "final_acao", "especificacao")
  
  # Linha Produto
  
  uo_produto = copy(recorte_acoes)
  uo_produto[, c("IAG", "tipo", "valor") := list((IAG + 0.75), 1, NA)]
  uo_produto[, cod_acao:=NULL]
  setnames(uo_produto, c("Produto", "prod_acao", "unid_med_prod", "valor_prod"),
                       c("especificacao", "id_meta", "unidade_meta", "meta_valor"))
  
  if(TRUE %in% as.vector(unlist(lapply(strsplit(uo_produto$unidade_meta, " "), nchar))>14)){
    
    warning(paste("V3_T1_PROGRAMA_DE_INVESTIMENTO.R: Codigo UO: ", codigo_uo, 
                  " possui um valor de Unidade medida do produto que uma das palavras tem mais de 14 caracteres.",
                  "Isso pode gerar uma quebra de layout. verificar como ficou o layout no final para o caso de",
                  " unidade de medida do produto ", paste(unique(uo_produto$unidade_meta), collapse=", ")), "\n\n")
  }
  

  uo_final = rbindlist(list(uo_funcao, uo_subfuncao, uo_prog, uo_iag, uo_finalidade, uo_produto), fill=T)
  uo_final[, c("x", "merge"):=NULL]
  
  uo_final[, codigo_numerico := as.numeric(paste0(formatC(na2zero(FUNCAO), width = 2, flag = "0"),
                                                  formatC(na2zero(SUB_FUNCAO), width = 3, flag = "0"), 
                                                  formatC(na2zero(PROGRAMA), width = 3, flag = "0"), 
                                                  na2zero(IDENT_PROJATIV), 
                                                  formatC(na2zero(PROJ_ATIV), width = 3, flag = "0")))]
                                                                                                                            
                                                                                                                            
  uo_final = uo_final[order(codigo_numerico, IAG)]
  
  setcolorder(uo_final, c("FUNCAO",  "SUB_FUNCAO",  "PROGRAMA", "IDENT_PROJATIV", "PROJ_ATIV", "IAG", "tipo", 
                       "especificacao", "valor", "id_meta", "unidade_meta","meta_valor", "final_acao", 
                       "codigo_numerico", "nome_uo", "nome_orgao"))
  
  cols = 1:6

  uo_final = uo_final[which(IAG==0.5 | IAG==0.75 | IAG==1.5 | IAG==1.75), (cols) :=NA]

  uo_final$IAG = as.integer(uo_final$IAG)
  uo_final[is.na(tipo),  tipo:= 0]
  uo_final[, codigo_numerico := NULL]

  uo_final = uo_final[,lapply(.SD, formatarNum)]

  uo_final[, especificacao := correcaoCaracteresEspeciais(especificacao, caracteres)]
  uo_final[, unidade_meta := correcaoCaracteresEspeciais(unidade_meta, caracteres)]
  uo_final[, nome_uo := correcaoCaracteresEspeciais(nome_uo, caracteres)]
  uo_final[, nome_orgao := correcaoCaracteresEspeciais(nome_orgao, caracteres)]
  
  setnames(uo_final, c("FUNCAO", "SUB_FUNCAO", "PROGRAMA", "IDENT_PROJATIV", "PROJ_ATIV", "IAG"),
                     c("fun", "subf", "prog", "id", "proja", "iag"))

  write.table(uo_final, paste0("volume3/data/tabela1/", codigo_uo,".txt"), quote = FALSE, sep = "\t",
              na = "", dec = ",", row.names = FALSE)
}
