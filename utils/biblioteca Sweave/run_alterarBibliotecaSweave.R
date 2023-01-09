# Objetivo: retirar a biblioteca ae (almost European) de Sweave.sty. Essa bilioteca que gera o problema de busca
# e copiar/colar dos caracteres com acento, conforme descrevi em 
# http://stackoverflow.com/questions/34729509/rsweave-how-to-copy-paste-from-pdf-to-notepad-avoiding-error/37393528

### Recomendável:
# Ir no console R e executar > R.home()
# Resultado "C:/Users/m1312932/DOCUME~1/R/R-31~1.2" equivale a "C:\Users\m1312932\Documents\R\R-3.1.2"
# Ir em "C:\Users\m1312932\Documents\R\R-3.1.2\share\texmf\tex\latex" e fazer um backup do arquivo Sweave.sty
# Na perspectiva que o código abaixo apresente um erro inesperado, há um arquivo backup de Sweave.sty

script = readLines(paste(R.home(), "/share/texmf/tex/latex/Sweave.sty",sep=""), warn=FALSE)  

indice = which(grepl("^(?!\\%) *\\\\RequirePackage{ae} *", script, perl=T))

if(length(indice)>0){

sink(paste(R.home(), "/share/texmf/tex/latex/Sweave.sty",sep=""))

for(i in 1:length(script)){
  if(i==indice){
    cat("%", script[i], "\n")
    cat("\\RequirePackage{helvet} \n")
    cat("\\renewcommand{\\familydefault}{\\sfdefault} \n")
  } else{
    cat(script[i], "\n")
    }
  }
  sink()
  print(paste("Codigo R salvo em ", R.home(), "/share/texmf/tex/latex/Sweave.sty",sep=""))
} else{
  print("Biblioteca 'ae' (almost European) nao interfere no codigo. (possivelmente está comentada)")
}