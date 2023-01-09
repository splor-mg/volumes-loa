is_dtp_loa <- function(base, deduz_f58 = FALSE)   {
  colunas_obrigatorias <- c("ANO", "UO_COD", "FONTE_COD", "GRUPO_COD",
                            "IPU_COD", "ELEMENTO_COD", "ELEMENTO_ITEM_COD")
  base <- verifica_base(base, colunas_obrigatorias)
  
  base$DTP <- FALSE

  # Despesa Bruta com Pessoal
  base[is_dbp(base),
            DTP := TRUE]
  
  # Indenizacoes por restituicoes trabalhistas
  base[ELEMENTO_COD == 94, DTP := FALSE]
  
# Sentencas judiciais
  base[ANO != 2013 & 
            IPU_COD == 9,
            DTP := FALSE]

# DEA
  base[ANO != 2013 & 
            ELEMENTO_COD == 92,
            DTP := FALSE]

# Inativos e pensionistas com recursos vinculados 2014 em diante

  base[ANO >= 2014 & UO_COD == 2361 & FONTE_COD == 60 & ELEMENTO_COD %in% c(1, 3, 59),
            DTP := FALSE]
  
  base[ANO >= 2014 & UO_COD == 4431 & FONTE_COD == 60,
            DTP := FALSE]
  
  base[ANO >= 2018 & FONTE_COD %in% c(42, 43, 44, 81) & IPU_COD %in% c(1, 5),
            DTP := FALSE]     

  if(deduz_f58 == TRUE) {
      base[ANO >= 2018 & FONTE_COD == 58 & IPU_COD %in% c(1, 5),
            DTP := FALSE]     
  }

  base[ANO >= 2017 & FONTE_COD == 60 & UO_COD == 4711,
            DTP := FALSE]

  base[ANO >= 2017 & FONTE_COD %in% c(30, 75, 78),
            DTP := FALSE]     

  base[ANO >= 2020 & FONTE_COD %in% c(49,50) & ACAO_COD == 7002 & ELEMENTO_COD == 3,
            DTP := FALSE]     

  return(base$DTP)
}

