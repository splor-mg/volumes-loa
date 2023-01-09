suppressMessages(require(relatorios)); 
suppressMessages(require(data.table))
options(scipen = 999)

# =====================================================================
# pareamento_rec: Analisa quais receitas na nova codificação
# correspondem as receitas anteriores nos agregados de receita
# que montam os demonstrativos da LOA, e no pacote relatorios
# =====================================================================

pareamento_rec = function(prefixoRECEITA_COD, prefixoRECEITA_COD_2){
  
  # =======================================================
  # Repassa o prefixo de RECEITA_COD e os prefixos de RECEITA_COD_2 apresentando:
  # 1. Para determinado prefixo de RECEITA_COD quais são os valores de RECEITA_COD_2
  # 2. Se o prefixo de RECEITA_COD_2 abrange todos os códigos apresentados em 1
  # 3. Se não, mostra quais códigos ainda não foram considerados bem como os 
  #    considerados a mais
  # =======================================================
  
  vetor1 = sort(receita[nat(RECEITA_COD, prefixoRECEITA_COD), unique(RECEITA_COD_2)])
  vetor2 = sort(receita[nat(RECEITA_COD_2, prefixoRECEITA_COD_2), unique(RECEITA_COD_2)])
  
  cat("prefixo RECEITA_COD equivale aos códigos RECEITA_COD_2\n")
  print(vetor1)
  #cat("prefixoRECEITA_COD_2 equivale aos códigos RECEITA_COD_2\n")
  #print(vetor2)
  cat("Os prefixos são iguais?\n")
  
  if(all.equal(vetor1, vetor2)[1]==T){ cat("TRUE")
  } else{
    cat("FALSE\n")
    cat("Faltam quais códigos?\n")
    print(setdiff(vetor1, vetor2))
    cat("\nTem quais códigos a mais?\n")
    print(setdiff(vetor2, vetor1))
  }
}


# =====================================================================
# Identifica as novas receitas para cada função utilzada em relatórios
# =====================================================================

receita_de_para = function(caminho){
  
  receita = data.table(readxl::read_excel(caminho, sheet=1))
  # index = which(grepl("NOVA|ANTIGA", receita[1, ]))
  # receita = receita[, index, with=F]
  # names(receita) = as.character(receita[1, ])
  # receita= receita[2:nrow(receita), ]
  # setnames(receita, c("NOVA CLASSIFICAÇÃO MG", "NOVA DESCRIÇÃO MG", "CLASSIFICAÇÃO ANTIGA MG"),
  #                   c("RECEITA_COD_2", "RECEITA_DESC_2", "RECEITA_COD"))
  
  receita = receita[grepl("\\d+", RECEITA_COD), ]
  receita_cod_multiplas = receita[grepl("/", RECEITA_COD), ]
  
  receita = receita[!grepl("/", RECEITA_COD), ]
  
  for(i in 1:nrow(receita_cod_multiplas)){
    receitas = unlist(strsplit(receita_cod_multiplas[i, RECEITA_COD], "/"))
    receitas = gsub(" *(\\d+) *", "\\1", receitas)
    
    receita_temp = data.table(RECEITA_COD_2 = receita_cod_multiplas[i, rep(RECEITA_COD_2, length(receitas))],
                              RECEITA_DESC_2 = receita_cod_multiplas[i, rep(RECEITA_DESC_2, length(receitas))],
                              RECEITA_COD = receitas)
    
    receita = rbind(receita, receita_temp)
    
  }
  
  return(receita)
  
}


receita = receita_de_para("bancos/manual/desc_classificacao_receita_formatado.xlsx")

# Rec Primario
receita[nat(RECEITA_COD, 1,7,9), unique(substr(RECEITA_COD_2,1,1))]
receita[nat(RECEITA_COD, 2), unique(substr(RECEITA_COD_2,1,1))]

pareamento_rec(23,23)

# MDE
receita[RECEITA_COD==1721013200, unique(RECEITA_COD_2)]
pareamento_rec(1724,1758)

# is_icms_principal_2
pareamento_rec(1113,c(11180211, 1118022))

# is_icms_mjm_2
pareamento_rec(191142,c(11180212, 11190112))

# is_icms_divida_ativa_2
pareamento_rec(193115,c(11180213, 11190113))

# is_icms_mjm_divida_ativa_2
pareamento_rec(191315, c(11180214, 11190114))

# is_ipva_principal_2
pareamento_rec(111205, 11180121)

# is_ipva_mjm_2
pareamento_rec(191141, 11180122)

# is_ipva_divida_ativa_2
pareamento_rec(193114, 11180123)

# is_ipva_mjm_divida_ativa_2
pareamento_rec(191314, 11180124)

# is_irrf_2
pareamento_rec(111204, 111303)

# is_itcd_principal_2
pareamento_rec(c(111207, 111209), 11180131)

# is_itcd_mjm_2
pareamento_rec(c(191120, 191103, 191109, 191121), 11180132)

# is_itcd_divida_ativa_2
pareamento_rec(193120, 11180133)
pareamento_rec(193117, 111111) # 193117 não econtrado
pareamento_rec(c(193102, 193122, 193202), 122121) # Nenhum dos 3 códigos encontrados.

# is_fpe_2
pareamento_rec(17210101, 17180111)

# is_ipi_2
pareamento_rec(17210112, 1718016)

# is_lei_kandir_2
pareamento_rec(172136, c(17180611))

# is_fapemig_desvinc_rec_2
pareamento_rec(11, c(1113, 11180121, 11180131, 11180211, 1118022, 11210111, 11210411, 11220111, 112203, 1122021101000)) # 1122021101000

pareamento_rec(191, c(11180122, 11180124, 11180132, 11180134, 11180212, 11180214, 1119011, -11190113, 
                      1121011, -11210111, -11210113, 11210412, 11210414, 11220112, 11220114, 12109912,
                      13100112, 13100122, 13109912, 13900012, 13900014, 14000012, 14000014,
                      15000012, 15000014, 16100112, 16100114, 16909912, 16909914, 19100111,
                      19100411, 191006, 191008, 191009, 19909912, 11220212, 11220214)) # 11220212, 11220214

# is_direta_ajustada_rec_2
pareamento_rec(7990805100, 7728019101000)
pareamento_rec(7210290202, c(7218021101001, 7218025101001)) ##
pareamento_rec(7990805100, 7728019101000)

# is_direitos_creditorios_2
pareamento_rec(11130251, 1118021101002)
pareamento_rec(19114252, 1118021201002)
pareamento_rec(191964, 1910011104001)
pareamento_rec(19311551, 1118021301002)
pareamento_rec(193251, 1910011304001)
pareamento_rec(91130251,9118021101)
pareamento_rec(99114252,9118021201)
pareamento_rec(991964, 99100111)
pareamento_rec(99311551,9118021301)
pareamento_rec(993251,9910011304)

# is_complementacao_rec_2
pareamento_rec(7940, 79900)

# is_intra_saude_rec_2
pareamento_rec(79908051, 7728019)

#is_aplic_fin_2
pareamento_rec(132, 132)
pareamento_rec(9328, 9321)
pareamento_rec(1322, c(1321006, 1322))
pareamento_rec(1323, 1323)

# add_poder_rec_contrib_2
pareamento_rec(12,c(12, -12109912))
pareamento_rec(72, c(72, -72109912))

# add_fitch_rec_2
pareamento_rec(7 ,7) # Corrigir -7990991106
pareamento_rec(91, c(91180121, 91180131, 91180211))
pareamento_rec(14, 14000011)
pareamento_rec(15, 15000011)
pareamento_rec(16, c(16, -16100112, -16100113, -16100114, -16909912, -16909913, -16909914))
pareamento_rec(72, c(72, -72109912))
pareamento_rec(74, c(74000011))
pareamento_rec(75, 75000011)
pareamento_rec(76, c(76, -76909913, -76909914))
pareamento_rec(17, 17)
pareamento_rec(97, 97)
pareamento_rec(22, 22)
pareamento_rec(24, 24)
pareamento_rec(23, 23)
pareamento_rec(21, 21)

# is_rcl
pareamento_rec(1721011302, 1718017101002)
pareamento_rec(c(121050, 12102907, 12102909, 12102911, -1210290702), c(1210991199000,  121004210, 121004219900,  
                                                                       121004310, 121004410, 1210991105, 1218022101, 
                                                                       121099105003, - 1210042199002))

pareamento_rec(c(1210290801, 1210291001), c(1218022102000, 1218023102000))
#pareamento_rec(1721010101, 1718011101001) # CORRIGIR

#View(receita[RECEITA_COD_2 %in% c(1610011223002, 1610011323002, 1610011423002, 1690991201000, 1690991301000, 1690991401000),])


# Demonstrativo 1 LOA volume 1

# TRANSFERÊNCIAS DA UNIÃO
pareamento_rec(1721, c(17180, 17189))

# TRANSFERÊNCIAS MULTIGOVERNAMENTAIS
pareamento_rec(1724, 1758)

# TRANSFERÊNCIAS DE CONVÊNIOS
pareamento_rec(176, c(17181, 17281, 17381, 17481))

# Alternativa para OUTRAS TRANSFERÊNCIAS
pareamento_rec(c(1723, 1730, 1750), c(1730, 1740, 177))

# TRANSFERÊNCIAS DE CONVÊNIOS
pareamento_rec(247, c(24181, 24281, 24381, 24481))

# OUTRAS RECEITAS
pareamento_rec(25, 29)

# FPE
pareamento_rec(17210101, 1718011)

# FUNDO EXPORTAÇÃO - IPI
pareamento_rec(17210112, 1718016)

# QESE - SALÁRIO EDUCAÇÃO
pareamento_rec(17213501, 1718051)

# LEI  COMPLEMENTAR Nº 87/96
pareamento_rec(c(172136, 172199, -17219999, -17219909), 1718061)

# TRANSFERÊNCIAS  SUS
pareamento_rec(c(172133, 172134, 172135, -17213501, -17213401,-17213503, -17213506, -17213509, -17213513), 
               c(1718031, 1718041, -1718041101, 171805, -1718051, -1718053, -1718059102))

# COTA-PARTE DA CIDE
pareamento_rec(17210113, 1718017)

# "COTA -PARTE DA COMP. FINANCEIRA - RECURSOS HÍDRICOS"
pareamento_rec(17212211, 1718021)

# COTA -PARTE DA COMP. FINANCEIRA - RECURSOS MINERAIS
pareamento_rec(17212220, 1718022)

# COTA -PARTE ROYALTIES - COMP. FINANC. - PROD. DE PETRÓLEO
pareamento_rec(17212230, 1718023)

# RECEITA PATRIMONIAL Parear apenas com 13 mantém Dívida ativa e multas e juros
pareamento_rec(13, 13)
receita[nat(RECEITA_COD_2, 1310011201001, 1310011201002, 1310012201000, 1310991201000, 1331011101002, 
            1349011101000, 1349011102000, 1349011199000, 1390001201000, 1390001301000, 1390001401000), 
        unique(paste(RECEITA_COD_2, RECEITA_DESC_2))]

# INTERNA
pareamento_rec(211, 211)

# EXTERNA
pareamento_rec(212, 212)

#### DEDUÇÃO ####

# ICMS
pareamento_rec(91130204, 9118021103)

# FPE
pareamento_rec(97210101, 97180111)

# IPI
pareamento_rec(97210112, 9718016)

# ICMS - DESONERAÇÃO - LEI COMPLEMENTAR 87/96
pareamento_rec(972136, 971806)

# MULTAS DO ICMS
pareamento_rec(99114202,9118021203)

# DÍVIDA ATIVA TRIBUTÁRIA ICMS
pareamento_rec(99311502, 9118021303)

# IPVA
pareamento_rec(91120503, 9118012103)

# ITCD
pareamento_rec(91120702, 9118013103)

# MULTAS DO ITCD
pareamento_rec(99112002, 91180132)

# MULTAS DO IPVA
pareamento_rec(99114103, 91180122)

# DÍVIDA ATIVA DO IPVA
pareamento_rec(99311403, 91180123)

# DÍVIDA ATIVA DO ITCD
pareamento_rec(99312002, 91180133)
