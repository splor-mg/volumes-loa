# ===================================================
# Gera os targets dos PDF das tabelas do volume 1 que eram responsabilidade da PRODEMGE

pdfs_dcgf = gsub("^(T\\d+([A-B])*_DCGF.+)\\.Rnw$", "\\1", dir("volume1/Rnw")[grepl("^T\\d+([A-B])*_DCGF.+", dir("volume1/Rnw"))])

arquivos = paste0("pdf/", pdfs_dcgf, ".pdf")

write(arquivos, file = stdout())
