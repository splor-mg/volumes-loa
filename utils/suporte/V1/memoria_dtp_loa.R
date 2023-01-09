library(tidyverse)
library(relatorios)
library(data.table)
library(conflicted)
library(reest)

conflict_prefer("select", "dplyr")
conflict_prefer("filter", "dplyr")

options(pillar.sigfig = 20)

base = ler_loa_desp('sisor_desp.xlsx')

# Memória DTP PLOA 2020

base$DBP = FALSE
base[GRUPO_COD == 1, DBP := TRUE]
base[GRUPO_COD == 3 & ELEMENTO_COD == 34, DBP := TRUE]
base[GRUPO_COD == 3 & ELEMENTO_COD == 13 & ITEM_COD == 07, DBP := TRUE]
base[GRUPO_COD == 3 & ELEMENTO_COD == 13 & ITEM_COD == 23, DBP := TRUE]

base[ELEMENTO_COD == 59 & ITEM_COD == 01, DBP := FALSE]
base[ELEMENTO_COD == 12 & ITEM_COD == 04, DBP := FALSE]
base[ELEMENTO_COD == 16 & ITEM_COD == 05, DBP := FALSE]
base[ELEMENTO_COD %in% 92:94, DBP := FALSE]

base[ACAO_COD == 7002 & ELEMENTO_COD == 3 & FONTE_COD %in% 49:50, DBP := FALSE]

base[IPU_COD == 9 , DBP := FALSE]
base[UO_COD == 4711 & FONTE_COD == 60, DBP := FALSE]
base[FONTE_COD %in% c(30,42,43,44,58,75), DBP := FALSE]

# Conferencia

base %>% 
  mutate(ANO = 2020) %>%
  filter(DBP == TRUE) %>% 
  filter(is_executivo(.) | is_def_pub(.)) %>% 
  summarise(VL_LOA_DESP = sum(VL_LOA_DESP)) %>% 
  as_tibble()


base %>% 
  mutate(ANO = 2020) %>%
  filter(DBP == TRUE) %>% 
  filter(is_legislativo(.) | is_tce(.)) %>% 
  summarise(VL_LOA_DESP = sum(VL_LOA_DESP)) %>% 
  as_tibble()


base %>% 
  mutate(ANO = 2020) %>%
  filter(DBP == TRUE) %>% 
  filter(is_judiciario(.)) %>% 
  summarise(VL_LOA_DESP = sum(VL_LOA_DESP)) %>% 
  as_tibble()

base %>% 
  mutate(ANO = 2020) %>%
  filter(DBP == TRUE) %>% 
  filter(is_pgj(.)) %>% 
  summarise(VL_LOA_DESP = sum(VL_LOA_DESP)) %>% 
  as_tibble()

