source("utils/funcoes.R", encoding = "UTF-8")

trataAcoesPlanejamento = function(caminho, ANO_ANALISE){
  
  caminho = ultimo_banco_modificado(caminho)
  cat("    Utilizando ", caminho, "\n")
  
  if(grepl(".+\\.xlsx$", caminho)){
    return(trataAcoesPlanejamento_xlsx(caminho, ANO_ANALISE))
  } else{
    return(trataAcoesPlanejamento_txt(caminho, ANO_ANALISE))
  }
}


trataAcoesPlanejamento_xlsx = function(caminho, ANO_ANALISE){
  
  #===================================================================================================
  # Função para abir o banco acoes_planejamento_final_02_02_2016.xlsx presente no volume 2 e volume 3
  #===================================================================================================

  acoes = read_excel(caminho, sheet=1)
  
  lista_nomes = list("C.{1}digo *([a-z]{2})? *fun.+" = "cod_funcao",
                     "Nome *([a-z]{2})? *fun.+" = "nome_funcao", 
                     "C.{1}digo *([a-z]{2})? *subfun.+" = "cod_subfuncao",
                     "Nome *([a-z]{2})? *subfun.+" = "nome_subfuncao", 
                     "C.{1}digo *([a-z]{2})? *Programa" = "cod_prog",
                     "Nome *([a-z]{2})? *Programa" = "nome_prog",
                     "C.{1}digo *([a-z]{2})? *Tipo *([a-z]{2})? *A(ç|c)(a|ã)o" = "cod_tipo_acao",
                     "C.{1}digo *([a-z]{2})? *A(ç|c)(a|ã)o" = "cod_acao", 
                     "T(i|í)tulo *([a-z]{2})? *A(ç|c)(a|ã)o" = "titulo_acao", 
                     "C.{1}digo *IAG" = "cod_iag",
                     "Finalidade *([a-z]{2})? *A(ç|c)(a|ã)o" = "final_acao", 
                     "Produto *([a-z]{2})? *A(ç|c)(a|ã)o" = "prod_acao",
                     "^Unidade *([a-z]{2})? *Medida *([a-z]{2})? *Produto" = "unid_med_prod", 
                     "C.{1}digo *([a-z]{2})? *Unidade Or(ç|c)ament(á|a)ria.*A(ç|c)(a|ã)o" = "cod_uo", 
                     "Nome *([a-z]{2})? *Tipo *([a-z]{2})? *A(ç|c)ão" = "tipo_acao", 
                     "Exclus(ã|a)o L(ó|o)gica *([a-z]{2})? *A(c|ç)(ã|a)o" = "exc_acao")
  
  
  if(class(ANO_ANALISE)=="numeric"){
    lista_nomes[[paste(".* *f(i|í)sica *", ANO_ANALISE, sep="")]] = "valor_prod" 
  }
  
  lista_match_nomes = list()
  
  for(padrao in names(lista_nomes)){
    if(sum(as.numeric(grepl(padrao, names(acoes), ignore.case = TRUE)))!=1){
      
      stop(paste0("trataAcoesPlanejamento() : O padrao de variável <grepl>", padrao, 
                  "</grepl> não foi encontrado dentre os nomes do banco de ações de planejamento.",
                  " (ou foi encontrado mais de uma vez). Dessa forma, o banco final não terá a variável <Var>",
                  lista_nomes[[padrao]], "</Var> (ou terá essa variável no banco duplicada).",
                  " Corrigir no banco de acoes de planejamento."))
    }
    
    lista_match_nomes[[padrao]] = names(acoes)[grepl(padrao, names(acoes), ignore.case = TRUE)]
    names(acoes) = gsub(padrao, lista_nomes[[padrao]], names(acoes), ignore.case = TRUE)
  }
  
  novos_nomes = append(unlist(lista_nomes, use.names=F), "Produto")
  
  acoes = acoes[,novos_nomes]
  acoes = data.table(acoes)
  
  if(TRUE %in% (acoes$valor_prod<0)){
    warning(paste0("trataAcoesPlanejamento(): Na linha ", 
                   paste0(which(acoes$valor_prod<0)+1, collapse=", "),
                   " há um valor negativo para valor_prod (Previsão Física ANO)"))
      } 
  
  if(TRUE %in% (acoes$valor_prod==0)){
        warning(paste0("trataAcoesPlanejamento(): Na linha ", 
                       paste0(which(acoes$valor_prod==0)+1, collapse=", "),
                       " há um valor igual a zero para valor_prod (Previsão Física ANO)"))
    }
  
  return(acoes)
  
}


trataAcoesPlanejamento_txt = function(caminho, ANO_ANALISE){
  
  # ===============================================================
  # Abre o arquivo bancos/acoes_planejamento.txt. A função:
  # 1. Checa se o banco possui as variáveis esperadas
  # 2. Muda o nome das variáveis
  # 3. Checa se o tipo das variáveis é o esperado.
  # ===============================================================
  
  
  source('utils/helper_ler_bancos.R', encoding = 'utf-8')
  
  acoes_planejamento = load_acoes(caminho)
  names(acoes_planejamento) = removeAcentos(make.names(names(acoes_planejamento)))
  acoes_planejamento = acoes_planejamento[exclusao.logica.do.programa=='Não',]
  acoes_planejamento = acoes_planejamento[exclusao.logica.da.acao=='Não',]
  
  nomes_esperados = c("codigo.do.programa", "nome.do.programa", "codigo.da.unidade.orcamentaria.responsavel.pela.acao",
                      "codigo.da.funcao", "funcao",  "codigo.da.subfuncao",  "subfuncao",
                      "codigo.do.tipo.de.acao",  "tipo.de.acao",  "codigo.da.acao",  "titulo.da.acao",
                      "codigo.do.identificador.de.acao.governamental..iag.",  "exclusao.logica.da.acao",  "finalidade.da.acao",  
                      "codigo.do.produto",
                      "produto",  "unidade.de.medida.do.produto")
  
  novos_nomes = c("cod_prog", "nome_prog", "cod_uo", 
                  "cod_funcao", "nome_funcao", "cod_subfuncao", "nome_subfuncao",
                  "cod_tipo_acao", "tipo_acao", "cod_acao", "titulo_acao",
                  "cod_iag", "exc_acao", "final_acao", "prod_acao",
                  "Produto", "unid_med_prod")
  
  if(class(ANO_ANALISE)=="numeric"){
    nomes_esperados = c(nomes_esperados, paste0("previsao.fisica.", ANO_ANALISE))
    novos_nomes = c(novos_nomes, "valor_prod")
  }
  
  varEsperadas_naoIndentificadas = setdiff(nomes_esperados, names(acoes_planejamento))
  
  if(length(varEsperadas_naoIndentificadas) > 0){
    stop("Em ler_acoes_planejamento(): Variável(is) ", 
         paste(varEsperadas_naoIndentificadas, collapse=" "), "não encontrada(s) no banco")
  }
  
  setnames(acoes_planejamento, nomes_esperados, novos_nomes)
  
  acoes_planejamento = acoes_planejamento[, novos_nomes, with=F]
  
  verificaTipoVariaveis(acoes_planejamento, c("nome_prog", "nome_funcao", "nome_subfuncao", 
                                              "tipo_acao", "titulo_acao", "exc_acao", 
                                              "final_acao", "prod_acao","Produto", "unid_med_prod"))
  
  return(acoes_planejamento)
}


verificaTipoVariaveis = function(base, varsTextoEsperadas){
  
  #=====================================================================================
  # Verifica se as variáveis possuem as classes esperadas
  #
  # Motivação:
  # Bancos do SIGPLAN extensão .txt possuem textos com muitos caracteres especiais.
  # Há um risco de algum caracter gerar um efeito semelhante ao tab no excel,
  # o que faria com que o número de variáveis aumentasse bem como variáveis 
  # numéricas venham a conter textos.
  #=====================================================================================
  
  varsTexto = unlist(lapply(base, class))
  varsTexto = names(varsTexto)[varsTexto=="character"]
  
  if(length(setdiff(varsTexto, varsTextoEsperadas))>0){
    stop("Variáveis ", paste(setdiff(varsTexto, varsTextoEsperadas), collapse=" "), " foram iniciadas como texto. 
         A expectativa é que fossem númericas.")
  }
}
