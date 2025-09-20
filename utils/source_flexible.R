# =================================================================================
# Função para carregar arquivos R de forma flexível (case-insensitive)
# Resolve problemas de case sensitivity entre Windows e Linux/WSL
# =================================================================================

source_flexible <- function(file_path, encoding = "UTF-8", ...) {
  # Tenta diferentes variações de case para o arquivo
  variations <- c(
    file_path,  # Caminho original
    gsub("\\.R$", ".r", file_path),  # .R -> .r
    gsub("\\.r$", ".R", file_path)   # .r -> .R
  )
  
  # Remove duplicatas
  variations <- unique(variations)
  
  # Procura o primeiro arquivo que existe
  for (variation in variations) {
    if (file.exists(variation)) {
      source(variation, encoding = encoding, ...)
      return(invisible(TRUE))
    }
  }
  
  # Se nenhum arquivo foi encontrado, para com erro
  stop("Arquivo não encontrado: ", file_path, 
       "\nTentativas: ", paste(variations, collapse = ", "))
}

# Função para carregar funcoes.R especificamente
source_funcoes <- function(encoding = "UTF-8") {
  source_flexible("utils/funcoes.R", encoding = encoding)
}
