\name{render_roff}
\alias{render_roff}
\title{Knit an R troff document and typeset it with groff}
\description{
Knits the document with \code{\link{knit_roff}}, then runs
\code{groff -ms -k -e -t -p}: the ms macros, UTF-8 input, and the eqn, tbl and pic
preprocessors.
}
\usage{
render_roff(input, output = NULL, format = c("pdf", "ps", "utf8"), highlight = TRUE,
            groff = "groff")
}
\arguments{
\item{input}{Path of the document, usually \file{.Rms}.}
\item{output}{Path of the result. By default \code{input} with extension \file{.pdf},
\file{.ps} or \file{.txt}.}
\item{format}{\code{"pdf"}, \code{"ps"}, or \code{"utf8"}: the draft for a terminal, as
nroff gave, to read with \code{less -R}.}
\item{highlight}{Passed to \code{\link{knit_roff}}: bold keywords and italic
comments in the listings, or plain with \code{FALSE}.}
\item{groff}{The groff program.}
}
\details{
Needs GNU groff. PDF output uses groff's \code{gropdf}; figures in it need \code{pdfinfo}
from poppler, and groff runs with \code{-U} because \code{.PDFPIC} asks \code{pdfinfo} for
each picture's size. A terminal cannot set equations, so the \code{"utf8"} draft shows
their eqn source, which was designed to read the way it is spoken.

On Windows, groff comes from MSYS2: in the Rtools45 bash shell, \verb{pacman -Sy groff}.
Check with \code{Sys.which("groff")}, or pass the path to \code{groff.exe} as \code{groff}.
\code{pdfinfo}, for figures in PDF, is not in the part of MSYS2 that Rtools allows; the
package README describes other ways to get it.
}
\value{The path of the result, invisibly.}
\examples{
if (nzchar(Sys.which("groff"))) {
  doc <- file.path(tempdir(), "states.Rms")
  file.copy(system.file("examples", "states.Rms", package = "knitroff"), doc, overwrite = TRUE)
  draft <- render_roff(doc, format = "utf8")
  cat(head(readLines(draft), 40), sep = "\n")
}
}
