
demonstr_despesas_previdenciarias = function(base){
  
  base = copy(loa_desp)
  
  # N1: ADMINISTRAÇÃO MILITAR
  
  base[UO_COD == 2121 & ACAO_COD %in% c(2018, 4003) & CATEGORIA_COD == 3, 
       c("nvl2", "ordem2") := list("Despesas Correntes", 2)]

  base[UO_COD == 2121 & ACAO_COD %in% c(2018, 4003) & CATEGORIA_COD == 4,
      c("nvl2", "ordem2") := list("Despesas de Capital", 3)]

  base[ordem2 %in% 2:3, c("nvl1", "ordem1") := list("ADMINISTRAÇÃO MILITAR", 1)]

  # N2: Benefícios -  Civil
  
  base[UO_COD == 4711 & !(ACAO_COD %in% c(7008, 7023, 7016)), c("nvl3", "ordem3") := list("Aposentadoria", 6)]
  base[UO_COD %in% c(1011, 1021, 1031, 1051, 1091, 1441) & 
       ACAO_COD == 7006 & !(ELEMENTO_COD %in% c(3, 59) | ELEMENTO_ITEM_COD == 1308), c("nvl3", "ordem3") := list("Aposentadoria", 6)]
  
  
  base[ACAO_COD %in% c(7008, 7023), c("nvl3", "ordem3") := list("Pensão", 7)] 
  base[ACAO_COD == 7006 & (ELEMENTO_COD %in% c(3, 59) | ELEMENTO_ITEM_COD == 1308), 
       c("nvl3", "ordem3") := list("Pensão", 7)]

  base[UO_COD %in% c(2121, 4711) & ELEMENTO_COD %in% c(92,94) & GRUPO_COD == 1, 
       c("nvl3", "ordem3") := list("Outros Benefícios Previdenciários", 8)]

  base[ordem3 %in% 6:8, c("nvl2", "ordem2") := list("Benefícios -  Civil", 5)]
  
  # N2: Benefícios - Militar
  
  base[ACAO_COD == 7007, c("nvl3", "ordem3") := list("Reformas", 10)]
  
  base[ACAO_COD == 7002, c("nvl3", "ordem3") := list("Pensões", 11)]
  
  base[UO_COD %in% c(1251, 1401, 2121, 1051) & 
       ELEMENTO_ITEM_COD %in% c(501, 505, 802, 805, 807), 
       c("nvl3", "ordem3") := list("Outros Benefícios Previdenciários", 12)]
  
  base[ordem3 %in% 10:12, c("nvl2", "ordem2") := list("Benefícios - Militar", 9)]

  # N2: Outras Despesas Previdenciárias

  base[ACAO_COD == 7016, 
       c("nvl3", "ordem3") := list("Compensação Previdenciária do RPPS para o RGPS", 14)]
  
  base[UO_COD %in% c(2011, 2121) & ACAO_COD == 7004, 
       c("nvl3", "ordem3") := list("Demais Despesas Previdenciárias", 15)]
  
  base[ordem3 %in% 14:15, c("nvl2", "ordem2") := list("Outras Despesas Previdenciárias", 13)]
  
  # N1: PREVIDÊNCIA
  
  base[nvl2 %in% c("Outras Despesas Previdenciárias",
                   "Benefícios - Militar",
                   "Benefícios -  Civil"), 
       c("nvl1", "ordem1") := list("PREVIDÊNCIA", 4)]
  
  
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
