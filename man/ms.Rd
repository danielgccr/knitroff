\name{ms}
\alias{ms}
\alias{ms-macros}
\alias{TL}
\alias{AU}
\alias{AI}
\alias{AB}
\alias{AE}
\alias{PP}
\alias{LP}
\alias{IP}
\alias{QP}
\alias{NH}
\alias{SH}
\alias{DS}
\alias{DE}
\alias{KS}
\alias{KE}
\alias{FS}
\alias{FE}
\title{The ms macros: a reference for knitroff documents}
\description{
A knitroff document is troff with the ms macros, a package for papers, reports and memoranda. This page lists the macros, registers and strings of ms as GNU groff implements it, following groff_ms(7) for groff 1.24.1. Marked entries are extensions: \emph{(Berkeley)} from 4.2BSD, \emph{(Tenth Ed.)} from Research Unix, \emph{(GNU)} from groff. Requests and escapes, such as \verb{.sp} and \verb{\\fB}, are in \code{\link{troff}}.
}
\section{Using the ms macros with knitroff}{
\describe{
\item{\verb{render_roff()}}{runs \verb{groff -ms -k -e -t -p}: the ms macros, UTF-8 input, and the eqn, tbl and pic preprocessors. \verb{refer} is not run, so \verb{.[} ... \verb{.]} citations are left as they are.}
\item{\verb{.SS}, \verb{.SE}, \verb{.SR}}{are knitroff's, not ms's: knitroff replaces them before groff sees the document. ms has no macros with these names, so there is no clash.}
\item{listings}{each R chunk becomes a \verb{.DS L} ... \verb{.DE} display in the constant-width font \verb{CR}, so it is kept together on one page.}
\item{figures}{a plot becomes \verb{.PDFPIC -C} (PDF) or \verb{.PSPIC -C} (PostScript), centred, with its caption.}
\item{a skeleton}{a document needs at least one paragraph or heading macro; begin the text with \verb{.LP} or \verb{.PP}. After a heading, call a paragraph macro to end the heading text.}
\item{settings}{set registers and strings such as \verb{.nr LL 6i} or \verb{.ds CH} before the first ms macro other than \verb{.RP}.}
}
}

\section{Document description}{
Call these in the order shown. \verb{.TL} is required if any of \verb{.RP}, \verb{.AU}, \verb{.AI}, \verb{.AB} is used; \verb{.AE} is required after \verb{.AB}.
\describe{
\item{\verb{.RP [no-repeat-info] [no-renumber]}}{report format: put the title, authors and abstract on a separate cover page. \verb{no} is the AT&T form of \verb{no-repeat-info}; the other options are (GNU).}
\item{\verb{.TL}}{the title: the following input lines, until \verb{.AU}, \verb{.AB}, or a heading or paragraph macro.}
\item{\verb{.AU}}{an author's name, on the following lines. Call it again for each author.}
\item{\verb{.AI}}{the preceding author's institution, on the following lines.}
\item{\verb{.DA [x ...]}}{the current date, or x, in the centre footer (and on the cover page with \verb{.RP}).}
\item{\verb{.ND [x ...]}}{no date in the footer; the date, or x, only on the cover page with \verb{.RP}. This is groff's default.}
\item{\verb{.AB [no]}}{begin the abstract, headed by an italic "ABSTRACT"; \verb{no} leaves out the heading.}
\item{\verb{.AE}}{end the abstract.}
}
}

\section{Paragraphs}{
Each paragraph macro breaks the line and adds the space in \verb{\\n[PD]}.
\describe{
\item{\verb{.LP}}{a paragraph with no indentation.}
\item{\verb{.PP}}{a paragraph whose first line is indented by \verb{\\n[PI]}.}
\item{\verb{.IP [mark [width]]}}{an indented paragraph, with mark hanging in the margin: the way to make lists (\verb{.IP \\(bu}, \verb{.IP 1.}). width (in ens) replaces \verb{\\n[PI]} and stays until the next heading or other paragraph macro.}
\item{\verb{.QP}}{a paragraph indented from both margins by \verb{\\n[QI]}, for quotations.}
\item{\verb{.QS}, \verb{.QE}}{begin and end a region in which every paragraph is indented from both margins.}
\item{\verb{.XP}}{an "exdented" paragraph: a hanging indent, every line but the first indented. (Berkeley)}
}
}

\section{Headings}{
\describe{
\item{\verb{.NH [depth]}}{a numbered heading, 1., 1.1., 1.1.1. ..., at depth (default 1); the following lines are its text, ended by a paragraph macro. Skipping a depth draws a warning.}
\item{\verb{.NH S n ...}}{set the heading numbers explicitly; numbering continues from them. (Berkeley)}
\item{\verb{.SH [depth]}}{an unnumbered heading. depth (GNU) matches its size to \verb{.NH} at that depth.}
\item{\verb{\\*[SN]}, \verb{\\*[SN-DOT]}, \verb{\\*[SN-NO-DOT]}}{the number of the last \verb{.NH}, for captions and cross-references; with and without the final period. (GNU, \verb{SN} Berkeley)}
\item{\verb{.als SN-STYLE SN-NO-DOT}}{number headings without the final period. (GNU)}
}
Registers \verb{PSINCR} and \verb{GROWPS} (GNU) make headings above a depth larger; \verb{HORPHANS} (GNU) keeps a heading with lines of the next paragraph.
}

\section{Typeface}{
In these macros, text is set in the face, then post in the previous face with no space, and pre before it: \verb{.B word ,} gives a bold word followed by a roman comma. Without arguments, the face holds until the next paragraph, heading or typeface macro. pre is (GNU).
\describe{
\item{\verb{.B [text [post [pre]]]}}{bold.}
\item{\verb{.I [text [post [pre]]]}}{italic.}
\item{\verb{.R [text [post [pre]]]}}{roman (upright). Its arguments are (GNU).}
\item{\verb{.BI [text [post [pre]]]}}{bold italic. (Tenth Ed.)}
\item{\verb{.CW [text [post [pre]]]}}{constant width, for code in a sentence. (Tenth Ed.)}
\item{\verb{.BX [text]}}{text in a box (reverse video on a terminal). Use unbreakable spaces, such as \verb{\\~}, inside it.}
\item{\verb{.UL [text [post]]}}{underlined text (between underscores on a terminal).}
\item{\verb{.LG}, \verb{.SM}, \verb{.NL}}{type 2 points larger, 2 points smaller, or back to the normal size \verb{\\n[PS]}.}
\item{\verb{\\*\{} ... \verb{\\*\}}}{superscript. (GNU)}
\item{\verb{\\*<} ... \verb{\\*>}}{subscript. (GNU)}
}
}

\section{Indented regions}{
\describe{
\item{\verb{.RS}}{begin a region where headings, paragraphs and displays are indented further by \verb{\\n[PI]}. Regions nest. Use this, not \verb{.in}, which ms resets.}
\item{\verb{.RE}}{end the innermost region.}
}
}

\section{Keeps, boxes and displays}{
A keep holds text on one page; a display also turns filling off, so lines break as in the source.
\describe{
\item{\verb{.KS}, \verb{.KE}}{begin and end a keep: if it does not fit, the page breaks before it.}
\item{\verb{.KF}, \verb{.KE}}{a floating keep: if it does not fit, the text after it fills the page and the keep goes to the top of the next.}
\item{\verb{.B1}, \verb{.B2}}{a keep with a box drawn round it. Put it inside \verb{.KF} ... \verb{.KE} to let it float.}
\item{\verb{.DS L}, or \verb{.LD}}{a left-aligned display (\verb{.DS}: kept; \verb{.LD}: may break across pages). knitroff's listings are these.}
\item{\verb{.DS [I [indent]]}, or \verb{.ID [indent]}}{an indented display, by indent or \verb{\\n[DI]}.}
\item{\verb{.DS B}, or \verb{.BD}}{a block display: left-aligned, with its longest line centred.}
\item{\verb{.DS C}, or \verb{.CD}}{a centred display: each line centred.}
\item{\verb{.DS R}, or \verb{.RD}}{a right-aligned display. (GNU)}
\item{\verb{.DE}}{end any display.}
}
Displays and preprocessor regions get \verb{\\n[DD]} of space before and after (Berkeley); \verb{\\n[DI]} (GNU) is the default indentation.
}

\section{Tables, pictures, equations and citations}{
Preprocessors find these tokens only at the start of a line, with nothing between the dot and the name.
\describe{
\item{\verb{.TS [H]} ... \verb{.TE}}{a table for tbl (see \code{\link{tbl}}). With \verb{H}, the rows before \verb{.TH} repeat at the top of each page.}
\item{\verb{.PS h v} ... \verb{.PE} or \verb{.PF}}{a pic diagram; \verb{.PF} ends it and returns to the top of the picture.}
\item{\verb{.EQ [align [label]]} ... \verb{.EN}}{an equation for eqn (see \code{\link{eqn}}), centred unless align is \verb{L} or \verb{I}, with label at the right margin.}
\item{\verb{.[} ... \verb{.]}}{a citation for refer, which \verb{render_roff()} does not run.}
}
}

\section{Footnotes}{
\describe{
\item{\verb{\\**}}{an automatically numbered footnote mark in the text. (Berkeley)}
\item{\verb{.FS [mark]}, \verb{.FE}}{begin and end the footnote text, set at the foot of the page. Without mark, the next automatic number is used.}
}
\verb{\\n[FF]} sets the style: 0, the mark as a superscript (default); 1, as text with a period; 2, as 1 without indentation; 3, as 1 with the mark hanging. \verb{FI}, \verb{FPS}, \verb{FVS}, \verb{FPD} (the last three GNU) are the footnote indentation, type size, vertical spacing and paragraph distance. \verb{FS-MARK} is a hook macro called by \verb{.FS}. (GNU)
}

\section{Headers and footers}{
\describe{
\item{\verb{.ds LH}, \verb{CH}, \verb{RH}}{the left, centre and right header; \verb{CH} is \verb{-\\n[\%]-}, the page number between dashes, by default.}
\item{\verb{.ds LF}, \verb{CF}, \verb{RF}}{the left, centre and right footer, empty by default.}
\item{\verb{.OH 'left'centre'right'}, \verb{.EH}, \verb{.OF}, \verb{.EF}}{headers and footers for odd and even pages. Any character can replace the apostrophes. (Berkeley)}
\item{\verb{\%}}{in header or footer text, the page number. ms prints no header on page 1.}
\item{\verb{.P1}}{print the header on page 1 too. (Berkeley)}
\item{\verb{PT}, \verb{BT}, \verb{HD}}{the macros that print the header and footer, which you may redefine; \verb{HD} is called after the header. (\verb{HD} Berkeley)}
}
}

\section{Columns, tabs and contents}{
\describe{
\item{\verb{.1C}, \verb{.2C}}{one column (default) or two columns.}
\item{\verb{.MC [width [gutter]]}}{as many columns of width as fit, at least gutter apart; without arguments, two columns. \verb{\\n[MINGW]} (GNU) is the minimum gutter.}
\item{\verb{.TA}}{reset tab stops to every 5 ens. Set others with \verb{.ta}.}
\item{\verb{.XS [page]}, \verb{.XA [page [indent]]}, \verb{.XE}}{begin, add to, and end a table of contents entry; the lines between are its text. (Berkeley)}
\item{\verb{.PX [no]}, \verb{.TC [no]}}{print the table of contents at the end of the document; \verb{.TC} also restarts page numbers in roman numerals. (Berkeley)}
\item{\verb{.XN text}, \verb{.XH depth text}}{set a heading and make its contents entry at once, after \verb{.NH} or \verb{.SH}. (GNU)}
}
}

\section{Registers and strings}{
Set with \verb{.nr name value} or \verb{.ds name text} before the first ms macro. Defaults are for typesetters; terminals use the value in parentheses.
\tabular{lll}{
\verb{\\n[PO]} \tab page offset (left margin) \tab 1i (0) \cr
\verb{\\n[LL]} \tab line length \tab 6.5i (65n) \cr
\verb{\\n[LT]} \tab title line length \tab 6.5i (65n) \cr
\verb{\\n[HM]}, \verb{\\n[FM]} \tab top and bottom margins \tab 1i \cr
\verb{\\n[PS]} \tab type size \tab 10p \cr
\verb{\\n[VS]} \tab vertical spacing (leading) \tab 12p \cr
\verb{\\n[HY]} \tab hyphenation mode; 0 turns it off (Tenth Ed.) \tab 6 \cr
\verb{\\*[FAM]} \tab font family: T Times, H Helvetica, C Courier, ... (GNU) \tab T \cr
\verb{\\n[PI]} \tab paragraph indentation \tab 5n \cr
\verb{\\n[PD]} \tab space between paragraphs \tab 0.3v (1v) \cr
\verb{\\n[QI]} \tab quotation indentation \tab 5n \cr
\verb{\\n[PORPHANS]} \tab first lines of a paragraph kept together (GNU) \tab 1 \cr
\verb{\\n[PSINCR]} \tab heading size increment (GNU) \tab 1p \cr
\verb{\\n[GROWPS]} \tab depth above which headings grow (GNU) \tab 0 \cr
\verb{\\n[HORPHANS]} \tab lines kept with a heading (GNU) \tab 1 \cr
\verb{\\n[FI]} \tab footnote indentation \tab 2n \cr
\verb{\\n[FF]} \tab footnote format, 0 to 3 \tab 0 \cr
\verb{\\n[FPS]}, \verb{\\n[FVS]} \tab footnote type size and spacing (GNU) \tab PS-2p, FPS+2p \cr
\verb{\\n[FPD]} \tab footnote paragraph distance (GNU) \tab PD/2 \cr
\verb{\\*[FR]} \tab footnote line length, as a ratio \tab 11/12 \cr
\verb{\\n[DD]} \tab space around displays (Berkeley) \tab 0.5v (1v) \cr
\verb{\\n[DI]} \tab display indentation (GNU) \tab 0.5i \cr
\verb{\\n[MINGW]} \tab minimum gutter between columns (GNU) \tab 2n \cr
\verb{\\n[GS]} \tab 1 under groff ms, for a document to test \tab 1
}
Strings for symbols: \verb{\\*-} an em dash; \verb{\\*Q} and \verb{\\*U} left and right quotation marks. Strings to translate: \verb{\\*[ABSTRACT]}, \verb{\\*[TOC]}, \verb{\\*[REFERENCES]}, and \verb{\\*[MONTH1]} to \verb{\\*[MONTH12]}.
}

\section{Seventh Edition compatibility}{
groff ms is a reimplementation of AT&T ms, the package Mike Lesk wrote at Bell Laboratories and shipped with the Seventh Edition (1979). Marked entries are extensions: \emph{(Berkeley)} from 4.2BSD, \emph{(Tenth Ed.)} from Research Unix, \emph{(GNU)} from groff. Leave them out and the document is one 1979 ms could have formatted. Some Seventh Edition macros were specific to Bell Laboratories and are not in groff: the document types \verb{EG IM MF MR TM TR}, \verb{AT CS CT OK SG}, the Bell Labs addresses \verb{HO IH MH PY WH}, and \verb{UX}. The old accent strings, such as \verb{\\*'} (acute) and \verb{\\*:} (umlaut), and \verb{.AM} still work, but UTF-8 input or \verb{\\[...]} characters (see \code{\link{troff}}) are better.
}

\seealso{
\code{\link{troff}}, \code{\link{eqn}}, \code{\link{tbl}}, \code{\link{render_roff}}. In a terminal: \code{man groff_ms}; and M. E. Lesk, \emph{Typing Documents on the UNIX System: Using the -ms Macros with Troff and Nroff}, Bell Laboratories, 1978.
}
\examples{
doc <- c(".TL", "A short report", ".AU", "A. Student", ".AB",
         "One paragraph of abstract.", ".AE", ".NH", "Method", ".PP",
         "The mean is `r mean(1:10)`.", ".IP \\\\(bu", "a list item")
writeLines(doc, file.path(tempdir(), "report.Rms"))
}
