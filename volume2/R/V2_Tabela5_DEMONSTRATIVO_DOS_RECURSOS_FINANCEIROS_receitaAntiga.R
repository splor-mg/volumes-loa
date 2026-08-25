#######################################################################################
### Organização do banco TABELA 5 DEMONSTRATIVO DOS RECURSOS FINANCEIROS - Volume 2 
#######################################################################################

source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataTransferencias.R", encoding = "UTF-8")

# ============================================================================
# Definir parâmetros

desconsiderarUO = c(9901)
lista_recurso_ordinario = c(10,12)
uo_caso_especial = c(1091) # Caso em que aparece determinada fonte em RECEITA PRÓPRIA e REPASSE DO TESOURO, mas o 
                           # valor NÃO deve ser desconsiderado em REPASSE DO TESOURO ESTADUAL, mas sim somado
funfip = 4711
# ============================================================================

### Transferências entre UO's####
transf = trataTransferencias("bancos/SISOR/BASE_REPASSE_RECURSOS.xlsx")

# Subtotal1
demonstrativo1 = data.table(read.table("volume2/data/tabela4/subtotal1.txt", header = T, sep = "\t", 
                                       quote = "\"'", dec = ","))

# Banco de Receita

receita = trataReceita_Fiscal_antigo("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", TRUE)
setnames(receita, "UO_COD", "COD_UO")
receita_fonte = receita[, list(valor = sum(valor, na.rm=T)), by=list(COD_UO, COD_FONTE)]

## Sumário

sumario = data.table(read.table("volume2/data/sumario.txt", header = T, sep = "\t", 
                                quote = "\"'", dec = "@"))

UnidadesOrcamentarias = c()

## Abre QDD e gera o qdd ajustado

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", TRUE)

abrirLog("logs", "Tabela5_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS")

qdd_ajustado = trataQDD_Ajustado(qdd, transf, funfip)

for(codigo_uo in sumario[!COD_UO %in% desconsiderarUO & substr(COD_UO, 1,1)!="1", COD_UO]){
  

 registroLog(paste("<strong> Montagem do banco para a UO: ", codigo_uo, " </strong>"), "nota")

 registroLog(paste("Próxima UO na lista: ", sumario[match(codigo_uo, COD_UO)+1, COD_UO]), "nota")  
  #codigo_uo =  2301
 
    # =================================================================================================
    # INICIO PARTE 2. RECURSOS REPASSADOS PELO TESOURO ESTADUAL
    # =================================================================================================
  
  parte2 = data.table(especificacao = "2. RECURSOS REPASSADOS PELO TESOURO ESTADUAL") 

  subtotal1 = receita_fonte[COD_UO==codigo_uo, list(valor_rec = sum(valor, na.rm=T)), by=list(COD_FONTE)]
  valor_qdd_ajust = qdd_ajustado[COD_UO==codigo_uo, list(valor_qdd = sum(valor, na.rm=T)), by=list(FONTE)]
  
  if(nrow(subtotal1)>0){
    
    # =================================================================================================
    # As fontes que aparecem no banco de receita são as mesmas que aparecem no banco de qdd ajustado?
    # Teste realizado em R/V2_Tabela5_SUPORTE_CorrecaoFontesSimultaneas.R
    # =================================================================================================
    
    source("volume2/R/lib/V2_Tabela5_SUPORTE_CorrecaoFontesSimultaneas.R", encoding = "UTF-8")
    
  } else{
    
    # =================================================================================================
    # No caso que não existe valores de receita para a UO (Tabela 4), não precisamos realizar nenhuma
    # dedução em qdd ajustado, ou seja, podemos utilizar apenas o qdd ajustado
    # =================================================================================================
    
    
    repasse_tesouro = qdd_ajustado[COD_UO==codigo_uo, list(COD_UO, CATEGORIA, FONTE, valor_qdd = valor)]
  }
  
  
  if(nrow(repasse_tesouro)>0){
    
    # =====================================================================================================
    # repasse_tesouro é o banco necessário para criar o REPASSE DO TESOURO ESTADUAL
    # na situação que os valores qdd por fonte sejam menores ou iguais ao valores de receita por fonte
    # NÃO é necessário criar esse demonstrativo. O script R/V2_Tabela5_SUPORTE_CorrecaoFontesSimultaneas.R
    # zera o número de linhas de repasse_tesouro nesse caso.
    # ====================================================================================================
  

    repasse_tesouro[, categoria := ifelse(CATEGORIA==3, "DESPESAS CORRENTES", "DESPESAS DE CAPITAL")]

    repasse_tesouro[FONTE %in% lista_recurso_ordinario, tipo:="ordinario"]
    repasse_tesouro[!(FONTE %in% lista_recurso_ordinario), tipo:="vinculado"]

    repasse_tesouro = repasse_tesouro[, list(valor = sum(valor_qdd, na.rm=T)), by=list(especificacao = categoria, tipo)]

    repasse_tesouro = dcast(repasse_tesouro, especificacao ~ tipo, value.var = "valor")

    if(length(setdiff(c("ordinario", "vinculado"), names(repasse_tesouro)))>0){
      
      repasse_tesouro[,setdiff(c("ordinario", "vinculado"), names(repasse_tesouro)):=0]
      
    }

    repasse_tesouro[is.na(vinculado), vinculado := 0]
    repasse_tesouro[is.na(ordinario), ordinario := 0]

    repasse_tesouro[, total := vinculado + ordinario]

    if(codigo_uo %in% uo_caso_especial){
      
      # =====================================================================================================
      # Estar no conjunto "uo_caso_especial" significa que não é possível discriminar o recurso ordinário
      # e/ou vinculado entre Despesa Corrente ou Despesa de Capital. Isso acontece em duas situações:
      # 1. O valor em fonte 10 é maior no qdd em relação a receita e essa receita não faz referência a FES
      # ex. 1091
      #
      # 2. O valor em fonte 10 é maior no qdd em relação a receita, essa receita faz referência ao FES,
      # MAS, quando deduzimos o valor da função 10, há valores para essa função em despesa corrente e 
      # despesa com capital. Assim, não sabemos de onde tirar esse recurso (ex. 2261)
      # ====================================================================================================
      
      
      repasse_tesouro = repasse_tesouro[, list(especificacao="SUBTOTAL 2", 
                                               ordinario=sum(ordinario, na.rm=T),
                                               vinculado=sum(vinculado, na.rm=T), 
                                               total=sum(total, na.rm=T))]
      
    } else{
      
      repasse_tesouro = rbind(repasse_tesouro, 
                              repasse_tesouro[, list(especificacao="SUBTOTAL 2", 
                                                     ordinario=sum(ordinario, na.rm=T),
                                                     vinculado=sum(vinculado, na.rm=T), 
                                                     total=sum(total, na.rm=T))]
                              )
    }

    parte2 = rbind(parte2, repasse_tesouro, fill=T)

    registroLog(paste("PARTE 2: Montagem de 2.RECURSOS REPASSADOS PELO TESOURO ESTADUAL concluído para a UO ",
                            codigo_uo), "nota")

} else{
  

  registroLog(paste("Valor de Subtotal1 é MAIOR ou igual ao valor do qdd ajustado para cada Fonte, ou seja, não há ",
                    "o demonstrativo 2 Repasse do Tesouro Estadual para essa UO"), "aviso")

  parte2 = rbind(parte2, data.table(especificacao="SUBTOTAL 2", ordinario = NA, vinculado=NA, total=NA), fill=T)
  
  }

  setcolorder(parte2, c("especificacao", "ordinario", "vinculado", "total"))

  
  # =================================================================================================
  # INICIO PARTE 3. RECURSOS RECEBIDOS DE ÓRGÃOS E ENTIDADES DO ORÇAMENTO FISCAL
  # =================================================================================================
  

  recursos_recebidos = data.table(especificacao = "3. RECURSOS RECEBIDOS DE ÓRGÃOS E ENTIDADES DO ORÇAMENTO FISCAL",
                                  total = NA)

  transf_recebida = transf[cod_uo_benef == codigo_uo, ]

  if(nrow(transf_recebida)>0){
    
    # ====================================================================================================
    # O banco "transf_recebida" ter mais de zero linhas implica que a UO recebeu recursos de outras UO's.
    # uo_financ é a UO que repassou o recurso
    # ====================================================================================================
    

    recursos_recebidos_uo = transf_recebida[, list(total = sum(valor, na.rm=T)), by=list(cod_uo_financ, uo_financ)]
    
    recursos_recebidos_uo[, especificacao := paste0(cod_uo_financ, " - ", uo_financ)]
    
    recursos_recebidos_uo = recursos_recebidos_uo[order(especificacao)]

    recursos_recebidos_total = recursos_recebidos_uo[, list(especificacao = "SUBTOTAL 3", 
                                                            total = sum(total, na.rm=T))]

    recursos_recebidos = rbind(recursos_recebidos, recursos_recebidos_uo[, list(especificacao, total)])
    
    recursos_recebidos = rbind(recursos_recebidos, recursos_recebidos_total)
    
    registroLog(paste("PARTE 3: Montagem de 3.RECURSOS RECEBIDOS DE ÓRGÃOS E ENTIDADES DO ORÇAMENTO FISCAL ",
                      "concluído para a UO ", codigo_uo), "nota")

  } else{
    
    recursos_recebidos = rbind(recursos_recebidos, data.table(especificacao = "SUBTOTAL 3", total = NA))
    registroLog(paste("PARTE 3: A UO ", codigo_uo, " não recebeu recursos de outras UO's."), "aviso")
    
  }
  
  # =================================================================================================
  # INICIO PARTE 4. RECURSOS REPASSADOS A ÓRGÃOS E ENTIDADES DO ORÇAMENTO FISCAL
  # =================================================================================================

    recursos_transferidos = data.table(especificacao = "4. RECURSOS REPASSADOS A ÓRGÃOS E ENTIDADES DO ORÇAMENTO FISCAL",
                                  total = NA)


    transf_transferido = transf[cod_uo_financ == codigo_uo, ]

  if(nrow(transf_transferido)>0){
    
    # =========================================================================================================
    # O banco "transf_transferido" ter mais de zero linhas implica que a UO transferiu recursos de outras UO's.
    # uo_benef é a UO que recebeu o recurso
    # =========================================================================================================

    recursos_transferidos_uo = transf_transferido[,list(total = sum(valor, na.rm=T)), by=list(cod_uo_benef, uo_benef)]
    
    recursos_transferidos_uo[, especificacao := paste0(cod_uo_benef, " - ", uo_benef)]
    
    recursos_transferidos_uo = recursos_transferidos_uo[order(especificacao)]

    recursos_transferidos_total = recursos_transferidos_uo[, list(especificacao = "SUBTOTAL 4", 
                                                                  total = sum(total, na.rm=T))]

    recursos_transferidos = rbind(recursos_transferidos, recursos_transferidos_uo[, list(especificacao, total)])
    
    recursos_transferidos = rbind(recursos_transferidos, recursos_transferidos_total)

    registroLog(paste("PARTE 4: Montagem de 4.RECURSOS REPASSADOS A ÓRGÃOS E ENTIDADES DO ORÇAMENTO FISCAL",
                      " concluído para a UO ", codigo_uo), "nota")

  } else{
    
    recursos_transferidos = rbind(recursos_transferidos, data.table(especificacao = "SUBTOTAL 4", total = NA))
    registroLog(paste("PARTE 4: A UO ", codigo_uo, " não transferiu recursos para outras UO's."), "aviso")
    
  }

  # =================================================================================================
  # INICIO PARTE 4.RECEITA TOTAL
  # =================================================================================================

  receita_total = data.table(especificacao="5. Receita Total (1 + 2 + 3)",
                             total = sum(c(demonstrativo1[COD_UO == codigo_uo, subtotal1],
                                           parte2[especificacao=="SUBTOTAL 2", total],
                                           recursos_recebidos[especificacao=="SUBTOTAL 3", total]), na.rm=T))

  if(class(receita_total$total+1)!="numeric"){
    
    registroLog(paste("PARTE 5: RECEITA TOTAL valor calculado ", receita_total[1, total], "errado."), "erro")
    
  } else{
    registroLog(paste("PARTE 5: Montagem de 5.RECEITA TOTAL concluído para a UO ", codigo_uo), "nota") 
    }
  
  # =================================================================================================
  # INICIO PARTE 5.RECEITA DISPONÍVEL
  # =================================================================================================
    
  valor_total = sum(c(receita_total[1, total], -recursos_transferidos[nrow(recursos_transferidos), total]), na.rm=T)
    
  receita_disponivel = data.table(especificacao="6. Receita Disponível (5 - 4)",
                                  total = valor_total)

  
    if(receita_disponivel[1, total]<=0){
      
      registroLog(paste("PARTE 6: RECEITA DISPONÍVEL valor calculado NEGATIVO ou ZERO:",
                        formatarNum(receita_disponivel[1, total]),". Verificar o problema"), "erro")
    }
    
    
    if(receita_disponivel[1, total]!= qdd[COD_UO==codigo_uo, sum(valor, na.rm=T)]){
    
    registroLog(paste("PARTE 6: RECEITA DISPONÍVEL apresenta um valor", 
                      formatarNum(receita_disponivel[1, total]), "diferente do total apresentado em BASE_QDD_FISCAL (",
                      formatarNum(qdd[COD_UO==codigo_uo, sum(valor, na.rm=T)]),
                      "). Verificar a inconsistência."), "erro")
      } else{
        
        registroLog(paste("PARTE 6: RECEITA DISPONÍVEL apresenta um valor", 
                          formatarNum(receita_disponivel[1, total]),
                          "IGUAL ao total apresentado em BASE_QDD_FISCAL (",
                          formatarNum(qdd[COD_UO==codigo_uo, sum(valor, na.rm=T)]),
                          "), logo o montagem do banco está correta."), "nota")
        }

    
    # =================================================================================================
    # Consolidado
    # =================================================================================================

    tabela5 = rbind(parte2, recursos_recebidos, fill=T)
    tabela5 = rbind(tabela5, recursos_transferidos, fill=T)
    tabela5 = rbind(tabela5, receita_total, fill=T)
    tabela5 = rbind(tabela5, receita_disponivel, fill=T)


    if(!codigo_uo %in% sumario[, unique(COD_UO)]){
      registroLog(paste("Código ", codigo_uo, " não encontrado no sumário. \n\n"), "aviso")
      } else{
        tabela5[, c("nome_uo", "nome_orgao") := NA_character_]
        tabela5$nome_uo[1] = paste0(substr(codigo_uo, 1, 1), ".", substr(codigo_uo, 2, 3), ".", 
                                    substr(codigo_uo, 4, 4), " - ", sumario[COD_UO==codigo_uo, UO])
        
        cod_orgao = sumario[COD_UO==codigo_uo, COD_ORGAO]
        
        tabela5$nome_orgao[1] = paste0(substr(cod_orgao, 1, 1), ".", substr(cod_orgao, 2, 3), ".", 
                                       substr(cod_orgao, 4, 4), " - ", sumario[COD_UO==codigo_uo, ORGAO])
        
        }

      tabela5 = tabela5[,lapply(.SD, formatarNum)]

      tabela5[, nome_orgao := correcaoCaracteresEspeciais(nome_orgao, caracteres)]
      tabela5[, nome_uo := correcaoCaracteresEspeciais(nome_uo, caracteres)]
      tabela5[, especificacao := correcaoCaracteresEspeciais(especificacao, caracteres)]
      
      write.table(tabela5, paste0("volume2/data/tabela5/", codigo_uo,".txt"), quote = TRUE, sep = "\t",
                  na = "", dec = ",", row.names = FALSE)

    registroLog(paste("<strong> Organização concluida para a UO: ", codigo_uo, " </strong> \n\n\n", sep=""), "nota")

    UnidadesOrcamentarias = append(UnidadesOrcamentarias, codigo_uo)

}

  registroLog(paste("A seguinte lista de Uo's  não possuem a tabela 5.\n",
                    paste(setdiff(sumario$COD_UO, UnidadesOrcamentarias), collapse=" ")), "nota")

  fecharLog("logs", "Tabela5_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS")