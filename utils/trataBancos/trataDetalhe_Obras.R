trataDetalhe_Obras = function(caminho, acoes, realizarTeste = TRUE){

  #==============================================================================
  # Função para abir o banco BASE_DETALHAMENTO_OBRAS.xlsx presente no volume 4
  #==============================================================================

  avisoNumAbas(caminho)
  if(realizarTeste){
    obras = read_excel(caminho, sheet=1)
  } else{
    obras = suppressWarnings(read_excel(caminho, sheet=1))
    }

  names(obras) = iconv(names(obras), from="UTF-8", to = "ASCII//TRANSLIT")
  names(obras) = gsub("VALOR (.+) (.+)$", "VALOR_\\1", names(obras), ignore.case = FALSE)
  names(obras) = gsub(" ", "_", names(obras), ignore.case = FALSE)

  nomes_variaveis = names(obras)
  min_ano = min(as.numeric(gsub("VALOR_T.+_(\\d{4})", "\\1", nomes_variaveis[grepl("^VALOR_T.+", nomes_variaveis)])), na.rm = TRUE)

  obras = data.table(obras)

  setnames(obras, paste0(c("VALOR_TESOURO_","VALOR_OUTROS_"), min_ano), c("VALOR_TESOURO","VALOR_OUTROS"))

  if(is.data.table(acoes)){

    if(!all.equal(c("cod_uo", "cod_funcao", "cod_subfuncao", "cod_prog", "cod_acao", "cod_iag",
                  "unid_med_prod") %in% names(acoes), rep(T, 7))){
      stop("trataDetalhe_Obras(): Não há as variáveis corretas no banco de ações. Rodar trataAcoesPlanejamento( ) antes.")

      }

    acoes = acoes[,.(cod_uo, cod_funcao, cod_subfuncao, cod_prog, cod_acao, cod_iag, unid_med_prod)]

    obras = merge(obras, acoes,
                  by.x = c("UO", "FUNCAO", "SUBFUNCAO", "PROGRAMA", "ACAO", "IAG"),
                  by.y = c("cod_uo", "cod_funcao", "cod_subfuncao", "cod_prog", "cod_acao", "cod_iag"),
                  all.x=T)

    obras[as.character(UNIDADE_DE_MEDIDA_DA_OBRA) %in% c("-",NA), UNIDADE_DE_MEDIDA_DA_OBRA:=unid_med_prod ]
    obras[, unid_med_prod:=NULL ]
  }

  if(realizarTeste){
  # 1.Sobre os nomes das variáveis no banco

    nomes_esperados = c("UO", "FUNCAO", "SUBFUNCAO", "PROGRAMA", "ACAO", "SUBPROJETO", "IAG",
                      "NUMERO_DA_OBRA_SISOR", "NUMERO_DA_OBRA_SIAD", "DESCRICAO_DA_OBRA",
                      "UNIDADE_DE_MEDIDA_DA_OBRA", "QUANTIDADE", "ALTERAR_UNIDADE_DE_MEDIDA_DA_OBRA",
                      "REGIAO_GEOGRAFICA_INTERMEDIARIA", "MUNICIPIO", "VALOR_TESOURO","VALOR_OUTROS", "STATUS_DA_OBRA")

    nomes_diferentes = setdiff(nomes_esperados, names(obras))

    if(length(nomes_diferentes)>0){
      warning(paste("trataDetalhe_Obras(): Há nomes diferentes no banco. Os seguintes nomes de campos",
                  "não estão no banco atual: {{",  paste(nomes_diferentes, collapse=", ")," }}"),
            immediate. = T)
      }

    # 2.Sobre a existência de valores negativos

    if(TRUE %in% (obras$VALOR_OUTROS<0)){
      warning(paste("trataDetalhe_Obras(): Há valores negativos em VALOR_OUTROS na linha ",
                  paste0(which(obras$VALOR_OUTROS<0)+1, collapse=", ")), immediate. = T)
    }

    if(TRUE %in% (obras$VALOR_TESOURO<0)){
        warning(paste("trataDetalhe_Obras(): Há valores negativos em VALOR_TESOURO na linha ",
                        paste0(which(obras$VALOR_TESOURO<0)+1, collapse=", ")), immediate. = T)
    }

    # 3.Sobre a existência de valores igual a zero para a soma de valor tesouro e valor outros

    obras$valor_final = ifelse(is.na(obras$VALOR_OUTROS), 0, obras$VALOR_OUTROS) +
                        ifelse(is.na(obras$VALOR_TESOURO), 0, obras$VALOR_TESOURO)

    if(0 %in% (obras[, valor_final])){
      warning(paste("trataDetalhe_Obras(): Na linha ", paste0(which(obras$valor_final==0)+1, collapse=", "),
                  " há um valor igual a zero para a soma de valor tesouro e valor outros"), immediate. = T)
      }


    # 4.Sobre o texto do UNIDADE_DE_MEDIDA_DA_OBRA

    if(sum(c("-", NA) %in% obras[, unique(UNIDADE_DE_MEDIDA_DA_OBRA)]) >0){

      linhas = which(obras[,as.character(UNIDADE_DE_MEDIDA_DA_OBRA) %in% c("-",NA)])+1

      warning(paste("trataDetalhe_Obras(): Na linha ", paste(as.numeric(linhas) + 1,collapse=", "),
                    "há - ou NA para UNIDADE_DE_MEDIDA_DA_OBRA. Codigo UO",
                    paste(unique(obras[as.character(UNIDADE_DE_MEDIDA_DA_OBRA) %in% c("-",NA), UO]),
                        collapse=", ")),  immediate. = T)

    }


    nCaracteres = obras[,.(mais14caracteres = (sapply(strsplit(obras$UNIDADE_DE_MEDIDA_DA_OBRA, " "), nchar))),
                        by=.(UO, UNIDADE_DE_MEDIDA_DA_OBRA)]

    nCaracteres[, mais14caracteres := sapply(mais14caracteres, max)]


    if(TRUE %in% (nCaracteres$mais14caracteres>14)){

       warning(paste("trataDetalhe_Obras(): Há Unidades de medida que uma palavra tem mais de 14 caracteres. É o caso de ",
                     paste(unique(nCaracteres[mais14caracteres>14, UNIDADE_DE_MEDIDA_DA_OBRA]), collapse=", "),
                     ". Verificar o layout final das seguintes UO's ",
                     paste(unique(nCaracteres[mais14caracteres>14, UO]), collapse=", ")),
               immediate. = T)

    }


  # 5.Sobre o número do SIAD

  freq = data.table(table(obras$NUMERO_DA_OBRA_SIAD))

  if(TRUE %in% (freq$N>1)){
    warning(paste("trataDetalhe_Obras(): Os seguintes valores se repetem mais de uma vez no campo SIAD: \n",
                      paste(freq$V1[freq$N>1], collapse=", ")),
            immediate. = T)
    }

  if(sum(c("-", "0", NA) %in% freq[,unique(as.character(V1))])>0){
    warning(paste("trataDetalhe_Obras(): Há 0 ou - NA no campo SIAD. Analisar as seguintes UO's ",
                  paste(unique(obras[as.character(NUMERO_DA_OBRA_SIAD) %in% c("-", "0", NA), UO]), collapse=", ")),
            immediate. = T)
    }


  # 6.Sobre o número do SISOR

  freq = data.table(table(obras$NUMERO_DA_OBRA_SISOR))

  if(TRUE %in% (freq$N>1)){
    warning(paste("trataDetalhe_Obras(): Os seguintes valores se repetem mais de uma vez no campo SISOR: \n",
                  paste(freq$V1[freq$N>1], collapse=", ")), immediate. = T)
    }

  if(sum(c("-", "0", NA) %in% freq[, unique(as.character(V1))]) >0){
    warning(paste("trataDetalhe_Obras(): Há 0 ou - NA no campo SISOR. Analisar as seguintes UO's ",
                  paste(unique(obras[as.character(NUMERO_DA_OBRA_SISOR) %in% c("-", "0", NA), UO]), collapse=", ")),
            immediate. = T)

    }
  }

  return(obras)

}


avisoNumAbas = function(caminho){
  if(length(excel_sheets(caminho))>1){
    return(warning(paste("Aviso: o banco ", caminho,
                         " possui mais de 1 aba. A aba que será aberta é sempre a primeira nesse caso a aba",
                         excel_sheets(caminho)[1])), immediate. = T)
  }
}
