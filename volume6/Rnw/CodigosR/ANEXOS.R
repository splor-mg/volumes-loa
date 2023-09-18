# INICIO TABELA 
 
cat("\\footnotesize\n") 
 
cat("\\renewcommand*{\\arraystretch}{2}\n") 
grupo_despesa <- data.table(read_excel(paste0(dir_bancos, "/manual/desc_grupos_de_despesa.xlsx"), sheet = 1))[order(CODIGO)] 
fontes <- data.table(read_excel(paste0(dir_bancos, "/manual/desc_fontes_de_recursos_stn.xlsx"), sheet = 1))[order(CODIGO)] 
iag <- data.table(read_excel(paste0(dir_bancos, "/manual/desc_IAG.xlsx"), sheet = 1))[order(CODIGO)] 
ipu <- data.table(read_excel(paste0(dir_bancos, "/manual/desc_IPU.xlsx"), sheet = 1))[order(CODIGO)] 
 
cat("\\noindent\\begin{longtable}[c]{m{1cm}|m{11cm}}\n") # Inicia-se a tabela 
# Titulo 
titulo <- paste0( 
  "\\multicolumn{2}{c}{\\cellcolor{gray!50} \\textcolor{red} {\\normalsize \\textbf{", 
  "GRUPOS DE DESPESA}}}\\Tstrut  \\\\[2ex]\n" 
) 
cabecalho <- "\\multicolumn{1}{c|}{\\textbf{CÓDIGO}} & \\multicolumn{1}{c}{\\textbf{ESPECIFICAÇÃO}} \\\\\n" 
 
cat(titulo) 
cat("\\hline\\hline\n") 
# Cabeçalho de variáveis 
cat(cabecalho) 
cat("\\hline\n") 
cat("\\endfirsthead\n") # Indica o fim do primeiro header da tabela (presente no ínicio da tabela) 
 
# titulo 
cat(titulo) 
cat("\\hline\\hline\n") 
# Cabeçalho de variáveis 
cat(cabecalho) 
cat("\\hline\n") 
cat("\\endhead\n") # Fim do header que acompanha as n páginas que a tabela ocupa, sendo n diferente de 1 
cat("\\endfoot\n") # Fim do notapé do ínicio da tabela 
 
cat("\\hline\\hline\\hline\n") 
cat("\\endlastfoot\n") # Fim do notapé das n páginas que a tabela ocupa, sendo n diferente de 1 
 
# Linhas da tabela 
 
for (i in 1:nrow(grupo_despesa)) { 
  cat("\\multicolumn{1}{c|}{", grupo_despesa[i, CODIGO], "} &", toupper(grupo_despesa[i, ESPECIFICACAO]), "\\\\\n") 
} 
 
cat("\\end{longtable}\n") # Fim da tabela 
 
 
cat("\\noindent\\begin{longtable}[c]{m{1cm}|m{11cm}}\n") # Inicia-se a tabela 
# Titulo 
titulo <- paste0( 
  "\\multicolumn{2}{c}{\\cellcolor{gray!50} \\textcolor{red} {\\normalsize \\textbf{", 
  "FONTES DE RECURSOS}}}\\Tstrut  \\\\[2ex]\n" 
) 
cabecalho <- "\\multicolumn{1}{c|}{\\textbf{CÓDIGO}} & \\multicolumn{1}{c}{\\textbf{ESPECIFICAÇÃO}} \\\\\n" 
 
cat(titulo) 
cat("\\hline\\hline\n") 
# Cabeçalho de variáveis 
cat(cabecalho) 
cat("\\hline\n") 
cat("\\endfirsthead\n") # Indica o fim do primeiro header da tabela (presente no ínicio da tabela) 
 
# titulo 
cat(titulo) 
cat("\\hline\\hline\n") 
# Cabeçalho de variáveis 
cat(cabecalho) 
cat("\\hline\n") 
cat("\\endhead\n") # Fim do header que acompanha as n páginas que a tabela ocupa, sendo n diferente de 1 
cat("\\endfoot\n") # Fim do notapé do ínicio da tabela 
 
cat("\\hline\\hline\\hline\n") 
cat("\\endlastfoot\n") # Fim do notapé das n páginas que a tabela ocupa, sendo n diferente de 1 
 
# Linhas da tabela 
 
for (i in 1:nrow(fontes)) { 
  cat("\\multicolumn{1}{c|}{", fontes[i, CODIGO], "} &", toupper(fontes[i, CLASSIFICACAO]), "\\\\\n") 
} 
 
cat("\\end{longtable}\n") # Fim da tabela 
 
 
# COMEÇO DA TABELA IDENTIFICADORES DE PROCEDENCIA E USO 
 
cat("\\noindent\\begin{longtable}[c]{m{1cm}|m{14cm}}\n") 
 
cat( 
  "\\multicolumn{2}{c}{\\cellcolor{gray!50} \\textcolor{red} {\\normalsize \\textbf{", 
  "IDENTIFICADORES DE PROCEDÊNCIA E USO}}}\\Tstrut  \\\\[2ex]\n" 
) 
cat("\\hline\\hline\n") 
cat("\\multicolumn{1}{c|}{\\textbf{CÓDIGO}} & \\multicolumn{1}{c}{\\textbf{ESPECIFICAÇÃO}} \\\\\n") 
cat("\\hline\n") 
cat("\\endfirsthead\n") 
cat("\\hline\n") 
cat("\\endhead\n") 
cat("\\endfoot\n") 
 
cat("\\hline\\hline\\hline\n") 
cat("\\endlastfoot\n") 
 
for (i in 1:nrow(ipu)) { 
  cat("\\multicolumn{1}{c|}{", ipu[i, CODIGO], "} &", toupper(ipu[i, ESPECIFICACAO]), "\\\\\n") 
} 
 
cat("\\end{longtable}\n") 
cat("\\newpage\n") 
 
 
# COMEÇO DA TABELA DE IDENTIFICADORES DE AçÃO GOVERNAMENTAL 
 
cat("\\noindent\\begin{longtable}[c]{m{1cm}|m{11cm}}\n") 
 
cat( 
  "\\multicolumn{2}{c}{\\cellcolor{gray!50} \\textcolor{red} {\\normalsize \\textbf{", 
  "IDENTIFICADORES DE AÇÃO GOVERNAMENTAL}}}\\Tstrut  \\\\[2ex]\n" 
) 
cat("\\hline\\hline\n") 
cat("\\multicolumn{1}{c|}{\\textbf{CÓDIGO}} & \\multicolumn{1}{c}{\\textbf{ESPECIFICAÇÃO}} \\\\\n") 
 
cat("\\hline\n") 
cat("\\endfirsthead\n") 
cat("\\hline\n") 
cat("\\endhead\n") 
cat("\\endfoot\n") 
cat("\\hline\\hline\\hline\n") 
cat("\\endlastfoot\n") 
 
for (i in 1:nrow(iag)) { 
  cat("\\multicolumn{1}{c|}{", iag[i, CODIGO], "} &", toupper(iag[i, INTERPRETACAO]), "\\\\\n") 
} 
 
cat("\\end{longtable}\n") 
 
# FIM TABELA 
