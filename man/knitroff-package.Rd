\name{knitroff-package}
\alias{knitroff-package}
\alias{knitroff}
\docType{package}
\title{Dynamic Reports in troff with knitr}
\description{
Write a report in troff with the ms macros and put R code in it between \code{.SS} and
\code{.SE}. \code{\link{knit_roff}} runs the code; \code{\link{render_roff}} typesets the
result with GNU groff as a PDF, a PostScript file, or a draft for the terminal.
The design follows troff's preprocessors, eqn and tbl, which each found their own blocks
in a document and passed the rest through: here, one more preprocessor at the front of the
pipeline, which runs R.
}
\seealso{
The example report: \code{system.file("examples", "states.Rms", package = "knitroff")}.
}
