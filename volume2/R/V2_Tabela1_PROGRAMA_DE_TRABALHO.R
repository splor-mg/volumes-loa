### Organização do banco PROGRAMA DE TRABALHO - Volume 2
options(warn=1)
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataAcoesPlanejamento.R", encoding = "UTF-8")

ANO_ANALISE = as.numeric(readLines("utils/ano.txt", warn = F))

acoes = trataAcoesPlanejamento("bancos/SISOR/acoes_planejamento", ANO_ANALISE)
qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", TRUE)

grupo_despesa = data.table(read_excel("bancos/manual/desc_grupos_de_despesa.xlsx", sheet=1))
grupo_despesa = grupo_despesa[, list(CODIGO, ESPECIFICACAO)]

for(codigo_uo in qdd[, unique(COD_UO)]){

  uo = qdd[COD_UO==codigo_uo, ]

  # Parte 1: Montar as linhas referentes a função
  
  uo_funcao = uo[,list(total = sum(valor, na.rm = T)),  by=list(FUNCAO)]

  ## Aba Função no banco de apoio para identificar a label de Função

  for(i in 1:nrow(uo_funcao)){
    COD_FUNCAO1 = uo_funcao[i, FUNCAO]
    NOME_FUNCAO1 = acoes[cod_funcao==COD_FUNCAO1, nome_funcao][1]
    
    if(is.na(NOME_FUNCAO1)){
      warning(paste("V2_Tabela1_PROGRAMA_DE_TRABALHO: Código da função ", COD_FUNCAO1, 
                    " não encontrado na variável CÓDIGO no banco de apoio",
                    ".Verificar o problema. Possivelmente será necessário incluir uma nova linha.\n"))   
    } else{
      uo_funcao[i, descricao := NOME_FUNCAO1]
    }
  }

  uo_funcao[, tipo := 1]
  uo_funcao[, c("nome_uo", "nome_orgao"):=NA]
  
  uo_funcao$nome_uo[1] = paste0(substr(uo$COD_UO[1],1,1), ".",   substr(uo$COD_UO[1],2,3), ".", 
                                substr(uo$COD_UO[1],4,4), " - ", toupper(uo$UO[1]))

  uo_funcao$nome_orgao[1] = paste0(substr(uo$COD_ORGAO[1],1,1), ".", substr(uo$COD_ORGAO[1],2,3), ".", 
                                   substr(uo$COD_ORGAO[1],4,4), " - ",  toupper(uo$ORGAO[1]))

  # Parte 2: Montar as linhas referentes a subfunção2

  uo_subfuncao = uo[,list(total = sum(valor, na.rm = T)),  by=list(FUNCAO, SUB_FUNCAO)]

  for(i in 1:nrow(uo_subfuncao)){
    COD_SUBFUNCAO1 = uo_subfuncao[i, SUB_FUNCAO]
    NOME_SUBFUNCAO1 = acoes[cod_subfuncao==COD_SUBFUNCAO1, nome_subfuncao][1]
    
    if(is.na(NOME_SUBFUNCAO1)){
      warning(paste("V2_Tabela1_PROGRAMA_DE_TRABALHO: Código da subfunção ", COD_SUBFUNCAO1, 
                    " não encontrado na variável CÓDIGO no banco de apoio", 
                  ".Verificar o problema. Possivelmente será necessário incluir uma nova linha.\n"))
    } else{
      uo_subfuncao[i, descricao:= NOME_SUBFUNCAO1]
    }
  }

  uo_subfuncao[, tipo := 1]

  # Parte 3: Montar as linhas referentes a programa

  uo_prog = uo[, list(total = sum(valor, na.rm = T)),  by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, NOME_PROGRAMA)]

  setnames(uo_prog, "NOME_PROGRAMA", "descricao")
  uo_prog[, tipo := 1]

  # Parte 4: Montar as linhas referentes a ação
  
  uo_acao = uo[, list(total = sum(valor, na.rm = T)), 
               by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, PROJ_ATIV, NOME_ACAO)]

  setnames(uo_acao, "NOME_ACAO", "descricao")
  uo_acao[, tipo := 1]

  # Parte 5: Montar as linhas referentes a Finalidade

  uo_finalidade = uo_acao
  uo_finalidade[, descricao := NA_character_]

  for(i in 1:nrow(uo_finalidade)){
    lista = as.list(uo_finalidade[i, ])
    
    finalidade = acoes[cod_uo==codigo_uo &
                       cod_funcao==lista[["FUNCAO"]] &  
                       cod_subfuncao==lista[["SUB_FUNCAO"]] &  
                       cod_prog==lista[["PROGRAMA"]] &  
                       cod_acao==(as.numeric(paste0(lista[["IDENT_PROJATIV"]], 
                                            formatC(lista[["PROJ_ATIV"]], width = 3, flag = "0")))), final_acao]
  
  if(length(finalidade)!=1){
    
    warning(paste0("V2_Tabela1_PROGRAMA_DE_TRABALHO: Para a UO ", codigo_uo, " função ", 
                   lista[["FUNCAO"]], " subfunção ", lista[["SUB_FUNCAO"]],
                   " programa ", lista[["PROGRAMA"]], " ação ", lista[["IDENT_PROJATIV"]],
                   formatC(lista[["PROJ_ATIV"]], width = 3, flag = "0"), 
                   " há mais de uma Finalidade da Ação (Coluna Z), OU, não há nenhuma finalidade da ação.",
                  " Os valores, se existirem, são:", paste0(finalidade, collapse=", ")))
  } else{
    
    uo_finalidade[i, descricao := as.character(finalidade)]
    
    }
  }

  uo_finalidade[, tipo := 5]

  # Parte 6: Montar as linhas referentes a subprojeto

  uo_subprojeto = uo[, list(total = sum(valor, na.rm = T)),  
                     by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, 
                             PROJ_ATIV, SUB_PROJETO, NOME_ACAO)]

  setnames(uo_subprojeto, "NOME_ACAO", "descricao")
  uo_subprojeto[, tipo := 1]

  # Parte 7: Montar as linhas referentes a IPU

  uo_ipu = uo[,list(valor = sum(valor, na.rm = T)),
              by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, PROJ_ATIV, 
                      SUB_PROJETO, MODALIDADE, IAG, FONTE, IPU, GRUPO_DESPESA)]

  if(length(unique(uo_ipu$GRUPO_DESPESA))==1 & uo_ipu$GRUPO_DESPESA[1]==9){
    
    uo_ipu$GRUPO_DESPESA = NULL
    setnames(uo_ipu, "valor", "total")
  
  }else{
    
    uo_ipu = mergeDT(uo_ipu, grupo_despesa, by.x="GRUPO_DESPESA", by.y="CODIGO", all=T)

  if("Apenas no Banco X" %in% uo_ipu[, unique(merge)]){
    warning(paste("V2_Tabela1_PROGRAMA_DE_TRABALHO: Há um codigo de GRUPO DE DESPESA em BASE_QDD_FISCAL",
                  "que não possui correspondência em desc_grupos_de_despesa.xlsx. Trata-se do valor",
                  uo_ipu[merge=="Apenas no Banco X", paste0(unique(GRUPO_DESPESA), collapse=", ")],
                  ". Alterar os valores nessa aba e rodar novamente o código.\n\n"))
    }

  uo_ipu = uo_ipu[merge=="Em ambos os bancos",]

  uo_ipu[, GRUPO_DESPESA := tolower(paste0(GRUPO_DESPESA,
                                     gsub(" ", "_", iconv(ESPECIFICACAO, from="UTF-8", to="ASCII//TRANSLIT"))))]

  uo_ipu[, ESPECIFICACAO := NULL]
  uo_ipu[, merge := NULL]

  uo_ipu <- reshape(uo_ipu, timevar = "GRUPO_DESPESA", idvar = c("FUNCAO", "SUB_FUNCAO", "PROGRAMA", "IDENT_PROJATIV", 
                                                                 "PROJ_ATIV", "SUB_PROJETO", "MODALIDADE", "IAG", 
                                                                 "FONTE", "IPU"),  direction = "wide")

  col_final = ncol(uo_ipu)
  uo_ipu$total = uo_ipu[,apply(.SD, 1, function(x) sum(x, na.rm=T)), .SDcols=11:col_final]
  
  }  
  
  uo_ipu[, tipo := 7]

  # Parte 8: Montar as linhas referentes ao produto, Unidade de Medida e Meta física

  uo_produto = uo_ipu[, list(MODALIDADE = (max(MODALIDADE) +1)), 
                      by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, PROJ_ATIV,  SUB_PROJETO ,IAG)]

  # Recorte do banco acoes apenas para a UO de interesse
  recorte_acoes = acoes[cod_uo==codigo_uo , list(cod_uo, cod_funcao, cod_subfuncao, cod_prog, cod_acao, 
                                                 cod_iag, Produto, valor_prod, unid_med_prod, tipo_acao, exc_acao)]

  recorte_acoes[, id_acao := as.numeric(substr(cod_acao, 1,1))]
  recorte_acoes[, proj_ativ := as.numeric(substr(cod_acao, 2,4))]
  recorte_acoes[, cod_acao := NULL]

  uo_produto = mergeDT(uo_produto, 
                       recorte_acoes, 
                       by.x=c("FUNCAO", "SUB_FUNCAO", "PROGRAMA", "IDENT_PROJATIV", "PROJ_ATIV", "IAG"),
                       by.y = c("cod_funcao", "cod_subfuncao", "cod_prog", "id_acao", "proj_ativ", "cod_iag"), all=T)

  for(j in 1:nrow(uo_produto)){
    
    lista_uo_produto = as.list(uo_produto[j, ])
    
    if(lista_uo_produto[["merge"]]=="Apenas no Banco X"){
      
      warning(paste0("V2_Tabela1_PROGRAMA_DE_TRABALHO: Para a UO ", codigo_uo, " função ", 
                    lista_uo_produto[["FUNCAO"]], " subfunção ", lista_uo_produto[["SUB_FUNCAO"]],
                    " programa ", lista_uo_produto[["PROGRAMA"]], " ação ", lista_uo_produto[["IDENT_PROJATIV"]],
                    formatC(lista_uo_produto[["PROJ_ATIV"]], width = 3, flag = "0"), 
                    " não há um Produto da ação no banco de ações.\n\n"))
  
    } else if(lista_uo_produto[["merge"]]=="Apenas no Banco Y"){
  
  if(toupper(lista_uo_produto[["tipo_acao"]])=="NÃO ORÇAMENTÁRIO" | toupper(lista_uo_produto[["exc_acao"]])=="SIM"){
    erro = FALSE
    #complemento_erro = ". Ou seja, é uma ação que deve ser desconsiderada."
  } else{
    erro = TRUE
    complemento_erro = paste0(". Era para o BASE_QDD_FISCAL apresentar linhas com função, subfunção programa, ação e ",
                             "o descritivo, bem como linhas com apenas modalidade IAG, fonte e IPU antes dessa ação. ",
                             "Reportar o erro. ")
  }
  
    if(erro){ warning(paste0("V2_Tabela1_PROGRAMA_DE_TRABALHO: Para a UO ", codigo_uo, " função ", 
                             lista_uo_produto[["FUNCAO"]], " subfunção ", lista_uo_produto[["SUB_FUNCAO"]], 
                             " programa ", lista_uo_produto[["PROGRAMA"]], " ação ", lista_uo_produto[["IDENT_PROJATIV"]], 
                             formatC(lista_uo_produto[["PROJ_ATIV"]], width = 3, flag = "0"), 
                            " há um Produto da ação no banco de ações que não tem uma correspondência em BASE_QDD_FISCAL",
                            ". Para esse produto o tipo de ação é ", toupper(lista_uo_produto[["tipo_acao"]]) , 
                            " e a exclusão lógica da ação é ",  toupper(lista_uo_produto[["exc_acao"]]), 
                            complemento_erro, "\n\n"))}
    }
  }

  uo_produto = uo_produto[merge=="Em ambos os bancos",]
  indice_palavras_grandes = as.vector(unlist(lapply(strsplit(uo_produto$unid_med_prod, " "), nchar))>13)

  if(length(unlist(strsplit(uo_produto$unid_med_prod, " "))[indice_palavras_grandes])>0){
      
      warning(paste("V2_Tabela1_PROGRAMA_DE_TRABALHO: Codigo UO: ", codigo_uo, 
                    " possui um valor de Unidade medida do produto que",
                    " uma das palavras tem mais de 13 caracteres. Isso pode gerar uma quebra de layout. ",
                    " Verificar como ficou o layout no final para o caso de unidade de medida do produto. ",
                    "Procurar pelas palavras '", 
                    paste(unlist(strsplit(uo_produto$unid_med_prod, " "))[indice_palavras_grandes], collapse="', ")))
      }

  uo_produto[, c("cod_uo", "merge") := NULL]
  
  setnames(uo_produto, "Produto", "descricao")
  uo_produto[, tipo := 8]

  # Parte 9: Append dos bancos e ordenação
  uo_final = rbind(uo_ipu, uo_subfuncao, fill=T)
  uo_final = rbind(uo_final, uo_prog, fill=T)
  uo_final = rbind(uo_final, uo_acao, fill=T)
  uo_final = rbind(uo_final, uo_finalidade, fill=T)
  uo_final = rbind(uo_final, uo_subprojeto, fill=T)
  uo_final = rbind(uo_final, uo_funcao, fill=T)
  uo_final = rbind(uo_final, uo_produto, fill=T)

  uo_final = uo_final[order(FUNCAO,SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, PROJ_ATIV, 
                            SUB_PROJETO, MODALIDADE, IAG, FONTE, IPU, na.last = FALSE)]

  # Parte 10: Incluir novas colunas e renomea-las

  campos_a_incluir = setdiff(tolower(paste0("valor.", grupo_despesa$CODIGO,
                            gsub(" ", "_", iconv(grupo_despesa$ESPECIFICACAO, from="UTF-8", to="ASCII//TRANSLIT")))),
                            grep("valor\\.(.+)", names(uo_final), value=T))

  uo_final = uo_final[, as.vector(campos_a_incluir):=NA]

  setnames(uo_final, 
           c(grep("^valor\\.\\d+_*pessoal(.+)sociais$", names(uo_final), value=T), 
             grep("^valor\\.\\d+_*juros(.+)divida$", names(uo_final), value=T),
             grep("^valor\\.\\d+_*outras(.+)correntes$", names(uo_final), value=T),
             grep("^valor\\.\\d+_*investimentos$", names(uo_final), value=T),
             grep("^valor\\.\\d+_*inversoes(.+)financeiras$", names(uo_final), value=T),
             grep("^valor\\.\\d+_*amort(.+)divida$", names(uo_final), value=T),
             "MODALIDADE"), 
           c("PESSOAL", "JUROS", "OUTRAS", "INVESTIMENTOS", "INVERSOES", "AMORTIZA", "MOD"))
  
  uo_final[, descricao := gsub("\"", "", descricao)]
  uo_final[, descricao := gsub("¿", "", descricao)]
  
  total = uo_final[, list(PESSOAL = sum(PESSOAL, na.rm=T), 
                          JUROS= sum(JUROS, na.rm=T), 
                          OUTRAS= sum(OUTRAS, na.rm=T),
                          INVESTIMENTOS= sum(INVESTIMENTOS, na.rm=T), 
                          INVERSOES= sum(INVERSOES, na.rm=T),
                          AMORTIZA= sum(AMORTIZA, na.rm=T), 
                          total= sum(total, na.rm=T)
                          )]

  total$total = sum(uo_final[is.na(SUB_FUNCAO), total], na.rm=T)
  
  total = total[, lapply(.SD, function(x){if(x==0){NA} else{x}})]

  total[, c("FUNCAO", "descricao", "tipo") := list(999, "TOTAL", 9)]
  
  uo_final = rbind(uo_final, total, fill=T)
  uo_final = uo_final[!duplicated(uo_final), ]
  
  uo_final = uo_final[,lapply(.SD, formatarNum)]
  
  uo_final[, descricao := correcaoCaracteresEspeciais(descricao, caracteres)]
  uo_final[, unid_med_prod := correcaoCaracteresEspeciais(unid_med_prod, caracteres)]
  uo_final[, nome_uo := correcaoCaracteresEspeciais(nome_uo, caracteres)]
  uo_final[, nome_orgao := correcaoCaracteresEspeciais(nome_orgao, caracteres)]

  write.table(uo_final, paste0("volume2/data/tabela1/", codigo_uo,".txt"),quote = T, sep = "\t",
              na = "", dec = ",", row.names = FALSE)
}
