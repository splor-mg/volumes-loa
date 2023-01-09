# Organização do banco FONTE DE RECURSOS DE GRUPOS DE DESPESA – FISCAL - Volume 2 
options(warn=1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataPessoal.R", encoding = "UTF-8")

# ============================================================================
# Definir parâmetros

codigo_inativos = c(7007, 7006)
desconsiderarUO = c(9207, 1111, 1461, 2391, 2401, 2451)
uo_militar_com_civis_inativos = c(1251, 1401)
# ============================================================================

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", TRUE)

uos_com_info_inativos = qdd[ACAO %in% codigo_inativos, unique(COD_UO)]
#uos_com_info_inativos = c(1251, 1401)

qdd = qdd[(GRUPO_DESPESA==1 & IPU!=9)  | (GRUPO_DESPESA==3 & ELEMENTO_DESPESA == 34)  , ]

# Filtrar na base QDD fiscal a UO – “coluna F”; depois o grupo de despesa “1”– coluna I, 
# ainda, filtrar os IPU’s – na coluna M, exceto o IPU “9”.  Para achar o valor total 
# somar todas as linhas da coluna - valor final -coluna X.

## CATEGORIA PESSOAL
pessoal = trataPessoal("bancos/SISOR/BASE_CATEGORIA_PESSOAL.xlsx", realizarTeste = T)

pessoal[grepl("terceiri", classificacao, ignore.case = T), classificacao:="Ativo"]

pessoal[, nivel := ifelse(grepl("inativo", classificacao, ignore.case = T), 4,
                   ifelse(grepl("pensionista", classificacao, ignore.case = T), 3,
                   ifelse(grepl("terceiri", classificacao, ignore.case = T), 2,
                   ifelse(grepl("ativo", classificacao, ignore.case = T), 1, NA))))]

if(TRUE %in% pessoal[, is.na(nivel)]){
  
  warning(paste("V2_Tabela3_DETALHAMENTO_DA_CATEGORIA_DE_PESSOAL: No banco BASE_CATEGORIA_PESSOAL",
                "Há uma descrição de classificação que não possui um codigo de nivel. Trata-se de ", 
                paste(pessoal[is.na(nivel), unique(classificacao)], collapse=", "),
                ". Corrigir no código, especificando a ordem em que este deve aparecer no relatório.\n"))
  }

pessoal[, classificacao := ifelse(grepl("^pessoal.+", classificacao, ignore.case = TRUE), toupper(classificacao),
                                  paste("PESSOAL", toupper(classificacao)))]




for(codigo_uo in unique(pessoal$cod_uo)[!(unique(pessoal$cod_uo) %in% desconsiderarUO)]){

  #codigo_uo =  1251
  # Calcular o quantitativo de servidores
  
  qtde = pessoal[cod_uo==codigo_uo,]
  
  if(codigo_uo %in% uos_com_info_inativos){
    
    if (codigo_uo %in% uo_militar_com_civis_inativos){
      
      qtde_n1 = qtde[ categoria!="INATIVO CIVIL" , list(total = sum(quantidade, na.rm=T)), by= list(classificacao, nivel)]
      qtde_n2 = qtde[ categoria!="INATIVO CIVIL", list(quantidade = sum(quantidade, na.rm=T)), by= list(classificacao, categoria)]
      
    }else{
    
      qtde_n1 = qtde[ , list(total = sum(quantidade, na.rm=T)), by= list(classificacao, nivel)]
      qtde_n2 = qtde[, list(quantidade = sum(quantidade, na.rm=T)), by= list(classificacao, categoria)]
      
    }
  
    
    } else{ # Desconsiderando inativos nesses casos que serão incluidos no caso do FUNFIP
    
    
    qtde_n1 = qtde[!grepl("INATIVO", classificacao, ignore.case=T), 
                   list(total = sum(quantidade, na.rm=T)), 
                   by=list(classificacao, nivel)] # X
    
    qtde_n2 = qtde[!grepl("INATIVO", classificacao, ignore.case=T), 
                   list(quantidade = sum(quantidade, na.rm=T)), 
                   by=list(classificacao, categoria)] # X
  }
  
  if(TRUE %in% grepl("INATIVO", qtde_n1$classificacao, ignore.case=T)){
    servidores_inativos = 1 # sim
  } else{ # não 
    servidores_inativos = 0  
    }
  
  qtde = mergeDT(qtde_n2, qtde_n1, by.x="classificacao", by.y="classificacao", all=T)
  
  qtde = rbind(qtde, qtde_n1[, list(classificacao = "TOTAL", nivel=99, total = sum(total, na.rm=T))], fill=T)
  
  # Calcular o valor atribuído a PESSOAL ATIVO E PESSOAL INATIVO
  
  uo = qdd[COD_UO==codigo_uo, list(COD_UO, ACAO, NOME_ACAO, valor)]
  
  uo_com_acao_inativa = intersect(codigo_inativos, uo[, unique(ACAO)])
  
  if(length(uo_com_acao_inativa)>0){
    if(servidores_inativos==0){
      
      warning(paste("V2_Tabela3_DETALHAMENTO_DA_CATEGORIA_DE_PESSOAL: Há valores para inativos na UO ", 
                    codigo_uo, ", nas ações ", paste(codigo_inativos, collapse = ", "), 
                    " Mas não há servidores (quantidade) para inativos. Corrigir o banco de pessoal ", 
                    "ou incluir essa UO no conjunto 'uos_com_info_inativos' no código"))
      
      valor_pessoal = data.table(classificacao="PESSOAL ATIVO",
                                 valor = uo[!(ACAO %in% codigo_inativos), sum(valor, na.rm=T)])
      
    } else{ # servidores_inativos = 1
      
      valor_pessoal = data.table(classificacao=c("PESSOAL ATIVO", "PESSOAL INATIVO"),
                                 valor = c(uo[!(ACAO %in% codigo_inativos), sum(valor, na.rm=T)], 
                                           uo[ACAO %in% codigo_inativos, sum(valor, na.rm=T)]))
    }
  
    } else{
    
      if(servidores_inativos==1){
        
        warning(paste("V2_Tabela3_DETALHAMENTO_DA_CATEGORIA_DE_PESSOAL: NÃO Há valores para inativos na UO ", 
                      codigo_uo, "considerando as ações", paste(codigo_inativos, collapse = ", "), 
                      "mas HÁ servidores (quantidade) para inativos. Corrigir o banco de valores em BASE_QDD_FISCAL"))
      }
        valor_pessoal = data.table(classificacao="PESSOAL ATIVO",
                                   valor = uo[!(ACAO %in% codigo_inativos), sum(valor, na.rm=T)])
    }
  
  
  valor_pessoal[, participacao := round((valor / sum(valor))*100,2)]
  
  valor_pessoal_total = valor_pessoal[,lapply(.SD, function(x) sum(x, na.rm=T)), .SDcols=2:3]
  valor_pessoal_total[, classificacao :="TOTAL"]
  
  valor_pessoal = rbind(valor_pessoal, valor_pessoal_total)
  
  qtde = mergeDT(qtde, valor_pessoal, by.x="classificacao", by.y="classificacao", all=T)
  
  qtde[, merge:=NULL]
  
  linhas_na = c()
  
  for(k in 2:nrow(qtde)){
    if(qtde[k, classificacao]==qtde[k-1, classificacao]){
      linhas_na = append(linhas_na, k)
    }
  }
  
  qtde = qtde[order(nivel, categoria)]
  
  if(length(linhas_na)>0){
    qtde = qtde[linhas_na, c("classificacao", "total", "valor", "participacao"):=NA]
  }
  
  nome_uo = qdd[COD_UO==codigo_uo, UO][1]

  
  cod_orgao = qdd[COD_UO==codigo_uo, COD_ORGAO][1]

  
  nome_orgao = qdd[COD_UO==codigo_uo, ORGAO][1]

  
  qtde[, "nivel":= NULL]
  qtde[, c("nome_uo", "nome_orgao"):=NA_character_]
  
  if(is.na(cod_orgao)==F){
    
    qtde$nome_uo[1] = paste0(substr(codigo_uo,1,1), ".", substr(codigo_uo,2,3), ".", 
                             substr(codigo_uo,4,4), " - ", toupper(nome_uo))
    
    qtde$nome_orgao[1] = paste0(substr(cod_orgao,1,1), ".", substr(cod_orgao,2,3), ".", 
                                substr(cod_orgao,4,4), " - ",toupper(nome_orgao))
  } else{
    warning(paste("V2_Tabela3_DETALHAMENTO_DA_CATEGORIA_DE_PESSOAL: Para a UO ", codigo_uo, 
                  " não há nome da UO e nome do orgao em BASE_QDD_FISCAL \n"))
  }
  
  qtde = qtde[,lapply(.SD, formatarNum)]
  
  qtde[, classificacao := correcaoCaracteresEspeciais(classificacao, caracteres)]
  qtde[, categoria := correcaoCaracteresEspeciais(categoria, caracteres)]
  qtde[, nome_uo := correcaoCaracteresEspeciais(nome_uo, caracteres)]
  qtde[, nome_orgao := correcaoCaracteresEspeciais(nome_orgao, caracteres)]
  
  #qtde[grepl("TERCEIRIZADO", classificacao, ignore.case = T), c("classificacao", "total"):=NA]
  
  write.table(qtde, paste0("volume2/data/tabela3/", codigo_uo,".txt"), quote = TRUE, sep = "\t",
            na = "", dec = ",", row.names = FALSE)

}
