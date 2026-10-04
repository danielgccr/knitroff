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

In RStudio, the Addins menu has \emph{Insert troff chunk} and \emph{Render troff document},
which stand in for Insert Chunk and the Knit button in \code{.Rms} files. Give them keys in
Tools > Modify Keyboard Shortcuts. They need the \pkg{rstudioapi} package.
}
\seealso{
The reference for writing documents: \code{\link{ms}} (the ms macros, such as \verb{.PP}),
\code{\link{troff}} (requests, escapes, units and special characters), \code{\link{eqn}}
(equations) and \code{\link{tbl}} (tables).

The example report: \code{system.file("examples", "states.Rms", package = "knitroff")}.
}
