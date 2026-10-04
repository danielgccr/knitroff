# A vignette engine, so packages can ship .Rms vignettes: add
#   VignetteBuilder: knitroff
# to DESCRIPTION, and start the vignette with R's lines, at the start of the line:
#   %\VignetteIndexEntry{My report}
#   %\VignetteEngine{knitroff::roff}
# knitroff removes them before knitting; troff would print them.
.onLoad <- function(libname, pkgname) {
  tools::vignetteEngine(
    "roff", package = pkgname, pattern = "[.]Rms$",
    weave = function(file, ...) render_roff(file, format = "pdf"),
    tangle = function(file, ...) tangle_roff(file)
  )
}

# The R code of a document, chunk after chunk: what R CMD check runs from a vignette.
tangle_roff <- function(file) {
  lines <- readLines(file, warn = FALSE)
  inside <- FALSE
  code <- character()
  for (line in lines) {
    if (grepl(roff_patterns$chunk.end, line)) inside <- FALSE
    if (inside) code <- c(code, line)
    if (grepl(roff_patterns$chunk.begin, line)) inside <- TRUE
  }
  output <- sub("\\.[^.]*$", ".R", file)
  writeLines(code, output)
  invisible(output)
}
