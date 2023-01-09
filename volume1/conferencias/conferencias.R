library(tidyverse)
library(execucao)
library(relatorios)
library(data.table)
library(conflicted)
library(reest)

conflict_prefer("select", "dplyr")
conflict_prefer("filter", "dplyr")

options(pillar.sigfig = 99)

desp = ler_loa_desp('bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx')
qdd = ler_loa_desp('bancos/SISOR/BASE_QDD_FISCAL.xlsx')
rec = ler_loa_rec('bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx')

# T14 --------------------------------------------------------------------------
# DEMONSTRATIVO DA DESPESA POR FUNÇÃO, SUBFUNÇÃO E PROGRAMA CONFORME O VÍNCULO COM OS RECURSOS
tbl = desp %>% 
  mutate(
    VINCULO = case_when(
      FONTE_COD %in% c(10) ~ 'ORDINARIO',
      FONTE_COD %in% 60:61 ~ 'RDA',
      TRUE ~ 'VINCULADOS'
    ))

tbl %>% 
  group_by(VINCULO) %>%
  summarise(VL_LOA_DESP = sum(VL_LOA_DESP))

tbl %>% 
  summarise(VL_LOA_DESP = sum(VL_LOA_DESP)) %>% 
  as_tibble()

# T15 --------------------------------------------------------------------------
# PROGRAMA DE TRABALHO DO GOVERNO: DEMONSTRATIVO DA DESPESA POR FUNÇÕES, 
# SUBFUNÇÕES E PROGRAMAS CONFORME OS GRUPOS DE DESPESA
tbl %>% 
  group_by(GRUPO_COD) %>% 
  summarise(VL_LOA_DESP=sum(VL_LOA_DESP))

tbl %>% 
  summarise(VL_LOA_DESP=sum(VL_LOA_DESP)) %>% 
  as_tibble()

qdd %>% 
  group_by(GRUPO_COD) %>% 
  summarise(VL_LOA_DESP=sum(VL_LOA_DESP))

# T16 MDE ----------------------------------------------------------------------
rec %>% 
  filter(is_mde_rec(.)) %>% 
  summarise(VL_LOA_REC=sum(VL_LOA_REC)) %>% 
  as_tibble()

rec %>% 
  mutate(ANO=2020) %>% 
  filter(is_perda_fundeb(.)) %>% 
  summarise(VL_LOA_REC = sum(VL_LOA_REC)) %>% 
  as_tibble()

tbl %>% 
  mutate(ANO=2020) %>% 
  filter(is_mde_desp(.)) %>% 
  group_by(UO_COD) %>%
  summarise(VL_LOA_DESP = sum(VL_LOA_DESP))


# T17 ---------------------------------------------------------------------
# DEMONSTRATIVO DA APLICAÇÃO DE RECURSOS EM PROGRAMAS DE SAÚDE E
# INVESTIMENTO EM TRANSPORTE E SISTEMA VIÁRIO
desp %>% 
  filter(FUNCAO_COD == 10) %>% 
  group_by(UO_COD) %>%
  summarise(VL_LOA_DESP = sum(VL_LOA_DESP))

desp %>% 
  filter(FUNCAO_COD == 26, GRUPO_COD %in% c(4,5)) %>% 
  group_by(UO_COD) %>%
  summarise(VL_LOA_DESP = sum(VL_LOA_DESP))

# T18 ASPS ---------------------------------------------------------------------
rec %>% 
  filter(is_asps_rec(.)) %>% 
  summarise(VL_LOA_REC=sum(VL_LOA_REC)) %>% 
  as_tibble()

tbl %>% 
  mutate(ANO=2020) %>% 
  filter(is_asps_desp(.)) %>% 
  group_by(UO_COD) %>%
  summarise(VL_LOA_DESP = sum(VL_LOA_DESP))

# T19 FAPEMIG ------------------------------------------------------------------
rec %>% 
  filter(is_fapemig_rec(.)) %>% 
  summarise(VL_LOA_REC=sum(VL_LOA_REC)) %>% 
  as_tibble()

rec %>% 
  filter(FONTE_COD == 10, nat(RECEITA_COD, 1)) %>% 
  summarise(VL_LOA_REC=sum(VL_LOA_REC)) %>% 
  as_tibble()

tbl %>% 
  mutate(ANO=2020) %>% 
  filter(is_fapemig_desp(.)) %>% 
  group_by(UO_COD) %>%
  summarise(VL_LOA_DESP = sum(VL_LOA_DESP))


# T20 - PESSOAL RCL -------------------------------------------------------
x = desp %>% 
  filter(
    GRUPO_COD == 1 |
    (GRUPO_COD == 3 & ELEMENTO_COD == 34) |
    (GRUPO_COD == 3 & ELEMENTO_COD == 13 & (ITEM_COD == 07 | ITEM_COD == 23))
  ) %>% 
  filter(!(ELEMENTO_COD == 59 & ITEM_COD == 01),
         !(ELEMENTO_COD == 12 & ITEM_COD == 04),
         !(ELEMENTO_COD == 16 & ITEM_COD == 05),
         !(ELEMENTO_COD %in% 91:94),
         !(FONTE_COD %in% c(30,42,43,44,75)),
         !(FONTE_COD == 60 & UO_COD == 4711),
         !(FONTE_COD %in% 49:50 & ACAO_COD == 7002),
         !(IPU_COD == 9)) 

x %>% 
  filter(is_legislativo(.) | is_tce(.)) %>% 
  summarise(VL_LOA_DESP=sum(VL_LOA_DESP)) %>% 
  as_tibble()

x %>% 
  mutate(ANO = 2020) %>% 
  filter(is_judiciario(.)) %>% 
  summarise(VL_LOA_DESP=sum(VL_LOA_DESP)) %>% 
  as_tibble()

x %>% 
  mutate(ANO = 2020) %>% 
  filter(is_pgj(.)) %>% 
  summarise(VL_LOA_DESP=sum(VL_LOA_DESP)) %>% 
  as_tibble()

x %>% 
  mutate(ANO = 2020) %>% 
  filter(is_executivo(.) | is_def_pub(.)) %>% 
  summarise(VL_LOA_DESP=sum(VL_LOA_DESP)) %>% 
  as_tibble()



# T5 ----------------------------------------------------------------------
pessoal = readxl::read_excel('bancos/SISOR/BASE_CATEGORIA_PESSOAL.xlsx')

pessoal %>% 
  group_by(Classificação) %>% 
  summarise(Quantidade=sum(Quantidade))

pessoal %>% 
  summarise(Quantidade=sum(Quantidade))


# T25 ---------------------------------------------------------------------
desp %>% 
  filter(UO_COD == 1261,
         ACAO_COD %in% c(4299,4306)) %>% 
  select(ACAO_COD, ACAO_DESC)

desp %>% 
  mutate(ANO = 2020) %>% 
  filter(is_dbp(.)) %>% 
  filter(ACAO_COD == 7002, FONTE_COD %in% 49:50, ELEMENTO_COD != 3) %>% 
  summarise(VL_LOA_DESP=sum(VL_LOA_DESP))

desp %>% 
  mutate(ANO = 2020) %>% 
  filter(is_dbp(.), ACAO_COD == 7002, FONTE_COD %in% 49:50) %>% 
  group_by(ELEMENTO_COD) %>%
  summarise(VL_LOA_DESP = sum(VL_LOA_DESP))
