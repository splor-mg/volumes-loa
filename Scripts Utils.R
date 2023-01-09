library(dplyr)
library(stringr)
library(data.table)

# Count your lines of R code
list.files(path = getwd(), recursive = T, full.names = F) %>%
  str_subset("[.](Rnw|R|txt)$") %>%
  sapply(function(x) x %>% readLines() %>% length()) %>%
  sum()
#-----------------------------------------------------------------------------#

# find the regex in all files in the project and select the lines that contains it
scripts_filenames <- list.files(path = getwd(), pattern = "[.](r|R|Rnw)$", recursive = T, full.names = T)

regex = "(nat\\(|rec_|_rec|rec\\[|cod_receita|receita_cod|receita_|_receita|fonte_cod|[1,7,9][0-9]{12})"
dt = data.table(arquivo="" , linha="", codigo="")


for(i in 1:length(scripts_filenames)){

  txt = readLines( scripts_filenames[i])
  num_lines = grep(pattern = regex, x = txt)
  code = txt[grep(pattern = regex, x = txt)]
  
  app = data.table(arquivo=scripts_filenames[i], linha=num_lines, codigo=code )
  l = list(dt,app)
  dt = rbindlist(l)
  
}


dt[,arquivo:=gsub("C:/Users/andre/OneDrive/SEPLAG/2022/SPLOR/DCPPN/LeiOrcamentariaAnual/", "", dt[,arquivo])]

write.table(dt, file = "receitas.csv", sep = ";", row.names = FALSE, col.names = TRUE, fileEncoding = "UTF-8")


#------------------------------------------------------------------------------#

source("volume1/R/T8_DCGF_RECEITA_CORRENTE_LIQUIDA.R", encoding = "UTF-8")
args <- c("T8_DCGF_RECEITA_CORRENTE_LIQUIDA")

source("volume1/R/T12_DCGF_Demonstrativo_Evolucao_Despesa_Categoria_Economica.R", encoding = "UTF-8")
args <- c("T12_DCGF_Demonstrativo_Evolucao_Despesa_Categoria_Economica")




source("utils/Rnw2Tex.R", encoding = "UTF-8")
