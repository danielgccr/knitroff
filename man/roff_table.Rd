\name{roff_table}
\alias{roff_table}
\title{A data frame as a tbl table}
\description{
Returns troff for the tbl preprocessor, a centred, boxed table with a bold header and
numeric columns aligned, to be set when the document goes through \code{groff -t}
(which \code{\link{render_roff}} does). Make it the value of a chunk.
}
\usage{
roff_table(x, caption = NULL, digits = getOption("digits"))
}
\arguments{
\item{x}{A data frame or matrix.}
\item{caption}{Optional caption, set in bold, centred above the table.}
\item{digits}{Significant digits for numeric columns.}
}
\value{Troff text marked to go into the document as is.}
\examples{
cat(roff_table(head(mtcars[, 1:3]), caption = "Three columns of mtcars"))
}
