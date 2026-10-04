\name{knit_roff}
\alias{knit_roff}
\title{Knit an R troff document}
\description{
Runs the R code of a troff document and writes plain troff, ready for GNU groff with
the \code{-ms} macros. Code chunks sit between \code{.SS} and \code{.SE}, the way
\code{eqn} blocks sit between \code{.EQ} and \code{.EN}; chunk options follow
\code{.SS}, as in \code{.SS scatter, fig.cap="Income", echo=FALSE}. Inline results are
written \code{`r expr`}, and \code{.SR name expr} defines the troff string
\code{\\*[name]} with the value of \code{expr}.
}
\usage{
knit_roff(input, output = NULL, format = c("pdf", "ps", "utf8"), highlight = TRUE,
          quiet = TRUE)
}
\arguments{
\item{input}{Path of the document, usually \file{.Rms}.}
\item{output}{Path of the troff file. By default \code{input} with extension \file{.ms}.}
\item{format}{What the troff is for: \code{"pdf"} and \code{"ps"} include figures with
\code{.PDFPIC} and \code{.PSPIC}; \code{"utf8"}, the terminal draft, leaves a box to paste
each figure into and shows each equation as its eqn source.}
\item{highlight}{Set R keywords in bold and comments in italic, in the
constant-width bold and italic fonts, as printed listings did. \code{FALSE} gives the
plain listing of 1981. A chunk can choose for itself with \code{.SS highlight=FALSE} or
\code{TRUE}.}
\item{quiet}{Passed to \code{\link[knitr]{knit}}.}
}
\details{
Each chunk becomes one listing in a constant-width font: the code with \code{> } and
\code{+ } prompts, its output under it, kept together on a page. Figures are written to a
directory named after the document. knitr's patterns, hooks and options are restored
afterwards. No groff is needed to knit.
}
\value{The path of the troff file, invisibly.}
\seealso{\code{\link{render_roff}} to typeset the result, \code{\link{roff_table}}.}
\examples{
doc <- file.path(tempdir(), "mean.Rms")
writeLines(c(".PP", "The mean of 1 to 10 is `r mean(1:10)`.",
             ".SS", "x <- 1:10", "summary(x)", ".SE"), doc)
cat(readLines(knit_roff(doc, format = "utf8")), sep = "\n")
}
