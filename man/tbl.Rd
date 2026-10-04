\name{tbl}
\alias{tbl}
\alias{tables}
\title{tbl: tables in knitroff documents}
\description{
tbl, by Mike Lesk, is the troff preprocessor for tables. \code{\link{render_roff}} runs it for every output, the terminal draft included, and \code{\link{roff_table}} writes its input from a data frame. This page follows tbl(1) for groff 1.24.1.
}
\section{A table}{
A table sits between \verb{.TS} and \verb{.TE} and has three parts: options ending in \verb{;}, one format line per row ending in \verb{.}, and the data, one line per row with entries separated by tabs, or here by \verb{@}, which survives copying from this page.
\preformatted{.TS
center box tab(@);
cB cB
l n.
State@Income
_
Alaska@6315
Maine@3694
.TE}
The last format line applies to all remaining rows. \code{\link{roff_table}} writes tables like this from a data frame.
}

\section{Options}{
\tabular{ll}{
\verb{center} \tab centre the table (otherwise it is at the left margin) \cr
\verb{expand} \tab make the table as wide as the line \cr
\verb{box}, \verb{doublebox}, \verb{allbox} \tab a box round the table, a double one, or a box round every entry \cr
\verb{tab(x)} \tab separate entries with x instead of a tab \cr
\verb{linesize(n)} \tab lines n points thick \cr
\verb{delim(xy)} \tab eqn delimiters inside the table \cr
\verb{decimalpoint(c)}, \verb{nospaces}, \verb{nokeep}, \verb{nowarn} \tab (GNU) decimal separator, trim spaces, allow page breaks within rows, quiet
}
}

\section{Format: one letter per column}{
\tabular{ll}{
\verb{l}, \verb{r}, \verb{c} \tab left, right, centred \cr
\verb{n} \tab numbers aligned on the decimal point \cr
\verb{a} \tab left-aligned and indented, for sub-entries \cr
\verb{s} \tab span: the entry to the left extends into this column \cr
\verb{^} \tab span: the entry above extends into this row \cr
\verb{_}, \verb{=} \tab a single or double rule in place of the entry \cr
\verb{|}, \verb{||} \tab a vertical line between columns
}
After the letter, modifiers: \verb{b} bold, \verb{i} italic, \verb{f(CR)} any font, \verb{p12} type size, \verb{w(1i)} minimum width, \verb{e} equal widths, \verb{x} expand this column, \verb{t} top of a vertical span, and a number for the gap to the next column in ens (default 3). Rows of a format can be on separate lines or separated by commas: \verb{cB cB, l n.}
}

\section{Data}{
\describe{
\item{\verb{_}, \verb{=}}{alone on a line, a horizontal rule across the table; alone in an entry, a rule across that cell.}
\item{\verb{\\^}}{in an entry, the entry above spans down into it.}
\item{\verb{T\{} ... \verb{T\}}}{a text block: an entry of several lines, filled.}
\item{\verb{\\&}}{an empty entry made visible, or before a leading . in an entry.}
\item{\verb{.T&}}{a new format for the rows that follow, with no more columns than before.}
\item{\verb{.TS H}, \verb{.TH}}{with ms, the rows before \verb{.TH} repeat at the top of each page the table spans.}
}
}

\seealso{
\code{\link{roff_table}}, \code{\link{ms}}, \code{\link{troff}}, \code{\link{eqn}}. In a terminal: \code{man tbl}; and M. E. Lesk, \emph{Tbl: A Program to Format Tables}, Bell Laboratories, 1976.
}
