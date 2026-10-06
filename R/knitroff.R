#' Chunks in a troff document: `.SS options` ... `.SE`, and inline `` `r expr` ``.
roff_patterns <- list(
  chunk.begin = "^\\.SS\\s*(.*)$",
  chunk.end = "^\\.SE\\s*$",
  inline.code = "`r +([^`]+)`"
)

# Make text safe for troff: a backslash prints as \e, a line starting with . or ' gets \&.
roff_escape <- function(x) {
  x <- gsub("\\", "\\e", x, fixed = TRUE)
  sub("^([.'])", "\\\\&\\1", x)
}

state <- new.env()      # the figure count of the document being knitted
TAG <- "\001"           # marks listing lines until the chunk hook gathers them
ASIS <- ".\\\" knitroff: as is"   # first line of output that goes into the document untouched

# Code must keep its ASCII: groff would print - as a hyphen, ' and ` as quotes,
# ^ and ~ as accents. These are the characters a reader can paste back into R.
code_escape <- function(x) {
  x <- roff_escape(x)
  x <- gsub("-", "\\-", x, fixed = TRUE)
  x <- gsub("'", "\\(aq", x, fixed = TRUE)
  x <- gsub("`", "\\(ga", x, fixed = TRUE)
  x <- gsub("^", "\\(ha", x, fixed = TRUE)
  gsub("~", "\\(ti", x, fixed = TRUE)
}

lines_of <- function(x) unlist(strsplit(paste(x, collapse = "\n"), "\n", fixed = TRUE))

tagged <- function(lines, escape = code_escape) paste0(paste0(TAG, escape(lines), collapse = "\n"), "\n")

# Highlighting in the style of printed listings: keywords in bold, comments in italic, in
# groff's constant-width bold and italic (CB, CI). R's own parser finds the tokens.
BOLD <- c("FUNCTION", "IF", "ELSE", "WHILE", "FOR", "IN", "BREAK", "REPEAT", "NEXT", "NULL_CONST")
BOLD_WORDS <- c("TRUE", "FALSE", "NA", "Inf", "NaN")

highlighted <- function(expr) {
  lines <- lines_of(expr)
  data <- tryCatch(utils::getParseData(parse(text = expr, keep.source = TRUE)), error = function(e) NULL)
  style <- lapply(nchar(lines), function(n) rep("", n))      # one font per character
  if (!is.null(data)) {
    data <- data[data$terminal, ]
    font <- ifelse(data$token %in% BOLD | data$text %in% BOLD_WORDS, "CB",
                   ifelse(data$token == "COMMENT", "CI", ""))
    for (k in which(nzchar(font) & data$line1 == data$line2)) {
      l <- data$line1[k]
      cols <- intersect(data$col1[k]:data$col2[k], seq_along(style[[l]]))
      style[[l]][cols] <- font[k]
    }
  }
  mapply(function(line, st) {
    if (!nzchar(line)) return("")
    chars <- strsplit(line, "")[[1]]
    runs <- rle(st)
    ends <- cumsum(runs$lengths)
    paste0(vapply(seq_along(ends), function(r) {
      text <- code_escape(paste(chars[(ends[r] - runs$lengths[r] + 1):ends[r]], collapse = ""))
      if (nzchar(runs$values[r])) paste0("\\f(", runs$values[r], text, "\\f(CR") else text
    }, ""), collapse = "")
  }, lines, style, USE.NAMES = FALSE)
}

# Source as S showed it, "> " on an expression's first line and "+ " on the rest:
# highlighted, or plain as in 1981 when highlight=FALSE.
source_lines <- function(x, highlight) {
  unlist(lapply(x, function(expr) {
    body <- if (isTRUE(highlight)) highlighted(expr) else code_escape(lines_of(expr))
    paste0(c("> ", rep("+ ", length(body) - 1)), body)
  }))
}

# A chunk's prompts and output become one listing: no fill, constant width, kept on one
# page. Figures and tables between them stay outside it.
gather <- function(x) {
  lines <- lines_of(x)
  lines <- lines[nzchar(lines)]
  listing <- startsWith(lines, TAG)
  runs <- rle(listing)
  out <- character()
  end <- cumsum(runs$lengths)
  for (k in seq_along(end)) {
    part <- lines[(end[k] - runs$lengths[k] + 1):end[k]]
    out <- c(out, if (runs$values[k]) c(".DS L", ".ft CR", substring(part, 2), ".ft", ".DE") else part)
  }
  paste(out, collapse = "\n")  # knitr ends the line; a blank line would be troff's .sp
}

#' Set knitr's hooks to write troff
#'
#' @return Invisibly, the hooks that were replaced.
#' @export
hooks_roff <- function() {
  old <- knitr::knit_hooks$get()
  out <- function(x, options) {
    if (startsWith(x, ASIS)) x else tagged(lines_of(sub("\n$", "", x)))
  }
  knitr::knit_hooks$set(
    source = function(x, options) tagged(source_lines(x, options$highlight), escape = identity),
    output = out, warning = out, message = out, error = out,
    plot = roff_plot,
    inline = function(x) {
      if (is.numeric(x)) x <- format(x, digits = getOption("digits"))
      roff_escape(paste(x, collapse = ", "))
    },
    chunk = function(x, options) gather(x)
  )
  invisible(old)
}

# Figures: groff includes PDF in PDF output and EPS in PostScript. A terminal can show no
# picture, so the draft leaves a box to paste the figure into, as authors once did.
roff_plot <- function(x, options) {
  width <- if (is.null(options$out.width)) paste0(options$fig.width * 0.75, "i") else options$out.width
  number <- state$figures <- state$figures + 1
  caption <- if (length(options$fig.cap)) paste0("Figure ", number, ". ", options$fig.cap)
  format <- knitr::opts_knit$get("roff.format")
  picture <- if (identical(format, "pdf")) {
    sprintf(".PDFPIC -C %s %s", x, width)
  } else if (identical(format, "ps")) {
    sprintf(".PSPIC -C %s %s", x, width)
  } else {
    box <- paste0("Figure ", number, ": paste up ", basename(x), " here")
    rule <- paste0("+", strrep("-", nchar(box) + 8), "+")
    paste(c(".DS C", ".ft CR", code_escape(c(rule, paste0("|    ", box, "    |"), rule)), ".ft", ".DE"),
          collapse = "\n")
  }
  paste0(c(ASIS, ".sp 0.5", picture, if (length(caption)) c(".ce", paste0("\\fI", roff_escape(caption), "\\fP")),
           ".sp 0.5"), collapse = "\n")
}

#' A data frame as a tbl table
#'
#' Returns troff for the tbl preprocessor, so the table is set when the document goes
#' through `groff -t` (which [render_roff()] does). Use it as the value of a chunk.
#'
#' @param x A data frame or matrix.
#' @param caption Optional caption, set centred above the table.
#' @param digits Significant digits for numeric columns.
#' @export
roff_table <- function(x, caption = NULL, digits = getOption("digits")) {
  x <- as.data.frame(x)
  cells <- vapply(x, function(col) {
    if (is.numeric(col)) format(col, digits = digits) else as.character(col)
  }, character(nrow(x)))
  cells <- matrix(roff_escape(trimws(cells)), nrow = nrow(x))
  head <- roff_escape(names(x))
  align <- ifelse(vapply(x, is.numeric, logical(1)), "n", "l")
  rows <- apply(cells, 1, paste, collapse = "\t")
  text <- c(
    ASIS, ".sp 0.5", ".ft R",            # a table after a -ms heading would otherwise stay bold
    if (length(caption)) c(".ce", paste0("\\fB", roff_escape(caption), "\\fP"), ".sp 0.3"),
    ".TS", "center box tab(\t);",
    paste(rep("cB", ncol(x)), collapse = " "),
    paste0(paste(align, collapse = " "), "."),
    paste(head, collapse = "\t"), "_", rows, ".TE"
  )
  knitr::asis_output(paste0(paste(text, collapse = "\n"), "\n"))
}

# .SR name expr, from spp, becomes .ds name with the value of expr: the string \*[name].
sr_requests <- function(lines) {
  sub("^\\.SR\\s+(\\S+)\\s+(.*)$", ".ds \\1 `r \\2`", lines)
}

#' Knit an R troff document
#'
#' Runs the R chunks of a troff document (`.SS` ... `.SE`, inline `` `r expr` ``,
#' `.SR name expr`) and writes plain troff, ready for groff with the `-ms` macros.
#'
#' @param input Path to the document, usually `.Rms`.
#' @param output Path of the troff file; by default `input` with extension `.ms`.
#' @param format The output the figures are for: `"pdf"`, `"ps"` or `"utf8"`.
#' @param highlight Set keywords in bold and comments in italic in the listings; a chunk
#'   can still choose with `.SS highlight=FALSE` or `TRUE`.
#' @param quiet Passed to [knitr::knit()].
#' @return The path of the troff file, invisibly.
#' @export
knit_roff <- function(input, output = NULL, format = c("pdf", "ps", "utf8"), highlight = TRUE,
                      quiet = TRUE) {
  format <- match.arg(format)
  if (is.null(output)) output <- sub("\\.[^.]*$", ".ms", input)
  stem <- sub("\\.[^.]*$", "", basename(input))

  old_patterns <- knitr::knit_patterns$get()
  old_hooks <- hooks_roff()
  old_chunk <- knitr::opts_chunk$get()
  old_knit <- knitr::opts_knit$get()
  on.exit({
    knitr::knit_patterns$restore(old_patterns)
    knitr::knit_hooks$restore(old_hooks)
    knitr::opts_chunk$restore(old_chunk)
    knitr::opts_knit$restore(old_knit)
  }, add = TRUE)

  state$figures <- 0
  knitr::knit_patterns$restore(roff_patterns)
  knitr::opts_knit$set(out.format = "roff", roff.format = format)
  knitr::opts_chunk$set(
    comment = "", fig.path = file.path(dirname(output), paste0(stem, "-figures"), ""),
    dev = switch(format, pdf = "pdf", ps = "postscript", utf8 = "pdf"),
    fig.width = 6, fig.height = 4.5, highlight = highlight
  )
  text <- readLines(input, warn = FALSE, encoding = "UTF-8")
  text <- sr_requests(text[!grepl("^\\s*%\\s*\\\\Vignette", text)])   # R's vignette lines, not troff
  preamble <- c(".\\\" troff from knitroff: groff -ms -k -e -t -p",
                ".if n .ftr CR R",               # a terminal has one width of type:
                ".if n .ftr CB B",               # its bold and underlining stand for
                ".if n .ftr CI I",               # constant-width bold and italic
                ".if n .char \\- \\N'45'")         # and code needs the ASCII minus, not U+2212
  body <- knitr::knit(text = text, quiet = quiet, envir = new.env(parent = globalenv()))
  if (format == "utf8") body <- eqn_source(body)
  writeLines(c(preamble, body), output, useBytes = TRUE)
  invisible(output)
}

# A terminal cannot set an equation: groff's tty driver drops eqn's half-line motions. The
# draft shows the eqn source instead, which was designed to read the way it is spoken.
eqn_source <- function(body) {
  lines <- lines_of(body)
  start <- grep("^\\.EQ", lines)
  end <- grep("^\\.EN", lines)
  for (k in rev(seq_along(start))) {
    i <- start[k]
    j <- end[end > i][1]
    if (is.na(j)) next
    eq <- trimws(lines[seq_len(j - i - 1) + i])
    lines <- c(lines[seq_len(i - 1)], ".DS C", ".ft CR", code_escape(eq[nzchar(eq)]), ".ft", ".DE",
               lines[-seq_len(j)])
  }
  paste(lines, collapse = "\n")
}

#' Knit an R troff document and typeset it with groff
#'
#' @inheritParams knit_roff
#' @param output Path of the result; by default `input` with extension `.pdf`, `.ps` or `.txt`.
#' @param groff The groff program.
#' @return The path of the result, invisibly.
#' @details PDF output needs groff's `gropdf` and, for figures, `pdfinfo`; groff runs with
#'   `-U` because `.PDFPIC` asks `pdfinfo` for the picture size. `"utf8"` is the draft for
#'   a terminal, as nroff gave: read it with `less -R`.
#' @export
render_roff <- function(input, output = NULL, format = c("pdf", "ps", "utf8"), highlight = TRUE,
                        groff = "groff") {
  format <- match.arg(format)
  if (!nzchar(Sys.which(groff))) {
    stop("groff not found: install GNU groff, or use knit_roff() for the troff source alone")
  }
  ext <- c(pdf = ".pdf", ps = ".ps", utf8 = ".txt")[[format]]
  if (is.null(output)) output <- sub("\\.[^.]*$", ext, input)
  output <- path.expand(output)  # the shell quotes it for groff, and won't expand ~ in quotes
  ms <- knit_roff(input, sub("\\.[^.]*$", ".ms", output), format = format, highlight = highlight)
  args <- c("-ms", "-k", if (format != "utf8") "-e", "-t", "-p", if (format == "pdf") "-U", paste0("-T", format), shQuote(ms))
  status <- system2(groff, args, stdout = output)
  if (!identical(status, 0L)) stop("groff failed (exit status ", status, ") on ", ms)
  invisible(output)
}
