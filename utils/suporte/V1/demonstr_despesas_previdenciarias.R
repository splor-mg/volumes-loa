
demonstr_despesas_previdenciarias = function(base){
  
  base = copy(loa_desp)
  

  # N2: BENEFÍCIOS CIVIL
  
  base[UO_COD == 4711 & !ACAO_COD %in% c(7008, 7016) & ELEMENTO_COD %in% c(1, 13, 91, 92, 94) & !ELEMENTO_ITEM_COD == 1308, c("nvl3", "ordem3") := list("Aposentadorias", 3)]
  base[UO_COD %in% c(1011, 1021, 1031, 1051, 1091, 1441) & 
       ACAO_COD == 7006 & IPU_COD == 5 & ELEMENTO_COD %in% c(1, 13, 91, 92, 94) & !ELEMENTO_ITEM_COD == 1308, c("nvl3", "ordem3") := list("Aposentadorias", 3)]
  
  base[ACAO_COD %in% c(7008, 7023) & (ELEMENTO_COD %in% c(3)| ELEMENTO_ITEM_COD == 1308), c("nvl3", "ordem3") := list("Pensões", 4)] 
  base[ACAO_COD == 7006 & (ELEMENTO_COD %in% c(3) | ELEMENTO_ITEM_COD == 1308), 
       c("nvl3", "ordem3") := list("Pensões", 4)]

  base[UO_COD %in% c(4711) & !ELEMENTO_COD %in% c(1, 3, 13, 86, 91, 92, 94), 
       c("nvl3", "ordem3") := list("Outros Benefícios Previdenciários", 5)]
  base[ACAO_COD %in% c(7006) & IPU_COD == 5 & !ELEMENTO_COD %in% c(1, 3, 13, 91, 92, 94), 
       c("nvl3", "ordem3") := list("Outros Benefícios Previdenciários", 5)]

  base[ordem3 %in% 3:5, c("nvl2", "ordem2") := list("Benefícios -  Civil", 2)]
  
  # N2: BENEFÍCIOS - MILITAR
  
  base[ACAO_COD == 7007 & ELEMENTO_COD %in% c(1, 13, 91, 92, 94), c("nvl3", "ordem3") := list("Reformas", 7)]
  
  base[ACAO_COD == 7002 & (ELEMENTO_COD %in% c(3) | ELEMENTO_ITEM_COD == 1308), c("nvl3", "ordem3") := list("Pensões", 8)]
  
  base[ACAO_COD %in% c(7007,7002) & !ELEMENTO_COD %in% c(1, 3, 13, 91, 92, 94), c("nvl3", "ordem3") := list("Outros Benefícios Previdenciários", 9)]

  base[ordem3 %in% 7:9, c("nvl2", "ordem2") := list("Benefícios - Militar", 6)]

  # N1: BENEFÍCIOS
  
  base[nvl2 %in% c("Benefícios - Militar",
                   "Benefícios -  Civil"), 
       c("nvl1", "ordem1") := list("BENEFÍCIOS", 1)]


  # N1: OUTRAS DESPESAS PREVIDENCIÁRIAS

  base[ACAO_COD == 7016, 
       c("nvl2", "ordem2") := list("Compensação Previdenciária do RPPS para o RGPS", 11)]
  
  base[UO_COD %in% c(2011, 2121) & ACAO_COD == 7004, 
       c("nvl2", "ordem2") := list("Demais Despesas Previdenciárias", 12)]
  
  base[ordem2 %in% 11:12, c("nvl1", "ordem1") := list("Outras Despesas Previdenciárias", 10)]
  
  
  
  
  demonstr_desp_prev = rbindlist(list(base[!is.na(nvl1), list(nvl=1, VL_LOA = sum(VL_LOA_DESP)),
                                           by=list(espec=nvl1, ordem = ordem1)],
                                      base[!is.na(nvl2), list(nvl=2, VL_LOA = sum(VL_LOA_DESP)), 
                                           by=list(espec=nvl2, ordem = ordem2)],
                                      base[!is.na(nvl3), list(nvl=3, VL_LOA = sum(VL_LOA_DESP)), 
                                           by=list(espec=nvl3, ordem = ordem3)]
                                      )
                                  )
  
  demonstr_desp_prev = demonstr_desp_prev[order(ordem)]
  demonstr_desp_prev[, ordem := NULL]
  
  return(demonstr_desp_prev)
  
}
