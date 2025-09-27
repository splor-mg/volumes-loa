suppressPackageStartupMessages({
  if (!requireNamespace("yaml", quietly = TRUE)) install.packages("yaml", repos = "https://cloud.r-project.org")
  if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes", repos = "https://cloud.r-project.org")
})

args <- commandArgs(trailingOnly = TRUE)
cfg_path <- if (length(args) >= 1) args[1] else Sys.getenv("R_PKGS_CONFIG", unset = "_dev_ploa-2025-checkpacotes_bitbucket_versoes_ultima_ploa.yml")
message("[INFO] Lendo configuração de pacotes em ", cfg_path, " ...")
cfg <- yaml::read_yaml(cfg_path)

repo_base <- cfg$repositorio_base
pkgs <- cfg$pacotes

bb_user <- Sys.getenv("BITBUCKET_AUTH_USER", unset = NA)
bb_pass <- Sys.getenv("BITBUCKET_APP_PASSWORD", unset = NA)

if (is.na(bb_user) || is.na(bb_pass) || nchar(bb_user) == 0 || nchar(bb_pass) == 0) {
  stop("Credenciais Bitbucket ausentes. Defina BITBUCKET_AUTH_USER e BITBUCKET_APP_PASSWORD no ambiente.")
}

install_one <- function(nome, repo, versao) {
  user_enc <- utils::URLencode(bb_user, reserved = TRUE)
  pass_enc <- utils::URLencode(bb_pass, reserved = TRUE)
  url_git <- sprintf("https://%s:%s@%s/%s.git", user_enc, pass_enc, repo_base, repo)
  message(sprintf("[INFO] Instalando %s (%s) de %s ...", nome, versao, repo))
  # Pré-checagem para diagnosticar erros de auth/tag
  chk <- tryCatch({
    system2("git", c("ls-remote", url_git, versao), stdout = TRUE, stderr = TRUE)
  }, error = function(e) e)
  if (inherits(chk, "error")) {
    message(sprintf("[ERRO] git ls-remote falhou para %s %s: %s", repo, versao, chk$message))
  }
  remotes::install_git(url_git, ref = versao, upgrade = "never", quiet = TRUE)
}

ok <- TRUE
for (p in pkgs) {
  tryCatch({
    install_one(p$nome, p$repo, p$versao)
  }, error = function(e) {
    message(sprintf("[ERRO] Falha ao instalar %s: %s", p$nome, e$message))
    ok <<- FALSE
  })
}

if (!ok) quit(status = 1) else message("[OK] Pacotes instalados com sucesso.")





