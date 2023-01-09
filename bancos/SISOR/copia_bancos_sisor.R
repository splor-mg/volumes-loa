# Copia bancos do SISOR salvos na pasta '\Downloads'
xpath = list.files('~/../Downloads/', full.names = TRUE, pattern = 'BASE_', ignore.case = FALSE)
xnames = list.files('~/../Downloads/', pattern = 'BASE_', ignore.case = FALSE)
dest = paste0('bancos/SISOR/', xnames)
file.copy(from = xpath, to = dest, overwrite = TRUE)

clean_excel = function(from, to) {
  vbscript = paste("cscript //nologo utils/vbs/clean_excel.vbs", from, to)
  shell(vbscript, mustWork = TRUE)
}

for(d in dest) {
  clean_excel(d, paste0(d, 'x'))
}
