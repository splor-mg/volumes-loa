trataReceita_Fiscal = function(caminho, realizarTeste = TRUE){

  #===================================================================================
  # Função para abrir o banco datapackages/ppo/data/orcamento_receita.csv
  #===================================================================================

  ppo = fread(caminho, encoding = "UTF-8", colClasses = list(character = "receita_cod"))
  texto = function(x) toupper(trimws(x, whitespace = "[\\h\\v]"))
  digitos = function(inicio, fim) as.numeric(substr(ppo$receita_cod, inicio, fim))

  receita = ppo[, list(UO_COD = uo_cod, NOME_UO = texto(uo_nome), SIGLA_UO = texto(uo_sigla),
                       COD_FONTE = fonte_cod, FONTE = fonte_desc,
                       CATEGORIA = digitos(1, 1), ORIGEM = digitos(2, 2), ESPECIE = digitos(3, 3),
                       RUBRICA = digitos(4, 4), ALINEA = digitos(5, 6), SUBALINEA = digitos(7, 7),
                       TIPO = digitos(8, 8), ITEM = digitos(9, 10), SUBITEM = digitos(11, 13),
                       COD_RECEITA = as.numeric(receita_cod), RECEITA = texto(receita_desc),
                       INTERP_RECEITA = interpretacao, valor = vlr_loa_rec, ANO = ano,
                       `BASE LEGAL` = base_legal)]

  if(realizarTeste){

    if(nrow(receita[valor<0 & substr(COD_RECEITA,1,1)!="9"])>0){
      warning(paste("trataReceita_Fiscal(): Há valores negativos na linha ",
                    paste0(which(receita$valor<0)+1, collapse=", "), "\n"))
    }

  }

  return(receita)

  }


avisoNumAbas = function(caminho){
  if(length(excel_sheets(caminho))>1){
    return(message(paste("trataReceita_Fiscal(): Aviso: o banco ", caminho,
                         " possui mais de 1 aba. A aba que será aberta é sempre a primeira nesse caso a aba",
                         excel_sheets(caminho)[1])))
  }
}


geraLoa_rec = function(receitaSISOR){

  #=========================================================================================
  # Transforma o banco BASE_ORCAM_RECEITA_FISCAL.xlsx no formato loa_rec do pacote execucao
  #=========================================================================================

  nomes_antigos = c("ANO","UO_COD", "COD_RECEITA", "RECEITA", "COD_FONTE", "valor")
  nomes_novos = c("ANO","UO_COD", "RECEITA_COD", "RECEITA_DESC", "FONTE_COD", "VL_LOA_REC")

  if(length(setdiff(nomes_antigos, names(receitaSISOR))) >0){
    stop("Erro em geraLoa_rec: Espera-se encontrar as seguintes variáveis no banco BASE_ORCAM_RECEITA_FISCAL.xlsx:",
         paste(setdiff(nomes_antigos, names(receitaSISOR)), collapse=", "), "\n")
  }

  setnames(receitaSISOR, nomes_antigos, nomes_novos)

  receitaSISOR$RECEITA_COD = as.numeric(as.character(receitaSISOR$RECEITA_COD))

  return(receitaSISOR[, nomes_novos, with=F])

}


trataReceita_Fiscal_antigo = function(caminho, realizarTeste = TRUE){

  #==============================================================================
  # Função para abir o banco BASE_ORCAM_RECEITA_FISCAL.xlsx presente no volume 2
  #==============================================================================

  avisoNumAbas(caminho)

  receita = read_excel(caminho, sheet=1)
  names(receita) = gsub(".*VALOR *FINAL.+", "valor", names(receita), ignore.case = FALSE)
  receita = data.table(receita)


  if(realizarTeste){

    nomes_esperados = c("UO_COD", "NOME_UO","SIGLA_UO", "COD_FONTE", "FONTE", "INTERPRETACAO",
                        "CATEGORIA", "SUBCATEGORIA" ,"FONTE_CLAS", "RUBRICA", "ALINEA","SUBALINEA",
                        "ITEM","COD_RECEITA", "RECEITA", "INTERP_RECEITA" , "valor", "ANO", "BASE LEGAL")

    nomes_diferentes = setdiff(nomes_esperados, names(receita))



    if(length(nomes_diferentes)>0){
      warning(paste("trataReceita_Fiscal(): Há nomes diferentes no banco. Os seguintes nomes de ",
                    "campos não estão no banco atual: {{", paste(nomes_diferentes, collapse=", ")," }}\n"))
    }

    if(nrow(receita[valor<0 & substr(COD_RECEITA,1,1)!="9"])>0){
      warning(paste("trataReceita_Fiscal(): Há valores negativos na linha ",
                    paste0(which(receita$valor<0)+1, collapse=", "), "\n"))
    }

    # if(TRUE %in% (receita$valor==0)){
    #   warning(paste("trataReceita_Fiscal(): Há valores iguais a zero na linha ",
    #                     paste0(which(receita$valor==0)+1, collapse=", "), "\n"))
    # }

  }

  return(data.table(receita))

}

ler_novaReceita = function(caminho){

  classificacao = fread(caminho, encoding = "UTF-8", colClasses = list(character = "receita_cod"))
  classificacao = classificacao[, list(RECEITA_COD = as.numeric(receita_cod),
                                       RECEITA_DESC = trimws(receita_desc, whitespace = "[\\h\\v]"))]

  return(classificacao[!is.na(RECEITA_COD), ])

}
