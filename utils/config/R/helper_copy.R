guess_base <- function(x) {
  tokens <- strsplit(x, "_")
  tokens[[1]][2]
}

copy_gmail <- function(file) {
  gmail_auth(secret_file = "~/.gmail/gmailr.json", scope = "full")
  from <- "from:dcgf@planejamento.mg.gov.br"
  filename <- paste0("filename:", file)
  has_attachment <- "has:attachment"
  query <- paste(from, filename, has_attachment)
  
  msgs_id <- id(messages(search = query))
  
  if(length(msgs_id) == 0) {
    stop(paste0("Base ", file," nao encontrada no gmail."), call. = FALSE)
  } 
  cat(paste0("Baixando ", file, "...\n"))
  msgs_date <- lapply(msgs_id, function(id) {
              subject(message(id, format = "metadata"))
              })
  
  names(msgs_date) <- msgs_id
  
  msg_id <- sort(unlist(msgs_date), decreasing = TRUE)[1]
  
  msg_date = gsub(".+_(\\d{4})-(\\d{2})-(\\d{2})-.+", "\\1-\\2-\\3", as.character(msg_id))
  
  if(msg_date != Sys.Date()){
    stop(paste0("Base ", file, " atualizada em ", msg_date, 
                ". Base desatualizada para ", Sys.Date()), call. = FALSE)
  }

  msg <- message(names(msg_id), format = "full")
  
  save_attachments(msg, path = "data-raw")
}

copy_scppo <- function(file, dir) {
  env <- Sys.getenv("PATH_SCPPO")
  if(env == "") {
    stop("A variavel PATH_SCPPO nao esta definida.")
  }
  path <- file.path(env, dir, file)
  copy_file(path)
}

copy_local <- function(file, dir) {
  path <- file.path(dir, file)
  copy_file(path)
}

copy_file <- function(path) {
  if(!file.exists(path)) {
    stop(paste("Arquivo", path, "nao encontrado."))
  }
  cat(paste0("Copiando ", path, "...\n"))
  invisible(file.copy(path, "data-raw/", overwrite = TRUE))
}

make_path <- function(x) {
  tokens <- strsplit(x, "_")
  base <- tokens[[1]][2]
  stem <- paste0(tokens[[1]][-c(1, 2)], collapse = "_")
  paste0(base, "_", stem, ".xlsx")
}

clean_excel <- function(from, to) {
  vbscript <- paste("cscript //nologo code/vbs/clean_excel.vbs", from, to)
  
  shell(vbscript, mustWork = TRUE)
  
  if(from != to) {
    invisible(file.remove(file.path("data-raw/", from)))
  }
}