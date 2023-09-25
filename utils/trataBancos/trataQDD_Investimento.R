trataQDD_Investimento = function(caminho, realizarTeste = TRUE){
  
  #==============================================================================
  # Função para abir o banco BASE_QDD_INVESTIMENTO.xlsx presente no volume 3
  #==============================================================================
  
  avisoNumAbas(caminho)
  
  qdd = read_excel(caminho, sheet=1)
  data.table::setnames(qdd, "VALOR (R$)", "valor")
  names(qdd) = stringi::stri_trans_general(names(qdd), "latin-ascii")
  
  nomes_esperados = c("ANO", "COD_ORGAO", "ORGAO", "PODER", "COD_UO", "UO", "SEQ_PROGTRAB", "FUNCAO", "SUB_FUNCAO",
                      "PROGRAMA", "IDENT_PROJATIV", "PROJ_ATIV", "ACAO", "valor", "IAG", "DESC_PROJETO_ATIV", "CATEGORIA",
                      "COD_NATUREZA", "NATUREZA", "COD_FONTE", "FONTE", "NOME_ACAO", "NOME_PROGRAMA")

  nomes_diferentes = setdiff(nomes_esperados, names(qdd))
    
  if(length(nomes_diferentes)>0){
    warning(paste("trataQDD_Investimento(): Há nomes diferentes no banco.", 
                  "Os seguintes nomes de campos não estão no banco atual: {{", 
                  paste(nomes_diferentes, collapse=", ")))
    } 
    
  if(TRUE %in% (qdd$valor<0)){
    warning(paste("trataQDD_Investimento(): Há valores negativos na linha ", 
                  paste0(which(qdd$valor<0)+1, collapse=", ")))
    } 
    
  if(TRUE %in% (qdd$valor==0)){
    warning(paste("trataQDD_Investimento(): Há valores iguais a zero na linha ", 
                  paste0(which(qdd$valor==0)+1, collapse=", ")))
    }
    
  return(data.table(qdd))
  
  }


avisoNumAbas = function(caminho){
  if(length(excel_sheets(caminho))>1){
    return(warning(paste("Aviso: o banco ", caminho,
                         " possui mais de 1 aba. A aba que será aberta é sempre a primeira nesse caso a aba",
                         excel_sheets(caminho)[1])))
  }
}