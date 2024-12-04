
trataQDD_Fiscal = function(caminho, realizarTeste = TRUE){
  
  #==============================================================================
  # Função para abir o banco BASE_QDD_FISCAL.xlsx presente no volume 5 e volume 2
  #==============================================================================
  
  avisoNumAbas(caminho)
  
  qdd = as.data.table(read_excel(caminho, sheet=1))
  data.table::setnames(qdd, "VALOR FINAL (R$)", "valor")
  names(qdd) = stringi::stri_trans_general(names(qdd), "latin-ascii")
 
  nomes_esperados = c("ANO", "COD_ORGAO", "ORGAO", "PODER", "COD_UO", "UO", "CATEGORIA", "GRUPO_DESPESA",
                        "MODALIDADE", "ELEMENTO_DESPESA", "FONTE", "IPU", "SEQ_PROGTRAB", "FUNCAO", "SUB_FUNCAO", 
                        "PROGRAMA","IDENT_PROJATIV", "PROJ_ATIV", "ACAO", "SUB_PROJETO", "valor","IAG", "NOME_ACAO", 
                        "NOME_PROGRAMA")

  nomes_diferentes = setdiff(nomes_esperados, names(qdd))
    
  if(length(nomes_diferentes)>0){
    warning(paste("BASE_QDD_FISCAL: Há nomes diferentes no banco. Os seguintes nomes de campos não estão no banco atual: {{",
                  paste(nomes_diferentes, collapse=", ")," }}"))
    } 
    
    if(TRUE %in% (qdd$valor<0)){
      warning(paste("BASE_QDD_FISCAL: Há valores negativos na linha ", paste0(which(qdd$valor<0)+1, collapse=", ")))
    } 
    
    if(TRUE %in% (qdd$valor==0)){
      warning(paste("BASE_QDD_FISCAL: Há valores iguais a zero na linha ", paste0(which(qdd$valor==0)+1, collapse=", ")))
    }
    
  return(data.table(qdd))
  }


trataQDD_Ajustado = function(qdd, transf, funfip){

  ### Organização QDD_ajustado
  # Objetivo: Retornar os recursos as UO's que financiam ações de outras UO's e deduzir esses recursos das UO's financiadas
  # Ganho: Os recursos não são duplamente somados no caso em que a UO é financiada, bem como os recursos não são duplamente
  # deduzidos no caso em que a UO é financiadora
  
  qdd_ajustado = qdd[, list(valor = sum(valor, na.rm=T)), 
                     by=list(COD_UO, UO, FUNCAO, CATEGORIA, GRUPO_DESPESA, FONTE, IPU, IAG)]
  
  qdd_ajustado1 = copy(qdd_ajustado)

  transf[, CATEGORIA := ifelse(grupo_de_despesa<4, 3, 4)]

  if(length(setdiff(transf[, unique(ipu)], c(2,5))) > 0){
    warning(paste0("trataQDD_Ajustado(): Os códigos foram criados considerando a IPU 2 e IPU 5 para",
                   " FUNFIP apenas. Há os seguintes problemas:\nNúmero de IPU que aparecem no banco ",
                   "(expectativa 2 e 5): ", transf[, unique(ipu)], "\n"))
   }
  
  if(length(transf[ipu==5, unique(cod_uo_financ)])>1){
      warning(paste0("trataQDD_Ajustado(): UO's que apresentam o IPU 5 (expectativa apenas a FUNFIP 4711): ", 
                   paste(transf[ipu==5, unique(cod_uo_financ)], collapse=", "), "\n"))
  }

  uo_financiadora = transf[ipu==2 | (ipu==5 & cod_uo_financ==funfip ), 
                           list(valor=sum(valor, na.rm=T)), 
                           by= list(COD_UO = cod_uo_financ, UO = uo_financ, CATEGORIA, 
                                    GRUPO_DESPESA=grupo_de_despesa, FONTE = fonte, IPU = ipu, IAG = iag)]

  funfip_uo_beneficiadas = transf[ipu==5 & cod_uo_financ==funfip, 
                                  list(valor=sum(valor, na.rm=T)), 
                                  by= list(COD_UO = cod_uo_benef, CATEGORIA, GRUPO_DESPESA=grupo_de_despesa,
                                           FONTE = fonte, IPU = ipu, IAG = iag)]
  
  linhas_excluir = c()
  
  for(j in 1:nrow(funfip_uo_beneficiadas)){
    COD_UO1 = funfip_uo_beneficiadas$COD_UO[j]
    GRUPO_DESPESA1 = funfip_uo_beneficiadas$GRUPO_DESPESA[j]
    FONTE1 = funfip_uo_beneficiadas$FONTE[j]
    IPU1 = funfip_uo_beneficiadas$IPU[j]
    
    linhas = which(qdd_ajustado$COD_UO == COD_UO1 & qdd_ajustado$GRUPO_DESPESA == GRUPO_DESPESA1 & 
                   qdd_ajustado$FONTE == FONTE1 & qdd_ajustado$IPU == IPU1 )
  
    valor_qdd = qdd_ajustado[linhas, sum(valor, na.rm=T)]
  
    if(valor_qdd!=funfip_uo_beneficiadas[j, valor]){
      
      warning(paste("trataQDD_Ajustado(): O Valor apresentado na funfip e direcionado para a UO ",
                    COD_UO1, " no grupo de despesa ", GRUPO_DESPESA1, " fonte ", FONTE1, " e IPU ", 
                    IPU1, " é DIFERENTE entre os bancos BASE_QDD_FISCAL (valor = ", valor_qdd,
                    ") e BASE_REPASSE_RECURSO (valor = ", funfip_uo_beneficiadas[j, valor], ")",
                    ". O ajuste será realizado do mesmo jeito.\n"))
    }
  
    linhas_excluir = c(linhas_excluir, linhas)
    
  }
  
  qdd_ajustado = qdd_ajustado[!(linhas_excluir),]
  
  valor_deduzido = qdd[FONTE %in% c(42,43) & IPU==5 & COD_UO %in% unique(funfip_uo_beneficiadas$COD_UO), 
                       sum(valor, na.rm=T)] + qdd_ajustado[IPU==2, sum(valor, na.rm=T)]
  
  if(valor_deduzido!=uo_financiadora[, sum(valor)]){
    
    chave_merge = c("COD_UO", "CATEGORIA", "GRUPO_DESPESA", "FONTE", "IPU", "IAG")
    
    banco_benef = qdd_ajustado1[IPU==2,]
    banco_benef = rbind(banco_benef, qdd_ajustado1[linhas_excluir, ])
    
    banco_benef = banco_benef[, list(valor_benef = sum(valor)), chave_merge]
    
    
    uo_financiadora1 = transf[ipu==2 | (ipu==5 & cod_uo_financ==funfip), 
                             list(valor_financ = sum(valor, na.rm=T), 
                                  uos_financiadoras = paste(cod_uo_financ, collapse = "\n")), 
                             by= list(COD_UO = cod_uo_benef, 
                                      CATEGORIA, GRUPO_DESPESA=grupo_de_despesa, 
                                      FONTE = fonte, IPU = ipu, IAG = iag)]
    
    
    result = merge(banco_benef, uo_financiadora1, by=chave_merge, all=T)
    
    result[is.na(result)] = 0
    
    result[, DIFF_BENEF_FINANC:=valor_benef - valor_financ]
    
    write.csv2(result, "logs/erro_qdd_ajustado.csv", row.names = F)
    
    warning(paste("trataQDD_Ajustado(): O Valor deduzido das UO's beneficiadas (", 
                  format(valor_deduzido, big.mark = ".", decimal.mark = ","), 
                  ") é diferente do valor somado as UO's financiadoras (", 
                  format(uo_financiadora[, sum(valor)], big.mark = ".", decimal.mark = ","), 
                  "). Ver logs/erro_qdd_ajustado.csv.\n"))
    
  }

  qdd_ajustado = rbind(qdd_ajustado[IPU!=2,], uo_financiadora, fill=T)

  qdd_ajustado = qdd_ajustado[,list(valor = sum(valor, na.rm=T)), 
                              by= list(COD_UO, UO, FUNCAO, CATEGORIA, GRUPO_DESPESA, FONTE, IPU, IAG)]

  return(qdd_ajustado)

}


geraLoa_desp = function(qdd){
  
  #=========================================================================================
  # Transforma o banco BASE_QDD_FISCAL.xlsx no formato loa_desp do pacote execucao
  #=========================================================================================
  
  if(sum(c("COD_UO", "FUNCAO", "SUB_FUNCAO", "PROGRAMA", "ACAO", "CATEGORIA", "GRUPO_DESPESA", "MODALIDADE", 
           "ELEMENTO_DESPESA", "FONTE", "IPU", "valor", "NOME_ACAO", "IAG") %in% names(qdd))!=14){
    
    stop("Alguma das variáveis COD_UO, FUNCAO, SUB_FUNCAO, PROGRAMA, ACAO, CATEGORIA, GRUPO_DESPESA, MODALIDADE,", 
           " ELEMENTO_DESPESA, FONTE, IPU, ou valor não está presente no banco\n",
         "Dica: rodar trataQDD_Fiscal( ) primeiro.")
  }
  
  setnames(qdd, c("COD_UO", "FUNCAO", "SUB_FUNCAO", "PROGRAMA", "ACAO", "CATEGORIA", "GRUPO_DESPESA", "MODALIDADE", 
                  "ELEMENTO_DESPESA", "FONTE", "IPU", "valor", "NOME_ACAO", "IAG"), 
                c("UO_COD", "FUNCAO_COD", "SUBFUNCAO_COD", "PROGRAMA_COD", "ACAO_COD", "CATEGORIA_COD", "GRUPO_COD", 
                  "MODALIDADE_COD", "ELEMENTO_COD", "FONTE_COD", "IPU_COD", "VL_LOA_DESP", "ACAO_DESC", "IAG_COD" ))

  return(qdd[, c("ANO", "UO_COD", "FUNCAO_COD", "SUBFUNCAO_COD", "PROGRAMA_COD", 
                 "ACAO_COD", "ACAO_DESC", "CATEGORIA_COD", "GRUPO_COD", 
                 "MODALIDADE_COD", "ELEMENTO_COD", "FONTE_COD", "IPU_COD", "IAG_COD", "VL_LOA_DESP" ), with=F])

}

avisoNumAbas = function(caminho){
  if(length(excel_sheets(caminho))>1){
    return(warning(paste("Aviso: o banco ", caminho,
                         " possui mais de 1 aba. A aba que será aberta é sempre a primeira nesse caso a aba",
                         excel_sheets(caminho)[1])), immediate. = T)
  }
}
