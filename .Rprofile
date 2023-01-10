setHook("rstudio.sessionInit", function(new_session) {
  if (new_session && is.null(rstudioapi::getActiveProject()))
    rstudioapi::openProject("LOA.Rproj")
}, action = "append")
