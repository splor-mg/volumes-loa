demonstr_receitas_previdenciarias = function(loa_rec){

base = copy(loa_rec)


# Receita de Contribuições dos Segurados
  
     #  base[nat(RECEITA_COD, 1210042101000, 1210042199002, 1210042199001, 1210042102000, 1210042104000, 
     #                        1210042105000, 1210042106000, 1210042103000, 1210042107000, 1210991199000), 
     #                        c("nvl4", "lvl4"):= list("Ativo Civil", 1111)]
     
     #  base[nat(RECEITA_COD, 1210043101000, 1210043102000, 1210043104000, 1210043105000, 
     #                        1210043106000, 1210043103000, 1210043107000), 
     #                        c("nvl4", "lvl4"):= list("Inativo Civil", 1112)]

     #  base[nat(RECEITA_COD, 1210044101000, 1210044102000, 1210044104000, 
     #                        1210044105000, 1210044106000, 1210044103000), 
     #                        c("nvl4", "lvl4"):= list("Pensionista Civil", 1113)]
  
  # retirada a classificação corresponde a "Outras Contribuições"
  base[is_contrib_prev_serv_civil_ativo(base), 
                        c("nvl4", "lvl4"):= list("Ativo Civil", 1111)]
     
  base[is_contrib_prev_serv_civil_inativo(base), 
                        c("nvl4", "lvl4"):= list("Inativo Civil", 1112)]

  base[is_contrib_prev_serv_civil_pens(base), 
                        c("nvl4", "lvl4"):= list("Pensionista Civil", 1113)]

     base[lvl4 %in% 1111:1113, 
               c("nvl3", "lvl3"):= list("Civil", 1110)]
  


     #  base[nat(RECEITA_COD, 1218022102000, 1218022101000, 1218022104000), 
     #       c("nvl4", "lvl4"):= list("Ativo Militar", 1121)]
  
     #  base[nat(RECEITA_COD, 1218023102000, 1218021101001, 1218023104000), 
     #       c("nvl4", "lvl4"):= list("Inativo Militar", 1122)]
  
     #  base[nat(RECEITA_COD, 1218024104000), 
     #       c("nvl4", "lvl4"):= list("Pensionista Militar", 1123)]
  
  
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
  
     #  base[UO_COD== 2121 & nat(RECEITA_COD, 131), 
     #       c("nvl3", "lvl3"):= list("Receitas Imobiliárias",1310)]

     #  base[UO_COD== 4711 & RECEITA_COD %in% c(1321001101000, 1321004101001, 1321004101002, 
     #                                          1390001401000,  1390001301000), 
     #                          c("nvl3", "lvl3"):= list("Receitas de Valores Mobiliários", 1320)]

     #  base[UO_COD== 2121 & RECEITA_COD %in% c(1322001102000, 1329001102000, 1321001101000), 
     #                          c("nvl3", "lvl3"):= list("Receitas de Valores Mobiliários",1320)]

     #  base[RECEITA_COD == 9321004101002, c("nvl3", "lvl3"):= list("Receitas de Valores Mobiliários",1320)]

     #  base[lvl3 %in% c(1310, 1320), 
     #                 c("nvl2", "lvl2"):= list("Receita Patrimonial", 1300)]


  base[is_rec_prev_imobiliaria(base), 
       c("nvl3", "lvl3"):= list("Receitas Imobiliárias",1310)]

  base[is_rec_prev_valores_mobiliarios(base), 
                          c("nvl3", "lvl3"):= list("Receitas de Valores Mobiliários", 1320)]

     
     base[lvl3 %in% c(1310, 1320), 
                 c("nvl2", "lvl2"):= list("Receita Patrimonial", 1300)]



# Receita de Serviços
  
     #  base[UO_COD== 2121 & RECEITA_COD %in% c(1640011101000, 1690991101000), 
     #                   c("nvl2", "lvl2"):= list("Receita de Serviços", 1400)]

  base[is_rec_prev_servicos(base), 
       c("nvl2", "lvl2"):= list("Receita de Serviços", 1400)]



# Outras Receitas Correntes
  
     #  base[UO_COD== 4711 & RECEITA_COD == 1990031101000, 
     #       c("nvl3", "lvl3"):= list("Compensação Previdenciária do RGPS para o RPPS", 1510)]

  
     #  base[UO_COD==4711 & RECEITA_COD %in% c(1922991199000, 1990991101000, 1990991101000), 
     #       c("nvl3", "lvl3"):= list("Demais Receitas Correntes", 1520)]

     #  base[UO_COD==2121 & RECEITA_COD %in% c(1990991199000),
     #       c("nvl3", "lvl3"):= list("Demais Receitas Correntes", 1520)]

     #  base[lvl3 %in% c(1510, 1520), 
     #                 c("nvl2", "lvl2"):= list("Outras Receitas Correntes", 1500)]


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
  
     # base[UO_COD==2121 & RECEITA_COD==2213001199000, 
     #                    c("nvl2", "lvl2"):= list("Alienação de Bens, Direitos e Ativos", 2100)]

  base[is_rec_prev_alienacao(base), 
                      c("nvl2", "lvl2"):= list("Alienação de Bens, Direitos e Ativos", 2100)]



# Amortização de Empréstimos
  
     # base[UO_COD==2121 & RECEITA_COD==2300061101000, 
     #                c("nvl2", "lvl2"):= list("Amortização de Empréstimos", 2200)]

  base[is_rec_prev_amortizacao(base), 
                      c("nvl2", "lvl2"):= list("Amortização de Empréstimos", 2200)]


       base[nvl2 %in% c("Alienação de Bens, Direitos e Ativos", 
                        "Amortização de Empréstimos"), 
                      c("nvl1", "lvl1"):= list("RECEITAS DE CAPITAL", 2000)] 



# RECEITAS PREVIDENCIÁRIAS - RPPS (INTRA-ORÇAMENTÁRIAS)
  
      # base[RECEITA_COD %in% c(7210041101000, 7210041102000, 7210041104000, 7210041105000, 
      #                         7210041106000, 7210041103000, 7210041107000, 7218021101002, 
      #                         7218021101001, 7210991103000, 7218025101002, 7218025101001, 7210991206000), 
      #    c("nvl1", "lvl1"):= list("RECEITAS PREVIDENCIÁRIAS - RPPS (INTRA-ORÇAMENTÁRIAS)", 3000)]
      
      # Para o caso das intraorçamentárias fazem referencia a Patronal
  
  


# Patronal do Ativo Civil

  #base[nat(RECEITA_COD, 72100411), c("nvl4", "lvl4"):= list("Ativo Civil", 1211)]

  base[nat(RECEITA_COD, 72150211), c("nvl4", "lvl4"):= list("Ativo Civil", 1211)]

# Patronal do Ativo Civil no IPSM

  #Considerando o que a receita 7210991103000 (contribuição do inativo do IPSM) está entrando como receita patronal INATIVO, foi acrescida a respectiva patronal do ativo.
  #Contudo, após validação da Rita com o IPSM, foi decidido que essa receita não seria considerada como receita previdenciária, mas sim uma receita de assistência à saúde.
  #base[nat(RECEITA_COD, 7219991103051),
  #    c("nvl4", "lvl4"):= list("Ativo Civil", 1211)]
  
# Patronal do Inativo Civil no IPSM
  
     # base[nat(RECEITA_COD, 7210991103000), 
     #     c("nvl4", "lvl4"):= list("Inativo Civil", 1212)]
     
  base[nat(RECEITA_COD, 7219991103052),
       c("nvl4", "lvl4"):= list("Inativo Civil", 1212)]
  
     #parece ser aqui o motivo de nao estar aparecendo ativo civil no nivel  Receita de Contribuições Patronais (AML 25/01/2020)
     base[lvl4 %in% c(1211, 1212), 
            c("nvl3", "lvl3"):= list("Civil", 1210)]
  
# Patronal do militar
     #  base[nat(RECEITA_COD, 7218021101002, 7218021101001), 
     #       c("nvl4", "lvl4"):= list("Ativo Militar", 1221)]

     base[nat(RECEITA_COD, 72155311, -7215531101000), 
            c("nvl4", "lvl4"):= list("Ativo Militar", 1221)]
  
     #  base[nat(RECEITA_COD, 7218025101002, 7218025101001), 
     #       c("nvl4", "lvl4"):= list("Inativo Militar", 1222)]

     base[nat(RECEITA_COD, 72155321, -7215532101000), 
            c("nvl4", "lvl4"):= list("Inativo Militar", 1222)]
  
     base[lvl4 %in% c(1221, 1222), 
           c("nvl3", "lvl3"):= list("Militar", 1220)]
  

#Patronal em Regime de Parcelamento de Débitos

     #  base[nat(RECEITA_COD, 7210991206000),
     #       c("nvl3", "lvl3"):= list("Em Regime de Parcelamento de Débitos", 1230)]

  base[is_rec_prev_parcel_debitos(base),
       c("nvl3", "lvl3"):= list("Em Regime de Parcelamento de Débitos", 1230)]
  
      base[lvl3 %in% c(1210, 1220, 1230),
            c("nvl2", "lvl2"):= list("Receita de Contribuições Patronais", 1200)]
  
  
  base[nvl2 %in% c("Outras Receitas Correntes", 
                   "Receita de Serviços", 
                   "Receita Patrimonial", 
                   "Receita de Contribuições dos Segurados",
                   "Receita de Contribuições Patronais"), 
       c("nvl1", "lvl1"):= list("RECEITAS CORRENTES", 1000)] 
  
  
  demonstr_rec_prev = rbindlist(list(base[!is.na(nvl1), list(nvl=1, VL_LOA = sum(VL_LOA_REC)),
                                          by=list(espec=nvl1, ordem = lvl1)],
                                     base[!is.na(nvl2), list(nvl=2, VL_LOA = sum(VL_LOA_REC)), 
                                          by=list(espec=nvl2, ordem = lvl2)],
                                     base[!is.na(nvl3), list(nvl=3, VL_LOA = sum(VL_LOA_REC)), 
                                          by=list(espec=nvl3, ordem = lvl3)],
                                     base[!is.na(nvl4), list(nvl=4, VL_LOA = sum(VL_LOA_REC)), 
                                          by=list(espec=nvl4, ordem = lvl4)]
                                    )
                                )
  
  demonstr_rec_prev = demonstr_rec_prev[order(ordem)]
  demonstr_rec_prev[, ordem:=NULL]
  
  return(demonstr_rec_prev)

}
