\name{eqn}
\alias{eqn}
\alias{neqn}
\alias{equations}
\title{eqn: equations in knitroff documents}
\description{
eqn, by Brian Kernighan and Lorinda Cherry, is the troff preprocessor for mathematics; its input reads much as the formula is spoken: \verb{x sup 2 over 2}. \code{\link{render_roff}} runs it for PDF and PostScript output. This page follows eqn(1) for groff 1.24.1.
}
\section{Displays and inline equations}{
\describe{
\item{\verb{.EQ} ... \verb{.EN}}{a displayed equation, centred by ms; \verb{.EQ L} left-aligns it, \verb{.EQ I} indents it, and a second argument is a label at the right margin, as in \verb{.EQ C (1)}.}
\item{\verb{delim $$}}{inside an \verb{.EQ} ... \verb{.EN}, makes \verb{$} delimit equations within the text: \verb{the mean $x bar$ is}. \verb{delim off} stops it.}
\item{knitroff}{in the \verb{"utf8"} draft, displayed equations appear as their eqn source, because groff cannot set them on a terminal; inline equations appear between their delimiters.}
}
}

\section{Writing equations}{
eqn reads words separated by spaces; spaces themselves do not show. Braces group: \verb{e sup \{i pi\}}. Quoted text is set as it is, in roman: \verb{"for all"}. \verb{~} is a space and \verb{^} half a space. eqn sets letters in italic and digits, operators and function names such as \verb{sin} in roman, and turns \verb{+ - = <= >=} into their mathematical characters.
\tabular{ll}{
\verb{x sub i}, \verb{x sup 2} \tab subscript, superscript; \verb{x sub i sup 2} both \cr
\verb{a over b} \tab a fraction \cr
\verb{sqrt x} \tab square root \cr
\verb{sum from i=1 to n x sub i} \tab limits under and over \verb{sum}, \verb{prod}, \verb{int}, \verb{lim}, \verb{union}, \verb{inter} \cr
\verb{left ( a over b right )} \tab brackets that grow to fit: ( [ \{ | and their mates, and \verb{left floor}, \verb{ceiling} \cr
\verb{x bar}, \verb{x under}, \verb{x hat}, \verb{x dot}, \verb{x vec} \tab marks over or under x; also \verb{dotdot}, \verb{tilde}, \verb{dyad} \cr
\verb{pile \{ a above b above c \}} \tab a vertical stack; \verb{lpile}, \verb{cpile}, \verb{rpile} align it \cr
\verb{matrix \{ ccol \{ a above b \} ccol \{ c above d \} \}} \tab a matrix of columns; \verb{lcol}, \verb{rcol} align them \cr
\verb{mark}, \verb{lineup} \tab align successive equations at a point, such as their = signs \cr
\verb{roman}, \verb{italic}, \verb{bold}, \verb{fat} \tab the face of the next item; \verb{fat} overstrikes to embolden \cr
\verb{size 12 x}, \verb{size +2 x} \tab type size of the next item \cr
\verb{up n}, \verb{down n}, \verb{fwd n}, \verb{back n} \tab move by n hundredths of an em \cr
\verb{define name "text"} \tab a macro: \verb{define var "x sub i"}; \verb{ndefine} and \verb{tdefine} only for nroff or troff \cr
\verb{gsize n}, \verb{gfont f} \tab the global type size and italic font of equations
}
}

\section{Names eqn knows}{
Greek letters: \verb{alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu nu xi omicron pi rho sigma tau upsilon phi chi psi omega}; spelled with a capital (\verb{Gamma}) or in capitals (\verb{GAMMA}) for uppercase.

Symbols and functions: \verb{inf partial grad del prime approx times nothing ... half}, \verb{== != += -> <- << >>}, and \verb{sin cos tan sinh cosh tanh arc exp log ln lim max min det Re Im and for if}.

Added by GNU eqn: \verb{cdot cdots ldots utilde dollar}, and the primitives \verb{accent uaccent big smallover vcenter split nosplit opprime type chartype set reset grfont gifont gbfont}.
}

\seealso{
\code{\link{ms}}, \code{\link{troff}}, \code{\link{tbl}}. In a terminal: \code{man eqn}; and B. W. Kernighan and L. L. Cherry, \emph{A System for Typesetting Mathematics}, Communications of the ACM 18 (1975), and their \emph{Typesetting Mathematics, User's Guide}.
}
\examples{
eq <- c(".EQ", "s sup 2 ~=~ 1 over {n - 1} sum from i=1 to n ( x sub i - x bar ) sup 2", ".EN")
cat(eq, sep = "\n")
}
