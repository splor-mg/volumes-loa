
demonstrativo_consolidado_rec = function(loa_rec){
  
  
  base = copy(loa_rec)
  
  # =================== Nivel 1 ===================================
  
  base[nat(RECEITA_COD, 1), c("nvl1", "desc1") := list(1, "RECEITAS CORRENTES")]
  base[nat(RECEITA_COD, 2), c("nvl1", "desc1") := list(2, "RECEITAS DE CAPITAL")]
  base[nat(RECEITA_COD, 9), c("nvl1", "desc1") := list(9, "DEDUÇÕES DA RECEITA CORRENTE")]
  
  # =================== Nivel 2 ===================================
  
  base[nat(RECEITA_COD, 11), c("nvl2", "desc2") :=list(1, "IMPOSTOS, TAXAS E CONTRIBUIÇÕES DE MELHORIA")]
  base[nat(RECEITA_COD, 12), c("nvl2", "desc2") :=list(2, "RECEITAS DE CONTRIBUIÇÕES")]
  base[is_transf_uniao(base), c("nvl2", "desc2") :=list(3, "TRANSFERÊNCIAS DA UNIÃO")]
  base[is_volta_fundeb(base), c("nvl2", "desc2") :=list(4, "TRANSFERÊNCIAS DO FUNDEB")]
  base[nat(RECEITA_COD, 1) & is_convenios_rec(base), c("nvl2", "desc2") :=list(6, "TRANSFERÊNCIAS DE CONVÊNIOS")]
  base[nat(RECEITA_COD, 17) & is.na(desc2), c("nvl2", "desc2") :=list(5, "OUTRAS TRANSFERÊNCIAS")]
  
  base[nat(RECEITA_COD, 1) & is.na(desc2) , c("nvl2", "desc2") :=list(7, "OUTRAS RECEITAS CORRENTES")]
  
  base[nat(RECEITA_COD, 21), c("nvl2", "desc2") :=list(8, "OPERAÇÕES DE CRÉDITO")]
  base[nat(RECEITA_COD, 22), c("nvl2", "desc2") :=list(9, "ALIENAÇÃO DE BENS")]
  base[nat(RECEITA_COD, 23), c("nvl2", "desc2") :=list(10, "AMORTIZAÇÃO DE EMPRÉSTIMOS")]
  base[nat(RECEITA_COD, 2) & is_convenios_rec(base), c("nvl2", "desc2") :=list(11, "TRANSFERÊNCIAS DE CONVÊNIOS")]
  base[nat(RECEITA_COD, 24) & is.na(desc2), c("nvl2", "desc2") :=list(12, "OUTRAS TRANSFERÊNCIAS")]
  base[nat(RECEITA_COD, 29), c("nvl2", "desc2") :=list(13, "OUTRAS RECEITAS")]
  
  # =================== Nivel 3 ===================================
  
  # ==== RECEITA TRIBUTÁRIA [nat(RECEITA_COD, 11)] =================================================
  
  base[grepl("11\\d{5}1\\d{5}", RECEITA_COD), c("nvl3", "desc3") :=list(1,"PRINCIPAL")]
  
  base[grepl("11\\d{5}[^1]\\d{5}", RECEITA_COD), 
       c("nvl3", "desc3") :=list(2,"ACESSÓRIAS [DÍVIDA ATIVA, MULTAS E JUROS]")]
  
  # ==== TRANSFERÊNCIAS DA UNIÃO [nat(RECEITA_COD, 17180, 17189)] ==========================================
  
  base[nat(RECEITA_COD, 1) & is_fpe_principal(base), c("nvl3", "desc3") :=list(3,"FPE")]
  base[nat(RECEITA_COD, 1) & is_ipi_principal(base), c("nvl3", "desc3") :=list(4,"FUNDO EXPORTAÇÃO - IPI")]
  base[nat(RECEITA_COD, 171450), c("nvl3", "desc3") :=list(5,"QESE - SALÁRIO EDUCAÇÃO")]
  base[nat(RECEITA_COD, 1) & is_lei_kandir_principal(base), c("nvl3", "desc3") :=list(6,"LEI  COMPLEMENTAR Nº 87/96")]
  
  base[nat(RECEITA_COD, 1713), c("nvl3", "desc3") :=list(7,"TRANSFERÊNCIAS  SUS")]
  
  base[nat(RECEITA_COD, 171154), c("nvl3", "desc3") := list(8,"COTA-PARTE DA CIDE")]
  base[nat(RECEITA_COD, 171250), c("nvl3", "desc3") := list(9,"COTA -PARTE DA COMP. FINANCEIRA - RECURSOS HÍDRICOS")]
  base[nat(RECEITA_COD, 171251), c("nvl3", "desc3") := list(10,"COTA -PARTE DA COMP. FINANCEIRA - RECURSOS MINERAIS")]
  base[nat(RECEITA_COD, 171252), c("nvl3", "desc3") := list(11,"COTA -PARTE ROYALTIES - COMP. FINANC. - PROD. DE PETRÓLEO")]
  base[desc2 == "TRANSFERÊNCIAS DA UNIÃO" & is.na(desc3), c("nvl3", "desc3") :=list(12,"OUTRAS TRANSFERÊNCIAS DA UNIÀO")]
  
  # ==== OUTRAS RECEITAS CORRENTES [nat(RECEITA_COD, 13, 14, 15, 16, 19)] =========================
  # Receita patrimonial, agropecuária, industrial e de serviços mantém dívida ativa, juros e mora e restituições
  # ao manter esse código
  
  base[nat(RECEITA_COD, 13), c("nvl3", "desc3") :=list(17,"RECEITA PATRIMONIAL")]
  base[nat(RECEITA_COD, 14), c("nvl3", "desc3") :=list(18,"RECEITA AGROPECUÁRIA")]
  base[nat(RECEITA_COD, 15), c("nvl3", "desc3") :=list(19,"RECEITA INDUSTRIAL")]
  base[nat(RECEITA_COD, 16), c("nvl3", "desc3") :=list(20,"RECEITA DE SERVIÇOS")]
  base[nat(RECEITA_COD, 19), c("nvl3", "desc3") :=list(21,"RECEITAS DIVERSAS")]
  
  # ==== OPERAÇÕES DE CRÉDITO [nat(RECEITA_COD, 21)] ==============================================
  
  base[nat(RECEITA_COD, 211), c("nvl3", "desc3") :=list(22,"INTERNA")]
  base[nat(RECEITA_COD, 212), c("nvl3", "desc3") :=list(23,"EXTERNA")]
  
  # ==== DEDUÇÕES DA RECEITA CORRENTE [nat(RECEITA_COD, 9)] =======================================
  
  # base[nat(RECEITA_COD, 9118021103), c("nvl3", "desc3") :=list(24,"ICMS")]
  # base[nat(RECEITA_COD, 97180111), c("nvl3", "desc3") :=list(25,"FPE")]
  # base[nat(RECEITA_COD, 9718016), c("nvl3", "desc3") :=list(26,"IPI")]
  # base[nat(RECEITA_COD, 9718061), c("nvl3", "desc3") :=list(27,"ICMS - DESONERAÇÃO - LEI COMPLEMENTAR 87/96")]
  # base[nat(RECEITA_COD, 9118021203), c("nvl3", "desc3") :=list(28,"MULTAS DO ICMS")]
  # base[nat(RECEITA_COD, 9118021303), c("nvl3", "desc3") :=list(29,"DÍVIDA ATIVA TRIBUTÁRIA ICMS")]
  # 
  # base[nat(RECEITA_COD, 9118012103), c("nvl3", "desc3") :=list(30,"IPVA")]
  # base[nat(RECEITA_COD, 9118013103), c("nvl3", "desc3") :=list(31,"ITCD")]
  # base[nat(RECEITA_COD, 91180132), c("nvl3", "desc3") :=list(32,"MULTAS DO ITCD")]
  # base[nat(RECEITA_COD, 91180122), c("nvl3", "desc3") :=list(33,"MULTAS DO IPVA")]
  # base[nat(RECEITA_COD, 91180123), c("nvl3", "desc3") :=list(34,"DÍVIDA ATIVA DO IPVA")]
  # base[nat(RECEITA_COD, 91180133), c("nvl3", "desc3") :=list(35,"DÍVIDA ATIVA DO ITCD")]
  # base[nat(RECEITA_COD, 9) & is.na(desc3), c("nvl3", "desc3") :=list(36,"CESSÃO DE DIREITOS CREDITÓRIOS")]
  
  
  base[nat(RECEITA_COD, 9) & is_ida_fundeb(base) & is_icms_bruto(base, deducoes = T), c("nvl3", "desc3") :=list(24,"ICMS - FUNDEB")]
  base[nat(RECEITA_COD, 9) & is_transf_const_mun_rec(base) & is_icms_bruto(base, deducoes = T), c("nvl3", "desc3") :=list(29,"ICMS - MUNICÍPIOS")]
  
  base[nat(RECEITA_COD, 9) & is_ida_fundeb(base) & is_ipva_bruto(base, deducoes = T), c("nvl3", "desc3") :=list(25,"IPVA - FUNDEB")]
  base[nat(RECEITA_COD, 9) & is_transf_const_mun_rec(base) & is_ipva_bruto(base, deducoes = T), c("nvl3", "desc3") :=list(30,"IPVA - MUNICÍPIOS")]
  
  base[nat(RECEITA_COD, 9) & is_ida_fundeb(base) & is_itcd_bruto(base, deducoes = T), c("nvl3", "desc3") :=list(26,"ITCD - FUNDEB")]
  base[nat(RECEITA_COD, 9) & is_transf_const_mun_rec(base) & is_itcd_bruto(base, deducoes = T), c("nvl3", "desc3") :=list(31,"ITCD - MUNICÍPIOS")]
  
  base[nat(RECEITA_COD, 9) & is_ida_fundeb(base) & is_fpe_principal(base, deducoes = T), c("nvl3", "desc3") :=list(27,"FPE - FUNDEB")]
  #base[nat(RECEITA_COD, 9) & is_transf_const_mun_rec(base) & is_fpe_principal(base), c("nvl3", "desc3") :=list(24,"FPE - MUNICÍPIOS")]
  
  base[nat(RECEITA_COD, 9) & is_ida_fundeb(base) & is_ipi_principal(base, deducoes = T), c("nvl3", "desc3") :=list(28,"IPI - FUNDEB")]
  base[nat(RECEITA_COD, 9) & is_transf_const_mun_rec(base) & is_ipi_principal(base, deducoes = T), c("nvl3", "desc3") :=list(32,"IPI - MUNICÍPIOS")]
  
  base[nat(RECEITA_COD, 971154), c("nvl3", "desc3") :=list(33,"CIDE - MUNICÍPIOS")]
  
  #base[nat(RECEITA_COD, 9) & is.na(desc3), c("nvl3", "desc3") :=list(34,"CESSÃO DE DIREITOS CREDITÓRIOS")]
  base[nat(RECEITA_COD, 9911010103003) & is.na(desc3), c("nvl3", "desc3") :=list(34,"FUNSET")]
  base[nat(RECEITA_COD, 9) & is.na(desc3) , c("nvl3", "desc3") :=list(35,"OUTRAS DEDUÇÕES")]
  
  
  # =================== Nivel 4 ===================================
  # nat(RECEITA_COD, 11180211, 11180221, 11180121, 11180131, 11130311, 11210111, 11210411, 11220111, 11220311) "PRINCIPAL"
  
  base[is_icms_principal(base), c("nvl4", "desc4") :=list(1,"ICMS")]
  base[is_ipva_principal(base), c("nvl4", "desc4") :=list(2, "IPVA")]
  base[is_itcd_principal(base), c("nvl4", "desc4") :=list(3, "ITCD")]
  base[is_irrf_principal(base), c("nvl4", "desc4") :=list(4, "IRRF")]
  base[is_taxas_principal(base), c("nvl4", "desc4") :=list(5, "TAXAS")]
  
  
  
  # nat(RECEITA_COD, 11180212, 11180213, 11180214, 11190112, 11190113, 11190114, 11180122, 
  #                  11180123, 11180124, 11180132, 11180133, 11180134, 11210112, 11210412, 
  #                  11220112, 11210113, 11210413, 11220113, 11210114, 11210414, 11220114), 
  #                  "ACESSÓRIAS [DÍVIDA ATIVA, MULTAS E JUROS]"

  base[is_icms_acessorias(base), c("nvl4", "desc4") :=list(6, "ICMS")]
  base[is_ipva_acessorias(base), c("nvl4", "desc4") :=list(7, "IPVA")]
  base[is_itcd_acessorias(base), c("nvl4", "desc4") :=list(8, "ITCD")]
  
  base[is_taxas_acessorias(base), c("nvl4", "desc4") :=list(9, "TAXAS")]
       
  return(base)
  
}

