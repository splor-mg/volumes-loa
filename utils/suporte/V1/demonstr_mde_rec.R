demonstr_mde_rec = function(loa_rec){
  
  base = copy(loa_rec)
  
  # ICMS
  
  base[is_icms_bruto(base), 
       c("nvl2", "lvl2"):= list("1.1 - ICMS", 110)]
  
  base[is_icms_principal(base), c("nvl3", "lvl3"):= list("1.1.1 - ICMS Principal", 111)]
  
  base[is_icms_mjm(base) | is_icms_divida_ativa(base) | is_icms_mjm_divida_ativa(base), 
       c("nvl3", "lvl3"):= list("1.1.2 - Multas, Juros de Mora, Dívida Ativa e Outros Encargos do ICMS", 
                                112)]
  
  # ITCD
  
  base[is_itcd_bruto(base), 
       c("nvl2", "lvl2"):= list("1.2 - ITCD", 120)]
  
  base[is_itcd_principal(base), c("nvl3", "lvl3"):= list("1.2.1 - ITCD Principal", 121)]
  
  base[is_itcd_mjm(base) | is_itcd_divida_ativa(base) | is_itcd_mjm_divida_ativa(base), 
       c("nvl3", "lvl3"):= list("1.2.2 - Multas, Juros de Mora, Dívida Ativa e Outros Encargos do ITCD", 
                                122)]  
  
  # IPVA
  
  base[is_ipva_bruto(base), 
       c("nvl2", "lvl2"):= list("1.3 - IPVA", 130)]
  
  base[is_ipva_principal(base), 
       c("nvl3", "lvl3"):= list("1.3.1 - IPVA Principal", 131)]
  
  base[is_ipva_mjm(base) | is_ipva_divida_ativa(base) | is_ipva_mjm_divida_ativa(base), 
       c("nvl3", "lvl3"):= list("1.3.2 - Multas, Juros de Mora, Dívida Ativa e Outros Encargos do IPVA", 
                                132)]

  # IRRF
           
  base[is_irrf_bruto(base), 
       c("nvl2", "lvl2"):= list("1.4 - IRRF", 
                                140)]
  # RECEITAS DE IMPOSTOS
  
  base[is_irrf_bruto(base) | is_ipva_bruto(base) | is_itcd_bruto(base) | is_icms_bruto(base), 
       c("nvl1", "lvl1"):= list("1 - RECEITA DE IMPOSTOS", 100)]

  
  # 2 - RECEITA DE TRANSFERÊNCIAS CONSTITUCIONAIS E LEGAIS
  
  base[is_fpe_principal(base), c("nvl2", "lvl2"):= list("2.1 - Cota Parte FPE", 210)]
  base[is_lei_kandir_principal(base), c("nvl2", "lvl2"):= list("2.2 - ICMS Desoneração - LC nº 87/1996", 220)]
  base[is_ipi_principal(base), c("nvl2", "lvl2"):= list("2.3 - Cota Parte IPI Exportação", 230)]
  base[is_iof_ouro_principal(base), c("nvl2", "lvl2"):= list("2.4 - Cota Parte IOF Ouro", 231)]
  
  base[is_fpe_principal(base) | is_lei_kandir_principal(base) | is_ipi_principal(base) | is_iof_ouro_principal(base), 
       c("nvl1", "lvl1"):= list("2 - RECEITA DE TRANSFERÊNCIAS CONSTITUCIONAIS E LEGAIS", 200)]
  
  # DEDUÇÔES
  
  base[is_icms_bruto(base) & FONTE_COD == 20,
       c("nvl2d", "lvl2d"):= list("3.1 - Parcela do ICMS Repassada aos Municípios", 310)]
  
  base[is_ipva_bruto(base) & FONTE_COD == 20,
       c("nvl2d", "lvl2d"):= list("3.2 - Parcela do IPVA Repassada aos Municípios", 320)]
  
  base[is_ipi_principal(base) & FONTE_COD == 20,
       c("nvl2d", "lvl2d"):= list("3.3 - Parcela da Cota Parte do IPI Exportação Repassada aos Municípios", 330)]
  
  base[is_itcd_bruto(base) & FONTE_COD == 20,
       c("nvl2d", "lvl2d"):= list("3.2 - Parcela do ITCD Repassada aos Municípios", 340)]
  
  base[FONTE_COD == 20 & (is_icms_bruto(base) | 
                          is_ipva_bruto(base) |  
                          is_ipi_principal(base) | 
                          is_itcd_bruto(base)), 
       c("nvl1d", "lvl1d"):= list("3 - DEDUÇÕES DE TRANSFERÊNCIAS CONSTITUCIONAIS AOS MUNICÍPIOS", 300)]
  
  mde_rec = rbindlist(list(base[!is.na(nvl1), list(nvl=1, VL_LOA = sum(VL_LOA_REC)),
                                by=list(espec=nvl1, ordem = lvl1)],
                           base[!is.na(nvl1d), list(nvl=1, VL_LOA = sum(VL_LOA_REC)),
                                     by=list(espec=nvl1d, ordem = lvl1d)],
                           base[!is.na(nvl2d), list(nvl=2, VL_LOA = sum(VL_LOA_REC)),
                                     by=list(espec=nvl2d, ordem = lvl2d)],
                           base[!is.na(nvl2), list(nvl=2, VL_LOA = sum(VL_LOA_REC)), 
                                by=list(espec=nvl2, ordem = lvl2)],
                           base[!is.na(nvl3), list(nvl=3, VL_LOA = sum(VL_LOA_REC)), 
                                by=list(espec=nvl3, ordem = lvl3)]
                           )
                     )
  
  mde_rec = mde_rec[order(ordem)]
  mde_rec[, ordem:=NULL]
  
  return(mde_rec)
  
}
