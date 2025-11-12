demonstr_receitas_previdenciarias = function(loa_rec){

base = copy(loa_rec)


# Receita de Contribuições dos Segurados
  

  # retirada a classificação corresponde a "Outras Contribuições"
  base[is_contrib_prev_serv_civil_ativo(base), 
                        c("nvl4", "lvl4"):= list("Ativo Civil", 1111)]
     
  base[is_contrib_prev_serv_civil_inativo(base), 
                        c("nvl4", "lvl4"):= list("Inativo Civil", 1112)]

  base[is_contrib_prev_serv_civil_pens(base), 
                        c("nvl4", "lvl4"):= list("Pensionista Civil", 1113)]

     base[lvl4 %in% 1111:1113, 
               c("nvl3", "lvl3"):= list("Civil", 1110)]
  

  base[is_contrib_prev_serv_militar_ativo(base), 
       c("nvl4", "lvl4"):= list("Ativo Militar", 1121)]
  
  base[is_contrib_prev_serv_militar_inativo(base), 
       c("nvl4", "lvl4"):= list("Inativo Militar", 1122)]
  
  base[is_contrib_prev_serv_militar_pens(base), 
       c("nvl4", "lvl4"):= list("Pensionista Militar", 1123)]
    
      
     base[lvl4 %in% 1121:1123, 
                 c("nvl3", "lvl3"):= list("Militar", 1120)]

     base[lvl3 %in% c(1110, 1120), 
                 c("nvl2", "lvl2"):= list("Receita de Contribuições dos Segurados", 1100)]



# Receita Patrimonial
  
  base[is_rec_prev_imobiliaria(base), 
       c("nvl3", "lvl3"):= list("Receitas Imobiliárias",1310)]

  base[is_rec_prev_valores_mobiliarios(base), 
                          c("nvl3", "lvl3"):= list("Receitas de Valores Mobiliários", 1320)]

     
     base[lvl3 %in% c(1310, 1320), 
                 c("nvl2", "lvl2"):= list("Receita Patrimonial", 1300)]



# Receita de Serviços
  
  base[is_rec_prev_servicos(base), 
       c("nvl2", "lvl2"):= list("Receita de Serviços", 1400)]



# Outras Receitas Correntes
  
  base[is_rec_prev_compensacao_regimes(base), 
       c("nvl3", "lvl3"):= list("Compensação Previdenciária do RGPS para o RPPS", 1510)]

  
  base[is_rec_prev_demais_receitas_correntes(base), 
       c("nvl3", "lvl3"):= list("Demais Receitas Correntes", 1520)]

       base[lvl3 %in% c(1510, 1520), 
                      c("nvl2", "lvl2"):= list("Outras Receitas Correntes", 1500)]



# Receitas Correntes
                                                                                                         
  base[nvl2 %in% c("Outras Receitas Correntes", 
                   "Receita de Serviços", 
                   "Receita Patrimonial", 
                   "Receita de Contribuições dos Segurados"), 
                 c("nvl1", "lvl1"):= list("RECEITAS CORRENTES", 1000)] 


# RECEITAS DE CAPITAL
    
# Alienação de Bens, Direitos e Ativos
  
  base[is_rec_prev_alienacao(base), 
                      c("nvl2", "lvl2"):= list("Alienação de Bens, Direitos e Ativos", 2100)]



# Amortização de Empréstimos
  

  base[is_rec_prev_amortizacao(base), 
                      c("nvl2", "lvl2"):= list("Amortização de Empréstimos", 2200)]


       base[nvl2 %in% c("Alienação de Bens, Direitos e Ativos", 
                        "Amortização de Empréstimos"), 
                      c("nvl1", "lvl1"):= list("RECEITAS DE CAPITAL", 2000)] 



# RECEITAS PREVIDENCIÁRIAS - RPPS (INTRA-ORÇAMENTÁRIAS)
  



# Patronal do Ativo Civil

  base[nat(receita_cod, 72150211), c("nvl4", "lvl4"):= list("Ativo Civil", 1611)]

# Patronal do Ativo Civil no IPSM

  #Considerando o que a receita 7210991103000 (contribuição do inativo do IPSM) está entrando como receita patronal INATIVO, foi acrescida a respectiva patronal do ativo.
  #Contudo, após validação da Rita com o IPSM, foi decidido que essa receita não seria considerada como receita previdenciária, mas sim uma receita de assistência à saúde.
  #base[nat(RECEITA_COD, 7219991103051),
  #    c("nvl4", "lvl4"):= list("Ativo Civil", 1211)]
  
# Patronal do Inativo Civil no IPSM
  

     
  base[nat(receita_cod, 7219991103052),
       c("nvl4", "lvl4"):= list("Inativo Civil", 1612)]
  
     #parece ser aqui o motivo de nao estar aparecendo ativo civil no nivel  Receita de Contribuições Patronais (AML 25/01/2020)
     base[lvl4 %in% c(1611, 1612), 
            c("nvl3", "lvl3"):= list("Civil", 1610)]
  
# Patronal do militar

     base[nat(receita_cod, 7219991103055, 7219991110051, -7215531101000), 
            c("nvl4", "lvl4"):= list("Ativo Militar", 1621)]
  
     base[nat(receita_cod, 7219991103056, 7219991110052, -7215532101000), 
            c("nvl4", "lvl4"):= list("Inativo Militar", 1622)]
  
     base[lvl4 %in% c(1621, 1622), 
           c("nvl3", "lvl3"):= list("Militar", 1620)]
  

#Patronal em Regime de Parcelamento de Débitos

  base[is_rec_prev_parcel_debitos(base),
       c("nvl3", "lvl3"):= list("Em Regime de Parcelamento de Débitos", 1630)]
  
      base[lvl3 %in% c(1610, 1620, 1630),
            c("nvl2", "lvl2"):= list("Receita de Contribuições Patronais", 1600)]
  
  
  base[nvl2 %in% c("Outras Receitas Correntes", 
                   "Receita de Serviços", 
                   "Receita Patrimonial", 
                   "Receita de Contribuições dos Segurados",
                   "Receita de Contribuições Patronais"), 
       c("nvl1", "lvl1"):= list("RECEITAS CORRENTES", 1000)] 
  
  
  base[nvl2 %in% c("Receita de Contribuições Patronais"), 
       c("nvl1", "lvl1"):= list("RECEITAS INTRA-ORÇAMENTÁRIAS", 1600)] 
  
  
  
  
  demonstr_rec_prev = rbindlist(list(base[!is.na(nvl1), list(nvl=1, VL_LOA = sum(vl_loa_rec)),
                                          by=list(espec=nvl1, ordem = lvl1)],
                                     base[!is.na(nvl2), list(nvl=2, VL_LOA = sum(vl_loa_rec)), 
                                          by=list(espec=nvl2, ordem = lvl2)],
                                     base[!is.na(nvl3), list(nvl=3, VL_LOA = sum(vl_loa_rec)), 
                                          by=list(espec=nvl3, ordem = lvl3)],
                                     base[!is.na(nvl4), list(nvl=4, VL_LOA = sum(vl_loa_rec)), 
                                          by=list(espec=nvl4, ordem = lvl4)]
                                    )
                                )
  
  demonstr_rec_prev = demonstr_rec_prev[order(ordem)]
  demonstr_rec_prev[, ordem:=NULL]
  
  return(demonstr_rec_prev)

}
