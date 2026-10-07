# Plain checks, run by R CMD check. The groff parts skip themselves when groff can't typeset.
library(knitroff)

dir <- tempfile("knitroff")
dir.create(dir)
doc <- file.path(dir, "t.Rms")
writeLines(c(
  ".PP",
  "Inline: `r 2 + 3`.",
  ".SR mn mean(1:4)",
  "The mean is \\*[mn].",
  ".SS",
  "x <- c(1, -2, 3)",
  "if (TRUE) {",
  "  y <- 'quoted'",
  "}",
  "cat('.starts with a dot', '\\n')",
  "sum(x)",
  ".SE",
  ".SS echo=FALSE",
  "knitroff::roff_table(data.frame(a = 1:2, b = c('p', 'q')), caption = 'T')",
  ".SE"
), doc)

before <- knitr::knit_patterns$get()
ms <- readLines(knit_roff(doc, format = "utf8"))
stopifnot(identical(knitr::knit_patterns$get(), before))     # knitr is left as it was

stopifnot(
  "Inline: 5." %in% ms,
  ".ds mn 2.5" %in% ms,                                          # .SR from spp
  "> x <\\- c(1, \\-2, 3)" %in% ms,                              # ASCII minus in code
  "+   y <\\- \\(aqquoted\\(aq" %in% ms,                          # continuation prompt, ASCII quote
  "\\&.starts with a dot " %in% ms,                              # output can't become a request
  "[1] 2" %in% ms
)
# highlighting: keywords bold, comments italic, back to CR; plain when the chunk says so
stopifnot("> \\f(CBif\\f(CR (\\f(CBTRUE\\f(CR) {" %in% ms)
hl <- file.path(dir, "h.Rms")
writeLines(c(".SS", "x <- NULL  # it's empty", ".SE", ".SS highlight=FALSE", "if (TRUE) 1", ".SE"), hl)
h <- readLines(knit_roff(hl, format = "utf8"))
stopifnot("> x <\\- \\f(CBNULL\\f(CR  \\f(CI# it\\(aqs empty\\f(CR" %in% h,
          "> if (TRUE) 1" %in% h)
h <- readLines(knit_roff(hl, format = "utf8", highlight = FALSE))
stopifnot(!any(grepl("\\f(C[BI]", h, fixed = TRUE)))

# no blank lines after chunks: troff reads one as .sp, and at a page's foot it starts a page
stopifnot(!any(ms == ""))
# the code and output of a chunk are one listing
stopifnot(sum(ms == ".DS L") == 1)
# the table goes into the document as troff, untouched
stopifnot(".TS" %in% ms, "a\tb" %in% ms, !any(grepl("\\\\&.TS", ms)))

# R's vignette lines are removed: troff would print them
vig <- file.path(dir, "v.Rms")
writeLines(c("%\\VignetteIndexEntry{V}", "%\\VignetteEngine{knitroff::roff}", ".PP", "text"), vig)
stopifnot(!any(grepl("Vignette", readLines(knit_roff(vig, format = "utf8")))))

# the R code of a document, for vignettes
code <- readLines(knitroff:::tangle_roff(doc))
stopifnot(code[1] == "x <- c(1, -2, 3)", length(code) == 7)

# the RStudio addin's chunk: wrap a selection, fill a blank line, or go below text
ci <- knitroff:::chunk_insert
stopifnot(identical(ci(c("a", "b"), 1, 2, TRUE), list(text = c(".SS", "a", "b", ".SE"), cursor = 2)),
          identical(ci(c("x", ""), 2, 2, FALSE), list(text = c(".SS", "", ".SE"), cursor = 3)),
          identical(ci(c(".PP", ""), 1, 1, FALSE), list(text = c(".PP", ".SS", "", ".SE"), cursor = 3)))

# a groff without the ms macros, like Debian's groff-base, is not enough to typeset
if (.Platform$OS.type == "unix") {
  base <- file.path(dir, "groff-base")
  writeLines(c("#!/bin/sh", "echo \"troff: fatal error: cannot open macro file named in '-m' command-line argument 's'\" >&2", "exit 4"), base)
  Sys.chmod(base, "755")
  stopifnot(!groff_available("utf8", groff = base))
  e <- tryCatch(render_roff(doc, format = "utf8", groff = base), error = conditionMessage)
  stopifnot(grepl("groff-base", e))
}

example <- file.path(dir, "states.Rms")
invisible(file.copy(system.file("examples", "states.Rms", package = "knitroff"), example))
if (groff_available("utf8")) {
  draft <- readLines(render_roff(example, format = "utf8"))
  plain <- gsub("\033\\[[0-9;]*m", "", draft)
  stopifnot(
    any(grepl("Figure 1: paste up scatter-1.pdf here", plain, fixed = TRUE)),
    any(grepl("> life <- state.x77[, \"Life Exp\"]", plain, fixed = TRUE)),
    any(grepl("s sup 2 ~=~ 1 over {n - 1}", plain, fixed = TRUE))
  )
}
if (groff_available("pdf") && nzchar(Sys.which("pdfinfo"))) {        # the example has a figure
  pdf <- render_roff(example, format = "pdf")
  stopifnot(identical(readBin(pdf, "raw", 4), charToRaw("%PDF")))
}
if (groff_available("ps")) {
  # a path with ~, as typed at the console: R expands it, the shell would not in quotes
  Sys.setenv(HOME = dir)
  stopifnot(file.exists(render_roff("~/t.Rms", format = "ps")), file.exists(file.path(dir, "t.ps")))
}
cat("knitroff: tests passed\n")
