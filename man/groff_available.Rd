\name{groff_available}
\alias{groff_available}
\title{Can groff typeset a document here?}
\description{
Runs groff on an empty ms document, with the arguments \code{\link{render_roff}} uses and
without output, and reports whether it succeeded. Finding the groff program is not
enough: Debian's \verb{groff-base}, installed for man pages, has no ms macros and no PDF
driver.
}
\usage{
groff_available(format = c("pdf", "ps", "utf8"), groff = "groff")
}
\arguments{
\item{format}{\code{"pdf"}, \code{"ps"} or \code{"utf8"}, as in \code{\link{render_roff}}.}
\item{groff}{The groff program.}
}
\value{\code{TRUE} or \code{FALSE}.}
\seealso{\code{\link{render_roff}}, which stops with an explanation when this is \code{FALSE}.}
\examples{
groff_available("utf8")
}
