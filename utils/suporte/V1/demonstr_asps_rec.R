demonstr_asps_rec = function(loa_rec){
  
  base = copy(loa_rec)
  
  
  base[is_itcd_principal(base), c("nvl2", "lvl2"):= list("ITCD Principal", 110)]
  
  base[is_icms_principal(base), c("nvl2", "lvl2"):= list("ICMS Principal", 120)]
  
  base[is_ipva_principal(base), c("nvl2", "lvl2"):= list("IPVA Principal", 130)]  
  
  base[is_irrf_bruto(base), c("nvl2", "lvl2"):= list("IRRF", 140)]
  
  base[is_icms_mjm(base) | is_itcd_mjm(base) | is_ipva_mjm(base), 
       c("nvl2", "lvl2"):= list("Multas, Juros de Mora e Outros Encargos dos Impostos", 150)]
  
  base[is_icms_divida_ativa(base)  | is_itcd_divida_ativa(base) | is_ipva_divida_ativa(base), 
       c("nvl2", "lvl2"):= list("Dívida Ativa dos Impostos", 160)]
  
  
  base[is_icms_mjm_divida_ativa(base) | is_ipva_mjm_divida_ativa(base), 
       c("nvl2", "lvl2"):= list("Multas, Juros de Mora e Outro Encargos da Dívida Ativa", 170)]
  
  
  base[is_irrf_bruto(base) | is_ipva_bruto(base) | is_itcd_bruto(base) | is_icms_bruto(base), 
       c("nvl1", "lvl1"):= list("I - RECEITA DE IMPOSTOS", 100)]
  
  
  # 2 - RECEITA DE TRANSFERÊNCIAS CONSTITUCIONAIS E LEGAIS
  
  base[is_fpe_principal(base), c("nvl2", "lvl2"):= list("Cota Parte FPE", 210)]
  base[is_ipi_principal(base), c("nvl2", "lvl2"):= list("Cota Parte IPI Exportação", 220)]
  base[is_lei_kandir_principal(base), c("nvl2", "lvl2"):= list("ICMS Desoneração - LC nº 87/1996", 230)]
  #base[RECEITA_COD %in% c(1718018101000), c("nvl3", "lvl3"):= list("Cota Parte IOF Ouro", 232)]
  
  # base[is_lei_kandir(base), #| RECEITA_COD %in% c(1718018101000), 
  #      c("nvl2", "lvl2"):= list("Compensações Financeiras Provenientes de Impostos e Transferências Governamentais", 230)]
  
  base[is_fpe_principal(base) | is_lei_kandir_principal(base) | is_ipi_principal(base), #| RECEITA_COD %in% c(1718018101000), 
       c("nvl1", "lvl1"):= list("II - RECEITA DE TRANSFERÊNCIAS CONSTITUCIONAIS E LEGAIS", 200)]
  
  # DEDUÇÔES
  
  base[is_icms_bruto(base) & FONTE_COD == 20,
       c("nvl2d", "lvl2d"):= list("Parcela do ICMS Repassada aos Municípios", 310)]
  
  base[is_ipva_bruto(base) & FONTE_COD == 20,
       c("nvl2d", "lvl2d"):= list("Parcela do IPVA Repassada aos Municípios", 320)]
  
  base[is_ipi_principal(base) & FONTE_COD == 20,
       c("nvl2d", "lvl2d"):= list("Parcela da Cota Parte do IPI Exportação Repassada aos Municípios", 330)]
  
  base[is_itcd_bruto(base) & FONTE_COD == 20,
       c("nvl2d", "lvl2d"):= list("Parcela do ITCD Repassada aos Municípios", 340)]
  
  base[FONTE_COD == 20 & (is_icms_bruto(base) | 
                            is_ipva_bruto(base) |  
                            is_ipi_principal(base) | 
                            is_itcd_bruto(base)), 
       c("nvl1d", "lvl1d"):= list("III - DEDUÇÕES DE TRANSFERÊNCIAS CONSTITUCIONAIS AOS MUNICÍPIOS", 300)]
  
  asps_rec = rbindlist(list(base[!is.na(nvl1), list(nvl=1, VL_LOA = sum(VL_LOA_REC)),
                                by=list(espec=nvl1, ordem = lvl1)],
                           base[!is.na(nvl1d), list(nvl=1, VL_LOA = sum(VL_LOA_REC)),
                                by=list(espec=nvl1d, ordem = lvl1d)],
                           base[!is.na(nvl2d), list(nvl=2, VL_LOA = sum(VL_LOA_REC)),
                                by=list(espec=nvl2d, ordem = lvl2d)],
                           base[!is.na(nvl2), list(nvl=2, VL_LOA = sum(VL_LOA_REC)), 
                                by=list(espec=nvl2, ordem = lvl2)]
                           # base[!is.na(nvl3), list(nvl=3, VL_LOA = sum(VL_LOA_REC)), 
                           #      by=list(espec=nvl3, ordem = lvl3)]
                           )
                       )
  
  asps_rec = asps_rec[order(ordem)]
  asps_rec[, ordem:=NULL]
  
  return(asps_rec)
  
}
