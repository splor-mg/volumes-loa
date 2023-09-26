suppressWarnings(suppressMessages(require(data.table))); suppressWarnings(suppressMessages(require(readxl)))

mergeDT <- function(x,y, ...) {
  
  # ========================================================
  # Realiza o merge segundo os parâmetros da função merge()
  # apresentando uma estatistica de quais observacoes
  # residem apenas no banco x, quais apenas no banco y
  # e quais apresentam correspondência em ambos os bancos.
  # ========================================================

  x = data.table(x)
  y = data.table(y)
  x[, merge1 := 1]
  y[, merge2 := 2]
  
  novobanco <- merge(x, y, ...)
 
  novobanco[is.na(merge1), merge1:=0]
  novobanco[is.na(merge2), merge2:=0]
  novobanco[, merge3:= merge1 + merge2]
  
  novobanco[,merge :="Em ambos os bancos"]
  novobanco[merge3==1, merge := "Apenas no Banco X"]
  novobanco[merge3==2, merge := "Apenas no Banco Y"]
  
  novobanco[, c("merge1", "merge2", "merge3"):=NULL]
  #print(table(novobanco$merge))
  
  return(novobanco)
}

Moda <- function(x) {
  # =====================================================
  # Apresenta o valor com maior frequência de um vetor
  # =====================================================
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

getCodigoR = function(input, output){
  
  # ===========================================================================
  # Copia todo o script entre INICIO TABELA e FIM TABELA dos arquivos .Rnw
  #
  # - Motivação:
  # Escrever scripts individuais por tabela, e esses
  # códigos serem utilizados na geração do relatório final
  # ===========================================================================
  
  script = readLines(input, warn=FALSE)  
  inicio_cod = which(grepl("# *INICIO *TABELA", script))
  fim_cod = which(grepl("# *FIM *TABELA", script))
  
  dir.create(output, showWarnings = FALSE)
  
  if(length(fim_cod)==0 | length(inicio_cod)==0){
    
    print(paste("length(fim_cod):", length(fim_cod), 
                "--length(inicio_cod):", length(inicio_cod), "Revisar o script .Rnw"))
  }
  
  sink(paste(output,"/", gsub(".+/(.+)\\.Rnw", "\\1",input, ignore.case = T),".R", sep=""))
  
  retiraLinhasSweave = function(texto){
    return(gsub("^ *(<<|@|%|\\\\).*", "", texto))
    }
  
  for(i in inicio_cod:fim_cod){
    cat(retiraLinhasSweave(script[i]), "\n")
  }
  
  sink()
  #print(paste("Codigo R salvo em ", output))
}


unique1 = function(x){
  
  # ===========================================================================
  # Em diversas visualizações de em .Rnw é utilizado unique com a expectativa
  # de aparecer apenas um valor. Essa função faz o teste e retorna um warning
  # em caso negativo
  # ===========================================================================
  
  y = unique(x)
  
  if(length(y)>1){
    warning("Em unique1()\n:Expectativa era que unique(...) retornasse apenas um valor, mas retornou:\n", 
            paste(y, collapse = "\n"), immediate. = TRUE)
  }
  
  return(y)
}


aplicaNegrito = function(texto, colocarNegrito){
  # =================================================================
  # Aplica negrito em qualquer tipo de texto no latex
  # Parametro colocarNegrito necessário para
  # T2_RECURSOS_FINANCEIROS_FONTE_RECURSOS_GRUPOS_DESPESA_FISCAL.Rnw
  # =================================================================
  
  if(colocarNegrito==1){
    return(paste("\\textbf{ ", texto, " }", sep=""))
  } else{
    return(texto)
  }
}

ler_csv = function(caminho){
  
  # Função para abrir os bancos csv já tratados em data
  
  return(data.table(read.csv2(caminho, header = T, stringsAsFactors = F)))
  
}



apoio = function(caminho, aba){
  
  # ====================================================================================
  # Função criada para ler o banco Tabela de apoio - classificação e especificações.xlsx
  # ====================================================================================
  
  nome = read_excel(caminho, sheet=aba)
  names(nome) = iconv(nome[1,], from="UTF-8" ,to="ASCII//TRANSLIT")
  
  return(data.table(nome[2:nrow(nome),]))
  
}


TratamentoNA = function(valor){
  # ==================================
  # Se o valor for NA substitui por ""
  # ==================================
  
  if(is.na(valor)){""} else{valor}
}


preencherCelula = function(valor){
  # =============================================
  # Utilizada em Volume 4 T2:
  # Preenche com X ou de Cinza o status da obra
  # =============================================
  
  if(is.na(valor)==F & valor==1){
    return("X")
    #return("\\cellcolor{gray!50}")
  } else{
    return("")
  }
}

tratUnidadeMedida = function(unidadeMedida){
  # ===============================================
  # Utilizada em Volume 4 T2:
  # Reduz o tamnanho da fonte para o caso de 
  # Unidades de Medida com mais de 11 caracteres
  # ===============================================
  
  if(nchar(as.character(unidadeMedida)) > 11){
    return(paste("\\fonteSeis{ ", as.character(unidadeMedida), "}"))
  } else{
    return(as.character(unidadeMedida))
  }
}

na2zero = function(x){
  if(is.numeric(x)){ x = ifelse(is.na(x), 0, x)
  } else{  x
  }
}

make_vol_dir = function(x){
  # ============================================
  # Gera o nome do diretorio em que está o volume
  # No caso do volumes 2A e 2B indica que estes
  # estão no dir volume2
  # ============================================

  if(grepl("^2(A|B)", x)){ return("2")
    } else if(grepl("^T\\d+.+", x)){ return("1")
    } else if(grepl("^6(A|B)", x)) {
        return("6")
      }
        else{ return(x)
    }
}

removeAcentos = function(vetor){
  
  #===================================================================================
  # Remove acentos de um vetor, considerando se o Encoding deste é UTF-8 ou unknown.
  # Outros tipos de enconding não foram considerados
  #===================================================================================
  
  removeAcentoEncoding = function(texto, encoding){
    tolower(stringi::stri_trans_general(texto, "latin-ascii"))
  }
  
  return(unlist(lapply(vetor, function(x) removeAcentoEncoding(x))))
  
}


abrirLog = function(caminho, tabela){
  log_r <<- file(paste0(caminho, "/log_", tabela, ".Rmd"),"w", encoding = 'UTF-8')
  writeLines(paste("<h2>Log ", tabela ,"</h2> <br> <h3>", 
                   format(Sys.time(), "%d de %B de %Y as %X"), "</h3>"), con=log_r, sep="<br><br>")
}


registroLog = function(registro, tipo){
  if(tipo=="erro"){
    registro = gsub("(\\n*)? *(.+) *(\\n*)?$", "\\1 <p style='color:red'> \\2 </p> \\3", registro)
  } else if(tipo=="aviso"){
    registro = gsub("(\\n*)? *(.+) *(\\n*)?$", "\\1 <p style='color:blue'> \\2 </p> \\3", registro)
  }else{
    registro = gsub("(\\n*)? *(.+) *(\\n*)?$", "\\1 <p> \\2 </p> \\3", registro)
  }
  
  registro = gsub("\\n", "<br>", registro)
  if(exists("log_r")){
    writeLines(registro, con=log_r, sep="\n")  
  }
}


fecharLog = function(caminho, tabela){

  close(log_r)
  
  knitr::knit(paste0(caminho, "/log_", tabela, ".Rmd"), 
              paste0(caminho, "/log_", tabela, ".md"),
              encoding = "UTF-8")
  
  markdown::markdownToHTML(paste0(caminho, "/log_", tabela, ".md"), paste0(caminho, "/log_", tabela, ".html"))
  
  v = file.remove(paste0(caminho, "/log_", tabela, ".Rmd"), paste0(caminho, "/log_", tabela, ".md"))
  
  utils::browseURL(paste0("file://", getwd(),"/", caminho, "/log_", tabela, ".html"))
  
}


getRnw_V1 = function(tbl){
  
  # Obtem o arquivo .Rnw em volume1/Rnw que segue o padrão descrito em tbl 
  
  padrao = paste0("^", tbl, ".+\\.Rnw$")
  indices = grepl(padrao, dir("volume1/Rnw"))
  
  if(!T %in% indices) stop("Em volume1/Rnw não existe um arquivo com o padrão \'", padrao, "\'\n")
  
  return(dir("volume1/Rnw")[indices])
  
}


formatarNum = function(x){
  if(is.numeric(x)){  
    x = format(x, big.mark=".", scientific = FALSE, decimal.mark = ",")
    x = gsub(" *(-*\\d+.+)", "\\1", x)
    x = ifelse(grepl("NA",x), NA, x)
  } else{ x
  }
}


negativoContabil = function(x){
  # Coloca parentenses em valores negativos
  
  return(gsub(" *-(\\d{1}.+)", "\\(\\1\\)", x))
}


formatReceita_COD = function(x){
  # Formata os codigos de receita colocando separador de pontos entre as naturezas
  
  if(nchar(x)==10){
      return(paste(substr(x, 1, 1), substr(x, 2, 2), substr(x, 3, 3), substr(x, 4, 4), 
                   substr(x, 5, 6), substr(x, 7, 8), substr(x, 9, 10), sep="."))
  
    }else if(nchar(x)==13){
      return(paste(substr(x, 1, 4), substr(x, 5, 6), substr(x, 7, 7), substr(x, 8, 8), 
                  substr(x, 9, 10), substr(x, 11, 13), sep="."))
  
    } else{
      return(x)
  }
}

ler_banco_txt = function(caminho, decimal = "@"){
  
  return(as.data.table(read.csv2(caminho,  header=T, sep="\t", dec=decimal, stringsAsFactors = FALSE, quote = NULL)))

}


ultimo_banco_modificado = function(caminho){
  
  # ===========================================================================================
  # Identifica entre o banco .txt e .xlsx para determinado prefixo, qual é o mais atual
  # Ex.: em bancos/localizadores_Todos_planejamento, qual é o arquivo mais atual:
  # bancos/localizadores_Todos_planejamento.txt ou bancos/localizadores_Todos_planejamento.xslx
  # ===========================================================================================
  
  diretorio = gsub("(.+)/([a-z_A-Z]*)$", "\\1", caminho)
  prefixo = gsub("(.+)/([a-z_A-Z]*)$", "\\2", caminho)
  
  arquivos = dir(diretorio)
  arquivos = arquivos[grepl(prefixo, arquivos)]
  
  if(length(arquivos)==0) warning("Não há nenhum banco para o argumento ", caminho, "\n")
  
  datas_modificacao = lapply(arquivos, function(x) file.mtime(paste0(diretorio, "/", x)))
  ultimo_modificado = arquivos[which.max(datas_modificacao)]
  
  return(paste0(diretorio, "/", ultimo_modificado))
  
}

is_receitas_previdenciarias = function(base){
  
  base[, RECEITAS_PREV := FALSE]
  
  base[RECEITA_COD %in% c(1210042101000, 1210042199002, 1210042199001, 1210042102000, 
                          1210042104000, 1210042105000, 1210042106000, 1210042103000, 
                          1210042107000, 1210991199000, 1210043101000, 1210043102000, 
                          1210043104000, 1210043105000, 1210043106000, 1210043103000, 
                          1210043107000, 1210044101000, 1210044102000, 1210044104000, 
                          1210044105000, 1210044106000, 1210044103000, 1218022102000, 
                          1218022101000, 1218023102000, 1218021101001, 9321004101002, 
                          7210041101000, 7210041102000, 7210041104000, 7210041105000, 
                          7210041106000, 7210041103000, 7210041107000, 7218021101002, 
                          7218021101001, 7210991103000, 7218025101002, 7218025101001, 
                          7210991206000, 1218022104000, 1218023104000, 1218024104000), RECEITAS_PREV := TRUE]
  
  base[UO_COD == 2121 & RECEITA_COD %in% c(1310011101001, 1322001102000, 1329001102000, 
                                           1321001101000, 1640011101000, 1690991101000, 
                                           1990991199000, 2213001199000, 2300061101000,
                                           1310011201001, 1310991201000),
       RECEITAS_PREV := TRUE]
  
  
  base[UO_COD == 4711 & RECEITA_COD %in% c(1321001101000, 1321004101001, 1321004101002, 
                                           1390001401000, 1390001301000, 1990031101000, 
                                           192299119900, 1990991101000, 1990991101000),
       RECEITAS_PREV := TRUE]
  
  return(base$RECEITAS_PREV)

}


is_despesas_previdenciarias = function(base){
  
  base[, UGEPREVI:=FALSE]
  base[UO_COD == 2121 & ACAO_COD %in% c(2018, 4003), UGEPREVI:=TRUE]
  base[UO_COD == 4711 & !ACAO_COD %in% c(7008, 7023, 7016), UGEPREVI:=TRUE]
  base[UO_COD %in% c(1011, 1021, 1031, 1051, 1091, 1441) & ACAO_COD==7006 , UGEPREVI:=TRUE]
  base[ACAO_COD %in% c(7008, 7023,7006), UGEPREVI:=TRUE]
  base[ELEMENTO_COD %in% c(92,94) &  GRUPO_COD==1 & UO_COD %in% c(2121, 4711), UGEPREVI:=TRUE]
  base[ACAO_COD %in% c(7007, 7002, 7016), UGEPREVI:=TRUE]
  base[UO_COD %in% c( 1251, 1401, 2121, 1051) & ELEMENTO_ITEM_COD %in% c(501, 505, 802, 805, 807),  UGEPREVI:=TRUE]
  base[UO_COD %in% c(2011, 2121) & ACAO_COD == 7004, UGEPREVI:=TRUE]
  
  return(base$UGEPREVI)
  
}


merge_QDD_v5 = function(banco, uos_proposta){
  
  vl_banco = banco[, sum(valor)]
  
  banco_proposta = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL_PROPOSTA.xlsx")
  
  chave_bancos = c("ANO", "COD_ORGAO", "COD_UO", "FUNCAO", "SUB_FUNCAO", "PROGRAMA", 
                   "IDENT_PROJATIV", "PROJ_ATIV", "SUB_PROJETO", "CATEGORIA", "GRUPO_DESPESA", 
                   "MODALIDADE", "ELEMENTO_DESPESA", 'IAG', "FONTE", "IPU")
  
  banco_proposta = banco_proposta[, c(chave_bancos, "valor"), with=F]
  
  setnames(banco_proposta, "valor", "valor_proposto")
  banco = merge(banco, banco_proposta[COD_UO %in% uos_proposta], by=chave_bancos, all.x=T)
  
  if(vl_banco != banco[, sum(valor)]) stop("Erro em merge_QDD_v5")
  
  return(banco)
  
}

zero2traco = function(valor){
  return(ifelse(valor==0, "-", valor))
}

adiciona_desc_volumes = function(base, column) {
  result <- data.table::copy(base)
  
  if(column == "GRUPO") {
    aux <- data.table(read_excel("bancos/manual/desc_grupos_de_despesa.xlsx"))
    aux <- aux[
      , .(GRUPO_COD = CODIGO, 
          GRUPO_DESC = stringi::stri_trans_general(ESPECIFICACAO, "latin-ascii"))
    ]
    result <- aux[result, on = "GRUPO_COD"]
  } else if(column == "UO") {
    aux <- data.table(read_excel("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx"))
    aux <- unique(
      aux[
        , .(UO_COD = UO_COD, 
            UO_SIGLA = SIGLA_UO)
      ]
    )
    result <- aux[result, on = "UO_COD"]
  } else if(column == "PROGRAMA") {
    aux <- data.table(read_excel("bancos/SISOR/BASE_QDD_FISCAL.xlsx"))
    aux <- unique(
      aux[
        , .(UO_COD = COD_UO,
            PROGRAMA_COD = PROGRAMA, 
            PROGRAMA_DESC = stringi::stri_trans_general(NOME_PROGRAMA, "latin-ascii"))
      ]
    )
    result <- aux[result, on = c("UO_COD", "PROGRAMA_COD")]
  } else {
    stop(paste("adiciona_desc_volumes não pode ser utilizada para coluna", column))
  }
  
  result
}

