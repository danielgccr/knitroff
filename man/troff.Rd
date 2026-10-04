\name{troff}
\alias{troff}
\alias{roff}
\alias{groff}
\alias{troff-requests}
\title{troff requests, escapes and characters for knitroff documents}
\description{
Below the ms macros (\code{\link{ms}}), a knitroff document is plain troff: requests on lines that begin with a dot, and escapes that begin with a backslash. This page covers what reports need, following groff(7) and groff_char(7) for groff 1.24.1.
}
\section{Writing troff text}{
\describe{
\item{requests}{a line beginning with \verb{.} or \verb{'} is a request or a macro call, such as \verb{.PP}. To begin a text line with either character, put \verb{\\&} (a zero-width character) before it.}
\item{escapes}{a backslash begins an escape, such as \verb{\\fB}. Write a literal backslash as \verb{\\e} or \verb{\\[rs]}.}
\item{breaks}{a blank line, or a line beginning with a space, breaks the paragraph. In filled text, start each sentence on a new line: troff then puts the right space after its period.}
\item{comments}{\verb{.\\"} begins a comment line; \verb{\\"} begins a comment at the end of a line.}
\item{knitroff}{inline results (\verb{`r expr`}) and \verb{.SR} strings are escaped for you; output in listings is too.}
}
}

\section{Requests}{
ms resets indentation, line length and type size at each paragraph and heading, so inside an ms document prefer its own macros and registers (\verb{.RS}, \verb{\\n[LL]}, \verb{.LG}) to \verb{.in}, \verb{.ll} and \verb{.ps}.
\tabular{ll}{
\verb{.br} \tab break the output line \cr
\verb{.sp [N]} \tab break, and space down N (default one line) \cr
\verb{.bp} \tab begin a new page \cr
\verb{.ne N} \tab begin a new page unless N of space remains \cr
\verb{.ce [N]} \tab centre the next N input lines (default 1); \verb{.ce 0} stops \cr
\verb{.nf}, \verb{.fi} \tab no filling (lines as in the source) / filling again \cr
\verb{.ad [l|r|c|b]}, \verb{.na} \tab adjust lines left, right, centre or both margins / no adjustment \cr
\verb{.ft F} \tab change to font F: R, I, B, BI, CR (constant width), or P (previous) \cr
\verb{.ps N} \tab type size N points; \verb{.ps +2} larger \cr
\verb{.vs N} \tab vertical spacing (baseline to baseline) \cr
\verb{.ll N} \tab line length \cr
\verb{.in N}, \verb{.ti N} \tab indentation / indentation of the next line only \cr
\verb{.po N}, \verb{.pl N} \tab page offset (left margin) / page length \cr
\verb{.ta N ...} \tab tab stops, such as \verb{.ta 1i 2i} or \verb{.ta 2iR} (right-aligned) \cr
\verb{.tl 'l'c'r'} \tab a three-part title line \cr
\verb{.hy [N]}, \verb{.nh} \tab hyphenation on / off \cr
\verb{.ul [N]} \tab underline (italic in troff) the next N lines \cr
\verb{.ds name text} \tab define a string, used as \verb{\\*[name]}; a leading \verb{"} keeps leading spaces \cr
\verb{.nr name N} \tab set a number register, used as \verb{\\n[name]} \cr
\verb{.de name} ... \verb{..} \tab define a macro; its arguments are \verb{\\\\$1}, \verb{\\\\$2} ... \cr
\verb{.so file} \tab read in another file here \cr
\verb{.ig} ... \verb{..} \tab ignore input up to \verb{..}
}
}

\section{Escapes}{
\tabular{ll}{
\verb{\\fB}, \verb{\\fI}, \verb{\\fR}, \verb{\\fP} \tab bold, italic, roman, previous font; \verb{\\f(CR} or \verb{\\f[CR]} constant width \cr
\verb{\\s+2}, \verb{\\s-2}, \verb{\\s0} \tab type size up, down, back to the previous \cr
\verb{\\*x}, \verb{\\*(xx}, \verb{\\*[name]} \tab the string x, xx, or name; \verb{.SR} defines them \cr
\verb{\\nx}, \verb{\\n(xx}, \verb{\\n[name]} \tab the value of a register; \verb{\\n[\%]} is the page number \cr
\verb{\\(xx}, \verb{\\[name]} \tab a special character, such as \verb{\\(em} (below) \cr
\verb{\\e} \tab a backslash \cr
\verb{\\-} \tab a minus sign. knitroff writes the - of code this way, so groff does not set it as a hyphen; in the terminal draft it is the ASCII - \cr
\verb{\\&} \tab nothing, zero width: protects a leading . or ' \cr
\verb{\\~}, \verb{\\ } (backslash, space) \tab an unbreakable space, adjustable / of fixed width \cr
\verb{\\0}, \verb{\\|}, \verb{\\^} \tab spaces the width of a digit, 1/6 em, 1/12 em \cr
\verb{\\u}, \verb{\\d} \tab up / down half an em, for simple super- and subscripts \cr
\verb{\\v'N'}, \verb{\\h'N'} \tab move vertically (down if positive) / horizontally \cr
\verb{\\l'N'}, \verb{\\L'N'} \tab draw a horizontal / vertical line of length N \cr
\verb{\\w'text'} \tab the width of text, for use in measurements \cr
\verb{\\z}c \tab print c without moving: zero width \cr
\verb{\\c} \tab join the next input line to this one \cr
\verb{\\\%} \tab a hyphenation point; at the start of a word, do not hyphenate it \cr
\verb{\\"} \tab a comment, to the end of the line
}
}

\section{Units}{
Measurements take a unit after the number, as in \verb{.sp 0.5v} or \verb{.in 2n}.
\tabular{ll}{
\verb{i}, \verb{c}, \verb{p}, \verb{P} \tab inch, centimetre, point (1/72 inch), pica (12 points) \cr
\verb{m}, \verb{n} \tab em and en: the width of M and half of it, at the current type size \cr
\verb{v} \tab one line of vertical spacing (a "vee") \cr
\verb{u} \tab the device's basic unit
}
Without a unit, \verb{.sp} and \verb{.ne} count lines (v), \verb{.ps} and \verb{.vs} points, and most other requests ems.
}

\section{Special characters}{
UTF-8 input works (knitroff runs groff with \verb{-k}), but these names are portable to any troff and to the terminal. Write \verb{\\(xx} for two-character names or \verb{\\[name]} for any.
\tabular{llll}{
\verb{\\(em} \tab em dash \tab \verb{\\(en} \tab en dash \cr
\verb{\\(hy} \tab hyphen \tab \verb{\\(mi} \tab minus \cr
\verb{\\(bu} \tab bullet \tab \verb{\\(de} \tab degree \cr
\verb{\\(co}, \verb{\\(rg}, \verb{\\(tm} \tab copyright, registered, trademark \tab \verb{\\(sc} \tab section \cr
\verb{\\(dg}, \verb{\\(dd} \tab dagger, double dagger \tab \verb{\\(ct}, \verb{\\(Po}, \verb{\\(Eu} \tab cent, pound, euro \cr
\verb{\\(mu}, \verb{\\(di} \tab times, divide \tab \verb{\\(+-} \tab plus or minus \cr
\verb{\\(<=}, \verb{\\(>=} \tab less, greater or equal \tab \verb{\\(!=}, \verb{\\(==}, \verb{\\(~=} \tab not equal, equivalent, approximately \cr
\verb{\\(->}, \verb{\\(<-} \tab arrows \tab \verb{\\(if}, \verb{\\(pd}, \verb{\\(gr} \tab infinity, partial, gradient \cr
\verb{\\(sr}, \verb{\\(is} \tab square root, integral \tab \verb{\\(sq}, \verb{\\(ci} \tab square, circle \cr
\verb{\\(lq}, \verb{\\(rq} \tab double quotes \tab \verb{\\(oq}, \verb{\\(cq} \tab single quotes \cr
\verb{\\(aq}, \verb{\\(dq} \tab ASCII ' and " \tab \verb{\\(ga}, \verb{\\(ha}, \verb{\\(ti} \tab ASCII `, ^, ~ \cr
\verb{\\(rs}, \verb{\\(sl} \tab backslash, slash \tab \verb{\\(fm} \tab prime (foot mark) \cr
\verb{\\(*a} ... \verb{\\(*w} \tab Greek alpha to omega \tab \verb{\\(*A} ... \verb{\\(*W} \tab capital Greek
}
The full list is in \verb{man groff_char}.
}

\seealso{
\code{\link{ms}}, \code{\link{eqn}}, \code{\link{tbl}}. In a terminal: \code{man 7 groff}, \code{man groff_char}, \code{info groff}.
}
