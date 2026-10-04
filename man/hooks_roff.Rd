\name{hooks_roff}
\alias{hooks_roff}
\title{Set knitr's output hooks to write troff}
\description{
Installs the hooks \code{\link{knit_roff}} uses, for those who drive
\code{\link[knitr]{knit}} themselves. Set \code{knitr::opts_knit$set(roff.format = "pdf")}
to choose how figures are included.
}
\usage{
hooks_roff()
}
\value{The hooks that were replaced, invisibly, for \code{knitr::knit_hooks$restore()}.}
