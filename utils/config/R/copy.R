suppressPackageStartupMessages(library(gmailr))
source("config/R/helper_copy.R")

arg <- commandArgs(trailingOnly = TRUE)
base <- guess_base(arg)
yml <- yaml::yaml.load_file("config/config.yaml")$copy[[base]]

if(yml$dir == "gmail") {
  copy_gmail(yml$files[[arg]])
} else if(grepl("^3.DCGF", yml$dir)) {
  copy_scppo(yml$files[[arg]], yml$dir)
} else {
  copy_local(yml$files[[arg]], yml$dir)
}

clean_excel(from = yml$files[[arg]], to = make_path(arg))
