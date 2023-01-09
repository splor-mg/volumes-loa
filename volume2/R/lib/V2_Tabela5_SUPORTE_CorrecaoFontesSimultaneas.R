## Correção para fontes que aparecem tanto em Receita Própria quanto em qdd ajustado
# Objetivos: 
# 1. Identificar quais valores de fontes por UO são iguais nos dois bancos e não considerá-las no demonstrativo 2
# 2. Identificar se a solução especifica para a FES é válida (Dedução da função 10)
# 3. Implementar a solução específica da UO 1091 (Não apresentar a discriminação entre Despesa Corrente e Despesa de Capital)


# ====================================================================================================
# O banco "matching_fontes" realiza o merge entre o qdd ajustado para a UO e seu banco de receita
#
# Em ambos os bancos: é o caso que de fato necessita de correção. É o caso que comparamos o valor qdd
# com o valor de receita. Se valor_qdd > valor_rec é necessário deduzir o valor_rec de valor_qdd
#
# Apenas no banco X: A fonte é exclusiva do qdd ajustado. Ou seja, essa fonte deve entrar no
# demonstrativo
#
# Apenas no banco Y: Inesperado. Nesse caso não é necessário correção.
# ===================================================================================================

matching_fontes = mergeDT(valor_qdd_ajust, subtotal1, by.x=c("FONTE") , by.y=c("COD_FONTE"), all=T)
      
if(!"Em ambos os bancos" %in% matching_fontes[, unique(merge)]){
  
  registroLog(paste("HÁ VALORES PARA RECEITA MAS NAO HÁ CORRESPONDÊNCIA COM QDD_AJUSTADO (REPASSE DO TESOURO)",
                    "NESSE CASO, PROCEDER COM A CORREÇÃO QUE NÃO HÁ VALORES DE RECEITA"), "erro")
  
}

matching_fontes[is.na(valor_rec), valor_rec := 0]
matching_fontes[is.na(valor_qdd), valor_qdd := 0]
  
matching_fontes[, diferenca := valor_qdd - valor_rec]

# ==========================================================================================================
# "fontes_s_rec" - fontes sem receita. São as fontes encontradas no qdd e NÃO foram encontradas na receita
# o valor qdd é maior que o valor da receita
#
# "fontes_c_rec" - fontes com receita. São fontes simultaneas no qdd ajustado e banco de receita, e 
#  o valor qdd é maior que o valor da receita
# ==========================================================================================================


fontes_s_rec = matching_fontes[diferenca>0 & valor_rec==0, unique(FONTE)]
fontes_c_rec = matching_fontes[diferenca>0 & valor_rec>0, unique(FONTE)]


if(length(fontes_s_rec)>0){
  
    registroLog(paste("Os valores no qdd_ajustado para as fontes", paste(fontes_s_rec, collapse=", "),
                      "não possuem correspondência no banco de Receita. Montar a Parte 2."), "nota")
  
    r_tesouro_apenas_qdd = qdd_ajustado[COD_UO==codigo_uo & FONTE %in% fontes_s_rec, ]
                                      
    repasse_tesouro = r_tesouro_apenas_qdd[, list(COD_UO, FUNCAO, FONTE, CATEGORIA, valor_qdd=valor)]

  } else{
    
    repasse_tesouro = data.table(COD_UO=NA, FUNCAO=NA, FONTE=NA, CATEGORIA=NA, valor_qdd=NA)
}

if(length(fontes_c_rec)>0){
  
  registroLog(paste("Os valores no qdd_ajustado para as fontes", paste(fontes_c_rec, collapse=", "),
                    "possuem um valor no banco de Receita que precisa ser subtraido de qdd_ajustado.", 
                    "Proceder com uma correção."), "nota")
  
  # ====================================================================================================================
  # "f_c_rec_ord" - fontes com receita dentro do conjunto de recursos ordinários (fonte 10 e 12)
  # Nesse caso proceder com a execução do script R/V2_Tabela5_SUPORTE_CorrecaoFonte10.R com as correções disponiveis
  #
  # "f_c_rec_vinc" - fontes com receita dentro do conjunto de recursos vinculados (diferente de fonte 10 e 12)
  # Situação que não existiu na LOA 2016 (ex. valor_qdd(FONTE 60) > valor_rec(FONTE 60)). Necessário compor uma solução
  # ====================================================================================================================
  
  f_c_rec_ord = fontes_c_rec[fontes_c_rec %in% lista_recurso_ordinario]
  f_c_rec_vinc = fontes_c_rec[!fontes_c_rec %in% lista_recurso_ordinario]
  
  if(length(f_c_rec_ord)>0){
    
    source("volume2/R/lib/V2_Tabela5_SUPORTE_CorrecaoFonte10.R", encoding = "UTF-8")
    
  }
  if(length(f_c_rec_vinc)>0){
    
    registroLog(paste("Problema não mapeado inicialmente. Temos fontes de recurso vinculado com valor_qdd maior ",
                    "que o valor da receita. É o caso das fontes ", paste(f_c_rec_vinc, collapse=", "), 
                    ". Essas Receitas não deveriam ter despesa igual receita?"), "erro")
    
    r_tesouro_vinc = qdd_ajustado[COD_UO==codigo_uo & FONTE %in% f_c_rec_vinc, 
                                  list(valor_qdd = sum(valor, na.rm=T)), 
                                  by=list(COD_UO, FONTE, FUNCAO, CATEGORIA)]
    
    r_tesouro_vinc = merge(r_tesouro_vinc,
                           r_tesouro_vinc[, list(porcent = sum(valor_qdd)), list(CATEGORIA, FONTE)], 
                           by=c("CATEGORIA", "FONTE"))
    
    r_tesouro_vinc[, porcent:= valor_qdd / porcent]
    
    valor_reduzir = matching_fontes[FONTE %in% f_c_rec_vinc, list(DIFF = sum(valor_rec, na.rm=T)), list(FONTE)]
    
    r_tesouro_vinc = merge(r_tesouro_vinc, valor_reduzir, by="FONTE")
    r_tesouro_vinc[, valor_qdd := valor_qdd - porcent*DIFF]
    r_tesouro_vinc[, c("porcent", "DIFF"):=NULL]
  
    }

  } 
    
  if(!exists("r_tesouro_f10")) r_tesouro_f10 = data.table(COD_UO=NA, FUNCAO=NA, FONTE=NA, CATEGORIA=NA, valor_qdd=NA)
  if(!exists("r_tesouro_vinc")) r_tesouro_vinc = data.table(COD_UO=NA, FUNCAO=NA, FONTE=NA, CATEGORIA=NA, valor_qdd=NA)
  
  repasse_tesouro = rbind(repasse_tesouro, r_tesouro_f10[,list(COD_UO, FUNCAO, FONTE, CATEGORIA, valor_qdd)])
  repasse_tesouro = rbind(repasse_tesouro,r_tesouro_vinc)
  
  repasse_tesouro = repasse_tesouro[!is.na(COD_UO),] 
  
  # ====================================================================================================================
  # No caso que não há demonstrativo 2 (ex. 1541). Esse script gera um repasse_tesouro com zero linhas
  # Para esses casos length(fontes_s_rec) = length(fontes_c_rec) = 0 o que gera um repasse_tesouro com 2 linhas NA
  # ====================================================================================================================
  