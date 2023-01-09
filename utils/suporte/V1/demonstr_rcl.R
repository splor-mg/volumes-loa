
demonstr_rcl_classificacao_antiga = function(rec){
  
  base = copy(rec)
  
  # ================================================================
  # Monta o demonstrativo de receita corrente líquida considerando
  # a classificação antiga (10 dígitos) da RECEITA
  
  base[nat(RECEITA_COD,11) ,rcl_n2:= "2.2.Receitas Tributárias" ]
  base[nat(RECEITA_COD,1113) ,rcl_n3:= "3.3.ICMS" ]
  base[nat(RECEITA_COD,111205) ,rcl_n3:= "4.3.IPVA" ]
  base[nat(RECEITA_COD,111207) ,rcl_n3:= "5.3.ITCD" ]
  base[nat(RECEITA_COD,111204) ,rcl_n3:= "6.3.IRRF" ]
  base[nat(RECEITA_COD,112) ,rcl_n3:= "7.3.Outras Receitas Tributárias" ]
  base[nat(RECEITA_COD,12) ,rcl_n2:= "8.2.Receitas de Contribuições" ]
  base[nat(RECEITA_COD,13) ,rcl_n2:= "9.2.Receita Patrimonial" ]
  base[nat(RECEITA_COD,14) ,rcl_n2:= "10.2.Receita Agropecuária" ]
  base[nat(RECEITA_COD,15) ,rcl_n2:= "11.2.Receita Industrial" ]
  base[nat(RECEITA_COD,16) ,rcl_n2:= "12.2.Receita de Serviços" ]
  base[nat(RECEITA_COD,17) ,rcl_n2:= "13.2.Receita de Transferências Correntes" ]
  base[nat(RECEITA_COD,1721010101, 1721010102) ,rcl_n3:= "14.3.Cota-Parte do FPE" ]
  base[nat(RECEITA_COD,1721360100, 1721360200) ,rcl_n3:= "15.3.Transferências da LC 87/1996" ]
  base[nat(RECEITA_COD,17210112) ,rcl_n3:= "16.3.Transferências da LC 61/1989" ]
  base[nat(RECEITA_COD,1724) ,rcl_n3:= "17.3.Transferências do FUNDEB" ]
  base[nat(RECEITA_COD, 17, -1721010101, -1721010102, -1721360100, 
          -1721360200, -17210112, -1724),  rcl_n3:= "18.3.Outras Transferências Correntes" ]
  base[nat(RECEITA_COD,19) ,rcl_n2:= "19.2.Outras Receitas Correntes" ]
  
  base[nat(RECEITA_COD, 1721011302) | FONTE_COD ==20 ,rcl_n2_1:= "21.2.Transferências Constitucionais e Legais" ]
  
  # ========= Contrib. para o Plano de Previdência do Servidor ==============================================
  base[nat(RECEITA_COD, 12102907, -1210290702, 
          12102909, 12102911, 121050), rcl_n2_2:= "22.2.Contrib. para o Plano de Previdência do Servidor" ]
  
  base[nat(RECEITA_COD, 1210290801, 1210291001), rcl_n2_2:= "23.2.Contrib. para o Custeio das Pensões Militares" ]
  base[nat(RECEITA_COD, 1922100000), rcl_n2_2:= "24.2.Compensação Financ. entre Regimes Previdência" ]
  base[nat(RECEITA_COD, 9), rcl_n2:= "25.2.Dedução da Receita Corrente – Formação do FUNDEB e Cessão de Direitos Creditórios" ]
  
  base[nat(RECEITA_COD,1) ,rcl_n1:= "1.1.RECEITAS CORRENTES ( I )" ]
  
  base[between(as.numeric(gsub("^(\\d+).+", "\\1",rcl_n2)), 21,25) | !is.na(rcl_n2_1) | !is.na(rcl_n2_2), 
      rcl_n1d:= "20.1.DEDUÇÕES ( II )" ]
  
  base_n1 = base[!is.na(rcl_n1), .(VL_LOA_REC = sum(abs(VL_LOA_REC)), nvl=1), by=.(espec = rcl_n1)]
  base_n1d = base[!is.na(rcl_n1d), .(VL_LOA_REC = sum(abs(VL_LOA_REC)), nvl=1), by=.(espec = rcl_n1d)]
  
  base_n1rcl = data.table(espec = "30.1.RECEITA CORRENTE LÍQUIDA ( I - II )",  
                         VL_LOA_REC = base_n1$VL_LOA_REC - base_n1d$VL_LOA_REC, 
                         nvl=1)
  
  base_n2 = base[!is.na(rcl_n2), .(VL_LOA_REC = sum(abs(VL_LOA_REC)), nvl=2), by=.(espec = rcl_n2)]
  
  base_n2 = rbind(base_n2, base[!is.na(rcl_n2_1), .(VL_LOA_REC = sum(abs(VL_LOA_REC)), nvl=2), by=.(espec = rcl_n2_1)])
  base_n2 = rbind(base_n2, base[!is.na(rcl_n2_2), .(VL_LOA_REC = sum(abs(VL_LOA_REC)), nvl=2), by=.(espec = rcl_n2_2)])
  
  base_n3 = base[!is.na(rcl_n3), .(VL_LOA_REC = sum(abs(VL_LOA_REC)), nvl=3), by=.(espec = rcl_n3)]
  rcl = rbindlist(list(base_n1, base_n1d, base_n1rcl, base_n2, base_n3))
  
  rcl[, ordem:=as.numeric(gsub("(\\d+)\\.(.+)", "\\1", espec))]
  rcl[, nvl := gsub("\\d+\\.(\\d+)\\..+", "\\1", espec)]
  
  rcl[, espec:= gsub("\\d+\\.\\d+\\.(.+)", "\\1", espec)]
  
  rcl = rcl[order(ordem)]
  
  return(rcl)
  
}

demonstr_rcl = function(rec){
  
  # ================================================================
  # Monta o demonstrativo de receita corrente líquida considerando
  # a nova classificação (13 dígitos) da RECEITA
  
  base = copy(rec)
  
  if(prod(unique(nchar(base[, RECEITA_COD])) == 13) != 1){
    stop("demonstr_rcl: Algum código de RECEITA_COD não possui 13 dígitos.")
  }

  base[nat(RECEITA_COD, 11), n1 := "1.1.Impostos, Taxas e Contribuições de Melhoria"]

  base[is_impostos_principal(base) & nat(RECEITA_COD,1), n2 := "2.2.Principal"]

  base[is_icms_principal(base) & nat(RECEITA_COD,1), n3 := "3.3.ICMS"]
  base[is_ipva_principal(base) & nat(RECEITA_COD,1), n3 := "4.3.IPVA"]
  base[is_itcd_principal(base) & nat(RECEITA_COD,1), n3 := "5.3.ITCD"]
  base[is_irrf_principal(base) & nat(RECEITA_COD,1), n3 := "6.3.IRRF"]
  base[is_taxas_principal(base) & nat(RECEITA_COD,1), n3 := "7.3.Taxas"]

  base[is_impostos_acessorias(base) & nat(RECEITA_COD,1), n2 := "8.2.Acessórias [Dívida Ativa, Multas e Juros]"]

  base[is_icms_acessorias(base) & nat(RECEITA_COD,1), n3 := "9.3.ICMS"]
  base[is_ipva_acessorias(base) & nat(RECEITA_COD,1), n3 := "10.3.IPVA"]
  base[is_itcd_acessorias(base) & nat(RECEITA_COD,1), n3 := "11.3.ITCD"]
  base[is_taxas_acessorias(base) & nat(RECEITA_COD,1), n3 := "12.3.Taxas"]


  base[nat(RECEITA_COD,12), n2:= "13.1.Receitas de Contribuições" ]
  base[nat(RECEITA_COD,13), n2:= "14.1.Receita Patrimonial" ]
  
  #adicionar Rendimentos de aplicação financeira e Outras rec patrimoniais na LOA 2023
  base[is_aplic_fin(base) & nat(RECEITA_COD,1), n3:= "15.2.Rendimentos de Aplicação Financeira" ]
  base[!is_aplic_fin(base) & nat(RECEITA_COD,13), n3:= "16.2.Outras Receitas Patrimoniais" ] 

  
  # estrutura da LOA 2022 comentada  
  # base[nat(RECEITA_COD,14), n2:= "15.1.Receita Agropecuária" ]
  # base[nat(RECEITA_COD,15), n2:= "16.1.Receita Industrial" ]
  # base[nat(RECEITA_COD,16), n2:= "17.1.Receita de Serviços" ]
  
  
  base[nat(RECEITA_COD,14), n2:= "17.1.Receita Agropecuária" ]
  base[nat(RECEITA_COD,15), n2:= "18.1.Receita Industrial" ]
  base[nat(RECEITA_COD,16), n2:= "19.1.Receita de Serviços" ]

  # estrutura da LOA 2022 comentada  
  # base[nat(RECEITA_COD, 17), n2:= "18.1.Receita de Transferências Correntes" ]
  # base[nat(RECEITA_COD, 1718011101001, 1718011101003), n3:= "19.2.Cota-Parte do FPE" ]
  # base[nat(RECEITA_COD, 1718061101001, 1718061101003), n3:= "20.2.Transferências da LC 87/1996" ]
  # base[nat(RECEITA_COD, 1718991199003), n3:= "21.2.Transferências da LC 61/1989" ]
  # base[nat(RECEITA_COD, 1758), n3:= "22.2.Transferências do FUNDEB" ]
  # base[nat(RECEITA_COD, 17, -1718011101001, -1718011101003, -1718061101001, -1718061101003,
  #         1718016101001, 1718016101002, 1718016101003, -1758),   n3:= "23.2.Outras Transferências Correntes" ]
  # 
  # 
  # base[nat(RECEITA_COD,19), n2:= "24.1.Outras Receitas Correntes" ]
  # 
  # base[nat(RECEITA_COD, 1718017101002) | FONTE_COD ==20 , n2_1:= "26.1.Transferências Constitucionais e Legais" ]
  

  
  base[nat(RECEITA_COD, 17), n2:= "20.1.Receita de Transferências Correntes" ]
  base[is_fpe_principal(base) & nat(RECEITA_COD,1), n3:= "21.2.Cota-Parte do FPE" ]
  base[is_lei_kandir_principal(base) & nat(RECEITA_COD,1), n3:= "22.2.Transferências da LC 87/1996" ]

  base[is_ipi_principal(base), n3:= "23.2.Transferências da LC 61/1989" ] 
  
  base[is_volta_fundeb(base), n3:= "24.2.Transferências do FUNDEB" ]
  base[nat(RECEITA_COD, 17) & is.na(n3),   n3:= "25.2.Outras Transferências Correntes" ]


  base[nat(RECEITA_COD,19), n2:= "26.1.Outras Receitas Correntes" ]
  
#===========================================================================================================
  # Header Deduções (II) virá aqui posteriormente
#===========================================================================================================
  
  base[is_transf_const_mun_rec(base) & nat(RECEITA_COD, 9) , n2_1:= "28.1.Transferências Constitucionais e Legais" ]
  
  
  
  
# ========= Contrib. para o Plano de Previdência do Servidor ==============================================

  base[nat(RECEITA_COD, 1215021, 1215011, 1215012, 1215013,
           1219991103052, 1219991203052, 1219991303052, 1219991403052,
           1219991104, 1219991204, 1219991304, 1219991404,
           1219991199, 1219991299, 1219991399, 1219991499,
           1215521101, 1215521201, 1215521301, 1215521401,
           -1215011199002),   n2_2:= "29.1.Contrib. para o Plano de Previdência do Servidor" ] #1210991199000, #pendente

# ==========================================================================================================

  base[FONTE_COD == 78, n2_2:= "30.1.Contrib. para o Custeio das Pensões Militares" ]
  base[FONTE_COD == 44, n2_2:= "31.1.Compensação Financ. entre Regimes Previdência" ]
  
  # Adicionado para LOA 2023
  base[nat(RECEITA_COD, 132104) & UO_COD %in% c(4711, 2361), n2_2:= "32.1.Rendimentos de Aplicações de Recursos Previdenciários" ] #FUNCAO ERRADA
  
  
  # estrutura da LOA 2022 comentada 
  # base[nat(RECEITA_COD, 9, -999) , n2_2:= "30.1.Dedução da Receita Corrente – Formação do FUNDEB e Cessão de Direitos Creditórios" ]
  # base[nat(RECEITA_COD, 9, -999) , VL_LOA_REC := -1*VL_LOA_REC]
  # 
  # 
  # base[nat(RECEITA_COD,1) , n0:= "0.0.RECEITAS CORRENTES ( I )" ]
  # base[!is.na(n2_1) | !is.na(n2_2), n0d:= "25.0.DEDUÇÕES ( II )" ]
  # 
  # 
  # base1 = data.table(espec = "31.0.RECEITA CORRENTE LÍQUIDA ( I - II )",  
  #                  VL = (base[n0=="0.0.RECEITAS CORRENTES ( I )", sum(VL_LOA_REC)] - 
  #                                  base[n0d== "25.0.DEDUÇÕES ( II )", sum(VL_LOA_REC)]))

  

  base[nat(RECEITA_COD, 9) & is.na(n2_1) , n2_2:= "33.1.Dedução da Receita Corrente – Formação do FUNDEB" ]
  base[nat(RECEITA_COD, 9) , VL_LOA_REC := -1*VL_LOA_REC]


  base[nat(RECEITA_COD,1) , n0:= "0.0.RECEITAS CORRENTES ( I )" ]
  base[!is.na(n2_1) | !is.na(n2_2), n0d:= "27.0.DEDUÇÕES ( II )" ]

  
  
  
  # incluido mudanças de receita LOA 2023
  ## FUNCAO ERRADA!!!!
  base[is_rcl(base) & !is_rcl_divida(base) , n2_2:= "35.0.(-) Transf. obrig. da União relativas às emendas individuais (art. 166-A, § 1º, da CF) (IV)" ]

  base[is_rcl_divida(base) & !is_rcl_pessoal(base), n2_2:= "37.0.(-) Transf. obrig. da União relativas às emendas de bancada (art. 166, § 16, da CF) (VI)" ]

 
  base1 = data.table(espec = "34.0.RECEITA CORRENTE LÍQUIDA ( III ) = ( I - II )",
                   VL = (base[n0=="0.0.RECEITAS CORRENTES ( I )", sum(VL_LOA_REC)] -
                                   base[n0d== "27.0.DEDUÇÕES ( II )", sum(VL_LOA_REC)]))
  
  
  # incluido mudanças de receita LOA 2023
  base2 = data.table(espec = "36.0.RCL AJUSTADA PARA CÁLCULO DOS LIMITES DE ENDIVIDAMENTO (V) = ( III - IV )",
                     VL = (base1[espec=="34.0.RECEITA CORRENTE LÍQUIDA ( III ) = ( I - II )", sum(VL)] -
                             base[n2_2== "35.0.(-) Transf. obrig. da União relativas às emendas individuais (art. 166-A, § 1º, da CF) (IV)", sum(VL_LOA_REC)]))

  base3 = data.table(espec = "38.0.RCL AJUSTADA PARA CÁLCULO DOS DE DESPESA DE PESSOAL (VII) = ( V - VI )",
                     VL = (base2[espec=="36.0.RCL AJUSTADA PARA CÁLCULO DOS LIMITES DE ENDIVIDAMENTO (V) = ( III - IV )", sum(VL)] -
                             base[n2_2== "37.0.(-) Transf. obrig. da União relativas às emendas de bancada (art. 166, § 16, da CF) (VI)", sum(VL_LOA_REC)]))
  
  
  
  
  rcl = rbindlist(list(
                      base[n0=="0.0.RECEITAS CORRENTES ( I )", list(VL = sum(VL_LOA_REC)), list(espec = n0)],
                      base[n0d== "27.0.DEDUÇÕES ( II )", list(VL = sum(VL_LOA_REC)), list(espec = n0d)],
                      base[!is.na(n1), list(VL = sum(VL_LOA_REC)), list(espec = n1)],
                      base[!is.na(n2), list(VL = sum(VL_LOA_REC)), list(espec = n2)],
                      base[!is.na(n3), list(VL = sum(VL_LOA_REC)), list(espec = n3)],
                      base[!is.na(n2_1), list(VL = sum(VL_LOA_REC)), list(espec = n2_1)],
                      base[!is.na(n2_2), list(VL = sum(VL_LOA_REC)), list(espec = n2_2)],
                      base1,
                      base2, 
                      base3 
                      )
                  )

  rcl[, ordem:=as.numeric(gsub("(\\d+)\\.(.+)", "\\1", espec))]
  rcl[, nvl := gsub("\\d+\\.(\\d+)\\..+", "\\1", espec)]
  
  rcl[, espec:= gsub("\\d+\\.\\d+\\.(.+)", "\\1", espec)]
  rcl = rcl[order(ordem)]
  
  setnames(rcl, "VL", "VL_LOA_REC")

  return(rcl)
  
}
