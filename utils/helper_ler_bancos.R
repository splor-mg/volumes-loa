suppressWarnings(suppressMessages(require(data.table)))
suppressWarnings(suppressMessages(require(readxl)))

# Carrega bases do Sigplan
# PROGRAMAS ---------------------------------------------------------------

load_programas = function(base) {
  x = readr::read_delim(
    file = base,
    delim = '|', 
    locale = readr::locale('pt', encoding = 'Latin1'),
    quote = '',
    na = '',
    col_types = 
      readr::cols(
        `Código do Programa`                                      = readr::col_integer(),
        `Nome do Programa`                                        = readr::col_character(),
        `Exclusão Lógica do Programa`                             = readr::col_character(),
        `Programa Novo`                                           = readr::col_character(),
        `Código da Área Temática`                                 = readr::col_character(),
        `Área Temática`                                           = readr::col_character(),
        `Código do Objetivo Estratégico`                          = readr::col_integer(),
        `Objetivo Estratégico`                                    = readr::col_character(),
        `Código da Diretriz Estratégica`                          = readr::col_character(),
        `Diretriz Estratégica`                                    = readr::col_character(),
        `Justificativa de Inclusão ou Exclusão do Programa`       = readr::col_character(),
        `Código do Órgão Responsável pelo Programa`               = readr::col_integer(),
        `Órgão Responsável pelo Programa`                         = readr::col_character(),
        `Código da Unidade Orçamentária Responsável pelo Programa`= readr::col_integer(),
        `Unidade Orçamentária Responsável pelo Programa`          = readr::col_character(),
        Objetivo                                                  = readr::col_character(),
        Justificativa                                             = readr::col_character(),
        `Tipo de Programa`                                        = readr::col_character(),
        `Horizonte Temporal`                                      = readr::col_character(),
        `Estratégia de Implementação`                             = readr::col_character(),
        `Unidade Administrativa Responsável pelo Programa`        = readr::col_character(),
        `Previsão Orçamentária 2023`                              = readr::col_double(),
        `Previsão Orçamentária 2024`                              = readr::col_double(),
        `Previsão Orçamentária 2025`                              = readr::col_double(),
        `Previsão Orçamentária 2026`                              = readr::col_double(),
        `Programa Transposto`                                     = readr::col_character(),
        Causas                                                    = readr::col_character(),
        `Título do Objetivo de Desenvolvimento Sustentável`       = readr::col_character(),
        `Subtítulo do Objetivo de Desenvolvimento Sustentável`    = readr::col_character() 
      )
  )
  return(as.data.table(x))
}

# ACOES ------------------------------------------------------------------------

load_acoes = function(base) {
  x = readr::read_delim(
    file = base,
    delim = '|', 
    locale = readr::locale('pt', encoding = 'Latin1'),
    quote = '',
    na = '',
    col_types = 
      readr::cols(
        `Código do Programa`                                      = readr::col_integer(),
        `Nome do Programa`                                        = readr::col_character(),
        `Código da Área Temática`                                 = readr::col_character(),
        `Área Temática`                                           = readr::col_character(),
        `Exclusão Lógica do Programa`                             = readr::col_character(),
        `Programa Novo`                                           = readr::col_character(),
        `Justificativa de Inclusão ou Exclusão do Programa`       = readr::col_character(),
        `Código da Unidade Orçamentária Responsável pelo Programa`= readr::col_integer(),
        `Unidade Orçamentária Responsável pelo Programa`          = readr::col_character(),
        `Código da Unidade Orçamentária Responsável pela Ação`    = readr::col_integer(),
        `Unidade Orçamentária Responsável pela Ação`              = readr::col_character(),
        `Código da Função`                                        = readr::col_integer(),
        Função                                                    = readr::col_character(),
        `Código da Subfunção`                                     = readr::col_integer(),
        Subfunção                                                 = readr::col_character(),
        `Código do Tipo de Ação`                                  = readr::col_integer(),
        `Tipo de Ação`                                            = readr::col_character(),
        `Código da Ação`                                          = readr::col_integer(),
        `Título da Ação`                                          = readr::col_character(),
        `Código do Identificador de Ação Governamental (IAG)`     = readr::col_integer(),
        `Identificador de Ação Governamental (IAG)`               = readr::col_character(),
        `Código do Projeto Estratégico`                           = readr::col_integer(),
        `Projeto Estratégico`                                     = readr::col_character(),
        `Exclusão Lógica da Ação`                                 = readr::col_character(),
        `Nova Ação`                                               = readr::col_character(),
        `Justificativa de Inclusão ou Exclusão da Ação`           = readr::col_character(),
        `Transferida para o SISOR`                                = readr::col_character(),
        `Unidade Administrativa Responsável pela Ação`            = readr::col_character(),
        `Base legal`                                              = readr::col_character(),
        `Finalidade da Ação`                                      = readr::col_character(),
        `Descrição da Ação`                                       = readr::col_character(),
        `Código do Público-alvo`                                  = readr::col_integer(),
        `Público-Alvo`                                            = readr::col_character(),
        `Código do Produto`                                       = readr::col_integer(),
        Produto                                                   = readr::col_character(),
        `Especificação do Produto`                                = readr::col_character(),
        `Código da Unidade de Medida do Produto`                  = readr::col_integer(),
        `Unidade de Medida do Produto`                            = readr::col_character(),
        `Previsão Orçamentária 2023`                              = readr::col_double(),
        `Previsão Orçamentária 2024`                              = readr::col_double(),
        `Previsão Orçamentária 2025`                              = readr::col_double(),
        `Previsão Orçamentária 2026`                              = readr::col_double(),
        `Previsão Física 2023`                                    = readr::col_double(),
        `Previsão Física 2024`                                    = readr::col_double(),
        `Previsão Física 2025`                                    = readr::col_double(),
        `Previsão Física 2026`                                    = readr::col_double(),
        `Ação Transposta`                                         = readr::col_character(),
        `Setor de Governo`                                        = readr::col_character()
      )
  )
  return(as.data.table(x))
}


# LOCALIZADORES -----------------------------------------------------------
load_localizadores = function(base) {
  x = readr::read_delim(
    file = base,
    delim = '|', 
    locale = readr::locale('pt', encoding = 'Latin1'),
    quote = '',
    na = '',
    col_types = 
      readr::cols(
        `Código do Programa`                                  =	readr::col_integer(),
        `Nome do Programa`                                    =	readr::col_character(),
        `Código da Área Temática`                             =	readr::col_character(),
        `Área Temática`                                       =	readr::col_character(),
        `Exclusão Lógica do Programa`                         =	readr::col_logical(),
        `Código da Ação`                                      =	readr::col_integer(),
        `Título da Ação`                                      =	readr::col_character(),
        `Código do Identificador de Ação Governamental (IAG)` =	readr::col_integer(),
        `Identificador de Ação Governamental (IAG)`           =	readr::col_character(),
        `Código do Tema Estratégico`                          =	readr::col_integer(),
        `Tema Estratégico`                                    =	readr::col_character(),
        `Código do Projeto Estratégico`                       =	readr::col_integer(),
        `Projeto Estratégico`                                 =	readr::col_character(),
        `Código da Função`                                    =	readr::col_integer(),
        Função                                                =	readr::col_character(),
        `Código da Subfunção`                                 =	readr::col_integer(),
        SubFunção                                             =	readr::col_character(),
        `Código da Unidade Orçamentária Responsável pela Ação`=	readr::col_integer(),
        `Unidade Orçamentária Responsável pela Ação`          =	readr::col_character(),
        `Exclusão Lógica da Ação`                             =	readr::col_logical(),
        `Código do Localizador`                               =	readr::col_character(),
        `Exclusão Lógica do Localizador`                      =	readr::col_character(),
        `Código da Região Geográfica Intermediária`           =	readr::col_integer(),
        `Região Geográfica Intermediária`                     =	readr::col_character(),
        `Código do Município IBGE`                            =	readr::col_integer(),
        `Código do Município Sigplan`                         =	readr::col_integer(),
        Município                                             =	readr::col_character(),
        `Previsão Orçamentária 2023`                          =	readr::col_double(),
        `Previsão Física 2023`                                =	readr::col_double(),
        `Previsão Orçamentária 2024`                          =	readr::col_double(),
        `Previsão Física 2024`                                =	readr::col_double(),
        `Previsão Orçamentária 2025`                          =	readr::col_double(),
        `Previsão Física 2025`                                =	readr::col_double(),
        `Previsão Orçamentária 2026`                          =	readr::col_double(),
        `Previsão Física 2026`                                =	readr::col_double()
      )
  )
  return(as.data.table(x))
}



# INDICADORES -----------------------------------------------------------
load_indicadores = function(base) {
  x = readr::read_delim(
    file = base,
    delim = '|', 
    locale = readr::locale('pt', encoding = 'Latin1'),
    quote = '',
    na = '',
    col_types = 
      readr::cols(
        `Código do Programa`                                                     = readr::col_integer(),
        `Nome do Programa`                                                       = readr::col_character(),
        `Exclusão Lógica do Programa`                                            = readr::col_logical(),
        Indicador                                                                = readr::col_character(),
        `Exclusão Lógica do Indicador`                                           = readr::col_logical(),
        `Unidade de Medida`                                                      = readr::col_character(),
        `Índice de Referência`                                                   = readr::col_double(),
        `Em apuração? (Índice de Referência)`                                    = readr::col_character(),
        `Data de Apuração`                                                       = readr::col_character(),
        `Previsão para 2023`                                                     = readr::col_double(),
        `Em apuração? (2023)`                                                    = readr::col_character(),
        `Previsão para 2024`                                                     = readr::col_double(),
        `Em apuração? (2024)`                                                    = readr::col_character(),
        `Previsão para 2025`                                                     = readr::col_double(),
        `Em apuração? (2025)`                                                    = readr::col_character(),
        `Previsão para 2026`                                                     = readr::col_double(),
        `Em apuração? (2026)`                                                    = readr::col_character(),
        Fonte                                                                    = readr::col_character(),
        Periodicidade                                                            = readr::col_character(),
        `Base Geográfica`                                                        = readr::col_character(),
        `Fórmula de Cálculo`                                                     = readr::col_character(),
        `Justificativa do Status em apuração da(s) Previsão(es) do(s) Índice(s)` = readr::col_character(),
        `Justificativa do Status em apuração do Índice de Referência`            = readr::col_character(),
        `Data Alteração`                                                         = readr::col_character(),
        `Indicador Novo?`                                                        = readr::col_logical(),
        Polaridade                                                               = readr::col_character())
  )
  return(as.data.table(x))
}


# removeAcentos = function(vetor){
#   
#   #===================================================================================
#   # Remove acentos de um vetor, considerando se o Encoding deste é UTF-8 ou unknown.
#   # Outros tipos de enconding não foram considerados
#   #===================================================================================
#   
#   retiraAcentos <- function(vetor, is_utf8) {
#     switch(is_utf8, "TRUE" = tolower(iconv(vetor, from="UTF-8", to="ASCII//TRANSLIT")),
#            "FALSE" = tolower(iconv(vetor, to="ASCII//TRANSLIT")))
#   }
#   
#   return(retiraAcentos(vetor, as.character("UTF-8" %in% Encoding(vetor))))
# }


removeAcentos = function(vetor){
  
  #===================================================================================
  # Remove acentos de um vetor, considerando se o Encoding deste é UTF-8 ou unknown.
  # Outros tipos de enconding não foram considerados
  #===================================================================================
  
  removeAcentoEncoding = function(texto, encoding){
    encoding = ifelse(encoding=="UTF-8", "TRUE", "FALSE")
    switch(encoding, "TRUE" = tolower(iconv(texto, from="UTF-8", to="ASCII//TRANSLIT")),
           "FALSE" = tolower(iconv(texto, to="ASCII//TRANSLIT")))
  }
  
  return(unlist(lapply(vetor, function(x) removeAcentoEncoding(x, Encoding(x)))))
  
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

removeEspacos = function(vetor){
  
  # ============================================================================
  # Remove espaços no final e substitui espaços no meio de expressões por ponto
  # utilizado para padronizar nomes de bancos .xlsx para o padrão de .txt
  # ============================================================================
  
  vetor = gsub("(.+) $", "\\1", vetor)
  return(gsub(" ", ".", vetor))
  
}

trata_exc_logica = function(base, prefixo="exc"){
  
  # ===========================================================================================
  # Trata variáveis de exclusao logica 0 e 1, ou Não e Sim transformando-as em "FALSE" e "TRUE"
  # ===========================================================================================
  
  ExclusaoLogicaBoleano = function(variavel){
    
    if(1 %in% unique(variavel)){
        return(as.character(as.logical(variavel)))
      
    } else if(!F %in% grepl("sim|n.o", tolower(variavel))){
        return(ifelse(grepl("sim", variavel, ignore.case = T), "TRUE", "FALSE"))
      
    } else if(!F %in% grepl("fals.|verd.+", tolower(variavel))){
        return(ifelse(grepl("verd.+", variavel, ignore.case = T), "TRUE", "FALSE"))
      
    } else if(!F %in% grepl("false|true", tolower(variavel))){
       return(toupper(variavel))
        
    }else{
        stop("Variável de exclusão lógica com valores não mapeados por trata_exc_logica().",
             "Valores apresentados: ", paste(unique(variavel), collapse=", "), "\n")
    }
  }
  
    vars_exc = names(base)[grepl(paste0("^",prefixo), names(base), ignore.case = T)]
    ind_exc = which(names(base) %in% vars_exc)
    
    base  = base[, (vars_exc):= lapply(.SD, ExclusaoLogicaBoleano), .SDcols = ind_exc]
    return(base)
}
