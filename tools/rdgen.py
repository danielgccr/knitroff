"""Generate knitroff's reference pages (ms, troff, eqn, tbl) as Rd. Run: python3 tools/rdgen.py

The content follows the groff 1.24.1 manuals: groff_ms(7), groff(7), groff_char(7), eqn(1), tbl(1).
Edit here, not in man/, and regenerate; troff is escaped for Rd in one place, esc()."""
import pathlib

MAN = pathlib.Path(__file__).resolve().parent.parent / 'man'


def esc(s):
    return s.replace('\\', '\\\\').replace('%', '\\%').replace('{', '\\{').replace('}', '\\}')


def c(s):                       # troff text, verbatim: Rd would parse \\code{} as R
    return '\\verb{' + esc(s) + '}'


def t(s):                       # plain text with troff characters in it
    return esc(s)


def table(spec, rows):
    return '\\tabular{' + spec + '}{\n' + ' \\cr\n'.join(' \\tab '.join(r) for r in rows) + '\n}\n'


def items(rows):                # \describe list: (term, text)
    return '\\describe{\n' + '\n'.join('\\item{' + a + '}{' + b + '}' for a, b in rows) + '\n}\n'


def section(title, body):
    return '\\section{' + title + '}{\n' + body + '}\n'


def page(name, aliases, title, description, sections, seealso, examples=None):
    out = ['\\name{' + name + '}'] + ['\\alias{' + a + '}' for a in aliases]
    out += ['\\title{' + title + '}', '\\description{\n' + description + '}']
    out += sections
    out.append('\\seealso{\n' + seealso + '}')
    if examples:
        out.append('\\examples{\n' + examples + '}')
    (MAN / (name + '.Rd')).write_text('\n'.join(out) + '\n')


EXT = 'Marked entries are extensions: \\emph{(Berkeley)} from 4.2BSD, \\emph{(Tenth Ed.)} from Research Unix, \\emph{(GNU)} from groff.'

# ---------------------------------------------------------------- ms
ms_sections = [
    section('Using the ms macros with knitroff', items([
        (c('render_roff()'), 'runs ' + c('groff -ms -k -e -t -p') + ': the ms macros, UTF-8 input, and the eqn, tbl and pic preprocessors. ' + c('refer') + ' is not run, so ' + c('.[') + ' ... ' + c('.]') + ' citations are left as they are.'),
        (c('.SS') + ', ' + c('.SE') + ', ' + c('.SR'), 'are knitroff\'s, not ms\'s: knitroff replaces them before groff sees the document. ms has no macros with these names, so there is no clash.'),
        ('listings', 'each R chunk becomes a ' + c('.DS L') + ' ... ' + c('.DE') + ' display in the constant-width font ' + c('CR') + ', so it is kept together on one page.'),
        ('figures', 'a plot becomes ' + c('.PDFPIC -C') + ' (PDF) or ' + c('.PSPIC -C') + ' (PostScript), centred, with its caption.'),
        ('a skeleton', 'a document needs at least one paragraph or heading macro; begin the text with ' + c('.LP') + ' or ' + c('.PP') + '. After a heading, call a paragraph macro to end the heading text.'),
        ('settings', 'set registers and strings such as ' + c('.nr LL 6i') + ' or ' + c('.ds CH') + ' before the first ms macro other than ' + c('.RP') + '.'),
    ])),
    section('Document description', 'Call these in the order shown. ' + c('.TL') + ' is required if any of ' + c('.RP') + ', ' + c('.AU') + ', ' + c('.AI') + ', ' + c('.AB') + ' is used; ' + c('.AE') + ' is required after ' + c('.AB') + '.\n' + items([
        (c('.RP [no-repeat-info] [no-renumber]'), 'report format: put the title, authors and abstract on a separate cover page. ' + c('no') + ' is the AT&T form of ' + c('no-repeat-info') + '; the other options are (GNU).'),
        (c('.TL'), 'the title: the following input lines, until ' + c('.AU') + ', ' + c('.AB') + ', or a heading or paragraph macro.'),
        (c('.AU'), 'an author\'s name, on the following lines. Call it again for each author.'),
        (c('.AI'), 'the preceding author\'s institution, on the following lines.'),
        (c('.DA [x ...]'), 'the current date, or ' + t('x') + ', in the centre footer (and on the cover page with ' + c('.RP') + ').'),
        (c('.ND [x ...]'), 'no date in the footer; the date, or ' + t('x') + ', only on the cover page with ' + c('.RP') + '. This is groff\'s default.'),
        (c('.AB [no]'), 'begin the abstract, headed by an italic "ABSTRACT"; ' + c('no') + ' leaves out the heading.'),
        (c('.AE'), 'end the abstract.'),
    ])),
    section('Paragraphs', 'Each paragraph macro breaks the line and adds the space in ' + c('\\n[PD]') + '.\n' + items([
        (c('.LP'), 'a paragraph with no indentation.'),
        (c('.PP'), 'a paragraph whose first line is indented by ' + c('\\n[PI]') + '.'),
        (c('.IP [mark [width]]'), 'an indented paragraph, with ' + t('mark') + ' hanging in the margin: the way to make lists (' + c('.IP \\(bu') + ', ' + c('.IP 1.') + '). ' + t('width') + ' (in ens) replaces ' + c('\\n[PI]') + ' and stays until the next heading or other paragraph macro.'),
        (c('.QP'), 'a paragraph indented from both margins by ' + c('\\n[QI]') + ', for quotations.'),
        (c('.QS') + ', ' + c('.QE'), 'begin and end a region in which every paragraph is indented from both margins.'),
        (c('.XP'), 'an "exdented" paragraph: a hanging indent, every line but the first indented. (Berkeley)'),
    ])),
    section('Headings', items([
        (c('.NH [depth]'), 'a numbered heading, 1., 1.1., 1.1.1. ..., at ' + t('depth') + ' (default 1); the following lines are its text, ended by a paragraph macro. Skipping a depth draws a warning.'),
        (c('.NH S n ...'), 'set the heading numbers explicitly; numbering continues from them. (Berkeley)'),
        (c('.SH [depth]'), 'an unnumbered heading. ' + t('depth') + ' (GNU) matches its size to ' + c('.NH') + ' at that depth.'),
        (c('\\*[SN]') + ', ' + c('\\*[SN-DOT]') + ', ' + c('\\*[SN-NO-DOT]'), 'the number of the last ' + c('.NH') + ', for captions and cross-references; with and without the final period. (GNU, ' + c('SN') + ' Berkeley)'),
        (c('.als SN-STYLE SN-NO-DOT'), 'number headings without the final period. (GNU)'),
    ]) + 'Registers ' + c('PSINCR') + ' and ' + c('GROWPS') + ' (GNU) make headings above a depth larger; ' + c('HORPHANS') + ' (GNU) keeps a heading with lines of the next paragraph.\n'),
    section('Typeface', 'In these macros, ' + t('text') + ' is set in the face, then ' + t('post') + ' in the previous face with no space, and ' + t('pre') + ' before it: ' + c('.B word ,') + ' gives a bold word followed by a roman comma. Without arguments, the face holds until the next paragraph, heading or typeface macro. ' + t('pre') + ' is (GNU).\n' + items([
        (c('.B [text [post [pre]]]'), 'bold.'),
        (c('.I [text [post [pre]]]'), 'italic.'),
        (c('.R [text [post [pre]]]'), 'roman (upright). Its arguments are (GNU).'),
        (c('.BI [text [post [pre]]]'), 'bold italic. (Tenth Ed.)'),
        (c('.CW [text [post [pre]]]'), 'constant width, for code in a sentence. (Tenth Ed.)'),
        (c('.BX [text]'), 'text in a box (reverse video on a terminal). Use unbreakable spaces, such as ' + c('\\~') + ', inside it.'),
        (c('.UL [text [post]]'), 'underlined text (between underscores on a terminal).'),
        (c('.LG') + ', ' + c('.SM') + ', ' + c('.NL'), 'type 2 points larger, 2 points smaller, or back to the normal size ' + c('\\n[PS]') + '.'),
        (c('\\*{') + ' ... ' + c('\\*}'), 'superscript. (GNU)'),
        (c('\\*<') + ' ... ' + c('\\*>'), 'subscript. (GNU)'),
    ])),
    section('Indented regions', items([
        (c('.RS'), 'begin a region where headings, paragraphs and displays are indented further by ' + c('\\n[PI]') + '. Regions nest. Use this, not ' + c('.in') + ', which ms resets.'),
        (c('.RE'), 'end the innermost region.'),
    ])),
    section('Keeps, boxes and displays', 'A keep holds text on one page; a display also turns filling off, so lines break as in the source.\n' + items([
        (c('.KS') + ', ' + c('.KE'), 'begin and end a keep: if it does not fit, the page breaks before it.'),
        (c('.KF') + ', ' + c('.KE'), 'a floating keep: if it does not fit, the text after it fills the page and the keep goes to the top of the next.'),
        (c('.B1') + ', ' + c('.B2'), 'a keep with a box drawn round it. Put it inside ' + c('.KF') + ' ... ' + c('.KE') + ' to let it float.'),
        (c('.DS L') + ', or ' + c('.LD'), 'a left-aligned display (' + c('.DS') + ': kept; ' + c('.LD') + ': may break across pages). knitroff\'s listings are these.'),
        (c('.DS [I [indent]]') + ', or ' + c('.ID [indent]'), 'an indented display, by ' + t('indent') + ' or ' + c('\\n[DI]') + '.'),
        (c('.DS B') + ', or ' + c('.BD'), 'a block display: left-aligned, with its longest line centred.'),
        (c('.DS C') + ', or ' + c('.CD'), 'a centred display: each line centred.'),
        (c('.DS R') + ', or ' + c('.RD'), 'a right-aligned display. (GNU)'),
        (c('.DE'), 'end any display.'),
    ]) + 'Displays and preprocessor regions get ' + c('\\n[DD]') + ' of space before and after (Berkeley); ' + c('\\n[DI]') + ' (GNU) is the default indentation.\n'),
    section('Tables, pictures, equations and citations', 'Preprocessors find these tokens only at the start of a line, with nothing between the dot and the name.\n' + items([
        (c('.TS [H]') + ' ... ' + c('.TE'), 'a table for tbl (see ' + '\\code{\\link{tbl}}' + '). With ' + c('H') + ', the rows before ' + c('.TH') + ' repeat at the top of each page.'),
        (c('.PS h v') + ' ... ' + c('.PE') + ' or ' + c('.PF'), 'a pic diagram; ' + c('.PF') + ' ends it and returns to the top of the picture.'),
        (c('.EQ [align [label]]') + ' ... ' + c('.EN'), 'an equation for eqn (see ' + '\\code{\\link{eqn}}' + '), centred unless ' + t('align') + ' is ' + c('L') + ' or ' + c('I') + ', with ' + t('label') + ' at the right margin.'),
        (c('.[') + ' ... ' + c('.]'), 'a citation for refer, which ' + c('render_roff()') + ' does not run.'),
    ])),
    section('Footnotes', items([
        (c('\\**'), 'an automatically numbered footnote mark in the text. (Berkeley)'),
        (c('.FS [mark]') + ', ' + c('.FE'), 'begin and end the footnote text, set at the foot of the page. Without ' + t('mark') + ', the next automatic number is used.'),
    ]) + c('\\n[FF]') + ' sets the style: 0, the mark as a superscript (default); 1, as text with a period; 2, as 1 without indentation; 3, as 1 with the mark hanging. ' + c('FI') + ', ' + c('FPS') + ', ' + c('FVS') + ', ' + c('FPD') + ' (the last three GNU) are the footnote indentation, type size, vertical spacing and paragraph distance. ' + c('FS-MARK') + ' is a hook macro called by ' + c('.FS') + '. (GNU)\n'),
    section('Headers and footers', items([
        (c('.ds LH') + ', ' + c('CH') + ', ' + c('RH'), 'the left, centre and right header; ' + c('CH') + ' is ' + c('-\\n[%]-') + ', the page number between dashes, by default.'),
        (c('.ds LF') + ', ' + c('CF') + ', ' + c('RF'), 'the left, centre and right footer, empty by default.'),
        (c(".OH 'left'centre'right'") + ', ' + c('.EH') + ', ' + c('.OF') + ', ' + c('.EF'), 'headers and footers for odd and even pages. Any character can replace the apostrophes. (Berkeley)'),
        (c('%'), 'in header or footer text, the page number. ms prints no header on page 1.'),
        (c('.P1'), 'print the header on page 1 too. (Berkeley)'),
        (c('PT') + ', ' + c('BT') + ', ' + c('HD'), 'the macros that print the header and footer, which you may redefine; ' + c('HD') + ' is called after the header. (' + c('HD') + ' Berkeley)'),
    ])),
    section('Columns, tabs and contents', items([
        (c('.1C') + ', ' + c('.2C'), 'one column (default) or two columns.'),
        (c('.MC [width [gutter]]'), 'as many columns of ' + t('width') + ' as fit, at least ' + t('gutter') + ' apart; without arguments, two columns. ' + c('\\n[MINGW]') + ' (GNU) is the minimum gutter.'),
        (c('.TA'), 'reset tab stops to every 5 ens. Set others with ' + c('.ta') + '.'),
        (c('.XS [page]') + ', ' + c('.XA [page [indent]]') + ', ' + c('.XE'), 'begin, add to, and end a table of contents entry; the lines between are its text. (Berkeley)'),
        (c('.PX [no]') + ', ' + c('.TC [no]'), 'print the table of contents at the end of the document; ' + c('.TC') + ' also restarts page numbers in roman numerals. (Berkeley)'),
        (c('.XN text') + ', ' + c('.XH depth text'), 'set a heading and make its contents entry at once, after ' + c('.NH') + ' or ' + c('.SH') + '. (GNU)'),
    ])),
    section('Registers and strings', 'Set with ' + c('.nr name value') + ' or ' + c('.ds name text') + ' before the first ms macro. Defaults are for typesetters; terminals use the value in parentheses.\n' + table('lll', [
        [c('\\n[PO]'), 'page offset (left margin)', '1i (0)'],
        [c('\\n[LL]'), 'line length', '6.5i (65n)'],
        [c('\\n[LT]'), 'title line length', '6.5i (65n)'],
        [c('\\n[HM]') + ', ' + c('\\n[FM]'), 'top and bottom margins', '1i'],
        [c('\\n[PS]'), 'type size', '10p'],
        [c('\\n[VS]'), 'vertical spacing (leading)', '12p'],
        [c('\\n[HY]'), 'hyphenation mode; 0 turns it off (Tenth Ed.)', '6'],
        [c('\\*[FAM]'), 'font family: T Times, H Helvetica, C Courier, ... (GNU)', 'T'],
        [c('\\n[PI]'), 'paragraph indentation', '5n'],
        [c('\\n[PD]'), 'space between paragraphs', '0.3v (1v)'],
        [c('\\n[QI]'), 'quotation indentation', '5n'],
        [c('\\n[PORPHANS]'), 'first lines of a paragraph kept together (GNU)', '1'],
        [c('\\n[PSINCR]'), 'heading size increment (GNU)', '1p'],
        [c('\\n[GROWPS]'), 'depth above which headings grow (GNU)', '0'],
        [c('\\n[HORPHANS]'), 'lines kept with a heading (GNU)', '1'],
        [c('\\n[FI]'), 'footnote indentation', '2n'],
        [c('\\n[FF]'), 'footnote format, 0 to 3', '0'],
        [c('\\n[FPS]') + ', ' + c('\\n[FVS]'), 'footnote type size and spacing (GNU)', 'PS-2p, FPS+2p'],
        [c('\\n[FPD]'), 'footnote paragraph distance (GNU)', 'PD/2'],
        [c('\\*[FR]'), 'footnote line length, as a ratio', '11/12'],
        [c('\\n[DD]'), 'space around displays (Berkeley)', '0.5v (1v)'],
        [c('\\n[DI]'), 'display indentation (GNU)', '0.5i'],
        [c('\\n[MINGW]'), 'minimum gutter between columns (GNU)', '2n'],
        [c('\\n[GS]'), '1 under groff ms, for a document to test', '1'],
    ]) + 'Strings for symbols: ' + c('\\*-') + ' an em dash; ' + c('\\*Q') + ' and ' + c('\\*U') + ' left and right quotation marks. Strings to translate: ' + c('\\*[ABSTRACT]') + ', ' + c('\\*[TOC]') + ', ' + c('\\*[REFERENCES]') + ', and ' + c('\\*[MONTH1]') + ' to ' + c('\\*[MONTH12]') + '.\n'),
    section('Seventh Edition compatibility', 'groff ms is a reimplementation of AT&T ms, the package Mike Lesk wrote at Bell Laboratories and shipped with the Seventh Edition (1979). ' + EXT + ' Leave them out and the document is one 1979 ms could have formatted. Some Seventh Edition macros were specific to Bell Laboratories and are not in groff: the document types ' + c('EG IM MF MR TM TR') + ', ' + c('AT CS CT OK SG') + ', the Bell Labs addresses ' + c('HO IH MH PY WH') + ', and ' + c('UX') + '. The old accent strings, such as ' + c("\\*'") + ' (acute) and ' + c('\\*:') + ' (umlaut), and ' + c('.AM') + ' still work, but UTF-8 input or ' + c('\\[...]') + ' characters (see ' + '\\code{\\link{troff}}' + ') are better.\n'),
]
# In \examples, Rd reads \\ as \, so the R string "\\(bu" is written with four backslashes here.
page('ms', ['ms', 'ms-macros', 'TL', 'AU', 'AI', 'AB', 'AE', 'PP', 'LP', 'IP', 'QP', 'NH', 'SH', 'DS', 'DE', 'KS', 'KE', 'FS', 'FE'],
     'The ms macros: a reference for knitroff documents',
     'A knitroff document is troff with the ms macros, a package for papers, reports and memoranda. This page lists the macros, registers and strings of ms as GNU groff implements it, following groff_ms(7) for groff 1.24.1. ' + EXT + ' Requests and escapes, such as ' + c('.sp') + ' and ' + c('\\fB') + ', are in ' + '\\code{\\link{troff}}' + '.\n',
     ms_sections,
     '\\code{\\link{troff}}, \\code{\\link{eqn}}, \\code{\\link{tbl}}, \\code{\\link{render_roff}}. In a terminal: \\code{man groff_ms}; and M. E. Lesk, \\emph{Typing Documents on the UNIX System: Using the -ms Macros with Troff and Nroff}, Bell Laboratories, 1978.\n',
     'doc <- c(".TL", "A short report", ".AU", "A. Student", ".AB",\n         "One paragraph of abstract.", ".AE", ".NH", "Method", ".PP",\n         "The mean is `r mean(1:10)`.", ".IP \\\\\\\\(bu", "a list item")\nwriteLines(doc, file.path(tempdir(), "report.Rms"))\n')

# ---------------------------------------------------------------- troff
troff_sections = [
    section('Writing troff text', items([
        ('requests', 'a line beginning with ' + c('.') + ' or ' + c("'") + ' is a request or a macro call, such as ' + c('.PP') + '. To begin a text line with either character, put ' + c('\\&') + ' (a zero-width character) before it.'),
        ('escapes', 'a backslash begins an escape, such as ' + c('\\fB') + '. Write a literal backslash as ' + c('\\e') + ' or ' + c('\\[rs]') + '.'),
        ('breaks', 'a blank line, or a line beginning with a space, breaks the paragraph. In filled text, start each sentence on a new line: troff then puts the right space after its period.'),
        ('comments', c('.\\"') + ' begins a comment line; ' + c('\\"') + ' begins a comment at the end of a line.'),
        ('knitroff', 'inline results (' + c('`r expr`') + ') and ' + c('.SR') + ' strings are escaped for you; output in listings is too.'),
    ])),
    section('Requests', 'ms resets indentation, line length and type size at each paragraph and heading, so inside an ms document prefer its own macros and registers (' + c('.RS') + ', ' + c('\\n[LL]') + ', ' + c('.LG') + ') to ' + c('.in') + ', ' + c('.ll') + ' and ' + c('.ps') + '.\n' + table('ll', [
        [c('.br'), 'break the output line'],
        [c('.sp [N]'), 'break, and space down N (default one line)'],
        [c('.bp'), 'begin a new page'],
        [c('.ne N'), 'begin a new page unless N of space remains'],
        [c('.ce [N]'), 'centre the next N input lines (default 1); ' + c('.ce 0') + ' stops'],
        [c('.nf') + ', ' + c('.fi'), 'no filling (lines as in the source) / filling again'],
        [c('.ad [l|r|c|b]') + ', ' + c('.na'), 'adjust lines left, right, centre or both margins / no adjustment'],
        [c('.ft F'), 'change to font F: R, I, B, BI, CR (constant width), or P (previous)'],
        [c('.ps N'), 'type size N points; ' + c('.ps +2') + ' larger'],
        [c('.vs N'), 'vertical spacing (baseline to baseline)'],
        [c('.ll N'), 'line length'],
        [c('.in N') + ', ' + c('.ti N'), 'indentation / indentation of the next line only'],
        [c('.po N') + ', ' + c('.pl N'), 'page offset (left margin) / page length'],
        [c('.ta N ...'), 'tab stops, such as ' + c('.ta 1i 2i') + ' or ' + c('.ta 2iR') + ' (right-aligned)'],
        [c(".tl 'l'c'r'"), 'a three-part title line'],
        [c('.hy [N]') + ', ' + c('.nh'), 'hyphenation on / off'],
        [c('.ul [N]'), 'underline (italic in troff) the next N lines'],
        [c('.ds name text'), 'define a string, used as ' + c('\\*[name]') + '; a leading ' + c('"') + ' keeps leading spaces'],
        [c('.nr name N'), 'set a number register, used as ' + c('\\n[name]')],
        [c('.de name') + ' ... ' + c('..'), 'define a macro; its arguments are ' + c('\\\\$1') + ', ' + c('\\\\$2') + ' ...'],
        [c('.so file'), 'read in another file here'],
        [c('.ig') + ' ... ' + c('..'), 'ignore input up to ' + c('..')],
    ])),
    section('Escapes', table('ll', [
        [c('\\fB') + ', ' + c('\\fI') + ', ' + c('\\fR') + ', ' + c('\\fP'), 'bold, italic, roman, previous font; ' + c('\\f(CR') + ' or ' + c('\\f[CR]') + ' constant width'],
        [c('\\s+2') + ', ' + c('\\s-2') + ', ' + c('\\s0'), 'type size up, down, back to the previous'],
        [c('\\*x') + ', ' + c('\\*(xx') + ', ' + c('\\*[name]'), 'the string x, xx, or name; ' + c('.SR') + ' defines them'],
        [c('\\nx') + ', ' + c('\\n(xx') + ', ' + c('\\n[name]'), 'the value of a register; ' + c('\\n[%]') + ' is the page number'],
        [c('\\(xx') + ', ' + c('\\[name]'), 'a special character, such as ' + c('\\(em') + ' (below)'],
        [c('\\e'), 'a backslash'],
        [c('\\-'), 'a minus sign. knitroff writes the - of code this way, so groff does not set it as a hyphen; in the terminal draft it is the ASCII -'],
        [c('\\&'), 'nothing, zero width: protects a leading . or \''],
        [c('\\~') + ', ' + c('\\ ') + ' (backslash, space)', 'an unbreakable space, adjustable / of fixed width'],
        [c('\\0') + ', ' + c('\\|') + ', ' + c('\\^'), 'spaces the width of a digit, 1/6 em, 1/12 em'],
        [c('\\u') + ', ' + c('\\d'), 'up / down half an em, for simple super- and subscripts'],
        [c("\\v'N'") + ', ' + c("\\h'N'"), 'move vertically (down if positive) / horizontally'],
        [c("\\l'N'") + ', ' + c("\\L'N'"), 'draw a horizontal / vertical line of length N'],
        [c("\\w'text'"), 'the width of text, for use in measurements'],
        [c("\\z") + 'c', 'print c without moving: zero width'],
        [c('\\c'), 'join the next input line to this one'],
        [c('\\%'), 'a hyphenation point; at the start of a word, do not hyphenate it'],
        [c('\\"'), 'a comment, to the end of the line'],
    ])),
    section('Units', 'Measurements take a unit after the number, as in ' + c('.sp 0.5v') + ' or ' + c('.in 2n') + '.\n' + table('ll', [
        [c('i') + ', ' + c('c') + ', ' + c('p') + ', ' + c('P'), 'inch, centimetre, point (1/72 inch), pica (12 points)'],
        [c('m') + ', ' + c('n'), 'em and en: the width of M and half of it, at the current type size'],
        [c('v'), 'one line of vertical spacing (a "vee")'],
        [c('u'), 'the device\'s basic unit'],
    ]) + 'Without a unit, ' + c('.sp') + ' and ' + c('.ne') + ' count lines (v), ' + c('.ps') + ' and ' + c('.vs') + ' points, and most other requests ems.\n'),
    section('Special characters', 'UTF-8 input works (knitroff runs groff with ' + c('-k') + '), but these names are portable to any troff and to the terminal. Write ' + c('\\(xx') + ' for two-character names or ' + c('\\[name]') + ' for any.\n' + table('llll', [
        [c('\\(em'), 'em dash', c('\\(en'), 'en dash'],
        [c('\\(hy'), 'hyphen', c('\\(mi'), 'minus'],
        [c('\\(bu'), 'bullet', c('\\(de'), 'degree'],
        [c('\\(co') + ', ' + c('\\(rg') + ', ' + c('\\(tm'), 'copyright, registered, trademark', c('\\(sc'), 'section'],
        [c('\\(dg') + ', ' + c('\\(dd'), 'dagger, double dagger', c('\\(ct') + ', ' + c('\\(Po') + ', ' + c('\\(Eu'), 'cent, pound, euro'],
        [c('\\(mu') + ', ' + c('\\(di'), 'times, divide', c('\\(+-'), 'plus or minus'],
        [c('\\(<=') + ', ' + c('\\(>='), 'less, greater or equal', c('\\(!=') + ', ' + c('\\(==') + ', ' + c('\\(~='), 'not equal, equivalent, approximately'],
        [c('\\(->') + ', ' + c('\\(<-'), 'arrows', c('\\(if') + ', ' + c('\\(pd') + ', ' + c('\\(gr'), 'infinity, partial, gradient'],
        [c('\\(sr') + ', ' + c('\\(is'), 'square root, integral', c('\\(sq') + ', ' + c('\\(ci'), 'square, circle'],
        [c('\\(lq') + ', ' + c('\\(rq'), 'double quotes', c('\\(oq') + ', ' + c('\\(cq'), 'single quotes'],
        [c('\\(aq') + ', ' + c('\\(dq'), 'ASCII \' and "', c('\\(ga') + ', ' + c('\\(ha') + ', ' + c('\\(ti'), 'ASCII `, ^, ~'],
        [c('\\(rs') + ', ' + c('\\(sl'), 'backslash, slash', c('\\(fm'), 'prime (foot mark)'],
        [c('\\(*a') + ' ... ' + c('\\(*w'), 'Greek alpha to omega', c('\\(*A') + ' ... ' + c('\\(*W'), 'capital Greek'],
    ]) + 'The full list is in ' + c('man groff_char') + '.\n'),
]
page('troff', ['troff', 'roff', 'groff', 'troff-requests'],
     'troff requests, escapes and characters for knitroff documents',
     'Below the ms macros (\\code{\\link{ms}}), a knitroff document is plain troff: requests on lines that begin with a dot, and escapes that begin with a backslash. This page covers what reports need, following groff(7) and groff_char(7) for groff 1.24.1.\n',
     troff_sections,
     '\\code{\\link{ms}}, \\code{\\link{eqn}}, \\code{\\link{tbl}}. In a terminal: \\code{man 7 groff}, \\code{man groff_char}, \\code{info groff}.\n')

# ---------------------------------------------------------------- eqn
eqn_sections = [
    section('Displays and inline equations', items([
        (c('.EQ') + ' ... ' + c('.EN'), 'a displayed equation, centred by ms; ' + c('.EQ L') + ' left-aligns it, ' + c('.EQ I') + ' indents it, and a second argument is a label at the right margin, as in ' + c('.EQ C (1)') + '.'),
        (c('delim $$'), 'inside an ' + c('.EQ') + ' ... ' + c('.EN') + ', makes ' + c('$') + ' delimit equations within the text: ' + c('the mean $x bar$ is') + '. ' + c('delim off') + ' stops it.'),
        ('knitroff', 'in the ' + c('"utf8"') + ' draft, displayed equations appear as their eqn source, because groff cannot set them on a terminal; inline equations appear between their delimiters.'),
    ])),
    section('Writing equations', 'eqn reads words separated by spaces; spaces themselves do not show. Braces group: ' + c('e sup {i pi}') + '. Quoted text is set as it is, in roman: ' + c('"for all"') + '. ' + c('~') + ' is a space and ' + c('^') + ' half a space. eqn sets letters in italic and digits, operators and function names such as ' + c('sin') + ' in roman, and turns ' + c('+ - = <= >=') + ' into their mathematical characters.\n' + table('ll', [
        [c('x sub i') + ', ' + c('x sup 2'), 'subscript, superscript; ' + c('x sub i sup 2') + ' both'],
        [c('a over b'), 'a fraction'],
        [c('sqrt x'), 'square root'],
        [c('sum from i=1 to n x sub i'), 'limits under and over ' + c('sum') + ', ' + c('prod') + ', ' + c('int') + ', ' + c('lim') + ', ' + c('union') + ', ' + c('inter')],
        [c('left ( a over b right )'), t('brackets that grow to fit: ( [ { | and their mates, and ') + c('left floor') + ', ' + c('ceiling')],
        [c('x bar') + ', ' + c('x under') + ', ' + c('x hat') + ', ' + c('x dot') + ', ' + c('x vec'), 'marks over or under x; also ' + c('dotdot') + ', ' + c('tilde') + ', ' + c('dyad')],
        [c('pile { a above b above c }'), 'a vertical stack; ' + c('lpile') + ', ' + c('cpile') + ', ' + c('rpile') + ' align it'],
        [c('matrix { ccol { a above b } ccol { c above d } }'), 'a matrix of columns; ' + c('lcol') + ', ' + c('rcol') + ' align them'],
        [c('mark') + ', ' + c('lineup'), 'align successive equations at a point, such as their = signs'],
        [c('roman') + ', ' + c('italic') + ', ' + c('bold') + ', ' + c('fat'), 'the face of the next item; ' + c('fat') + ' overstrikes to embolden'],
        [c('size 12 x') + ', ' + c('size +2 x'), 'type size of the next item'],
        [c('up n') + ', ' + c('down n') + ', ' + c('fwd n') + ', ' + c('back n'), 'move by n hundredths of an em'],
        [c('define name "text"'), 'a macro: ' + c('define var "x sub i"') + '; ' + c('ndefine') + ' and ' + c('tdefine') + ' only for nroff or troff'],
        [c('gsize n') + ', ' + c('gfont f'), 'the global type size and italic font of equations'],
    ])),
    section('Names eqn knows', 'Greek letters: ' + c('alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu nu xi omicron pi rho sigma tau upsilon phi chi psi omega') + '; spelled with a capital (' + c('Gamma') + ') or in capitals (' + c('GAMMA') + ') for uppercase.\n\nSymbols and functions: ' + c('inf partial grad del prime approx times nothing ... half') + ', ' + c('== != += -> <- << >>') + ', and ' + c('sin cos tan sinh cosh tanh arc exp log ln lim max min det Re Im and for if') + '.\n\nAdded by GNU eqn: ' + c('cdot cdots ldots utilde dollar') + ', and the primitives ' + c('accent uaccent big smallover vcenter split nosplit opprime type chartype set reset grfont gifont gbfont') + '.\n'),
]
page('eqn', ['eqn', 'neqn', 'equations'],
     'eqn: equations in knitroff documents',
     'eqn, by Brian Kernighan and Lorinda Cherry, is the troff preprocessor for mathematics; its input reads much as the formula is spoken: ' + c('x sup 2 over 2') + '. \\code{\\link{render_roff}} runs it for PDF and PostScript output. This page follows eqn(1) for groff 1.24.1.\n',
     eqn_sections,
     '\\code{\\link{ms}}, \\code{\\link{troff}}, \\code{\\link{tbl}}. In a terminal: \\code{man eqn}; and B. W. Kernighan and L. L. Cherry, \\emph{A System for Typesetting Mathematics}, Communications of the ACM 18 (1975), and their \\emph{Typesetting Mathematics, User\'s Guide}.\n',
     'eq <- c(".EQ", "s sup 2 ~=~ 1 over {n - 1} sum from i=1 to n ( x sub i - x bar ) sup 2", ".EN")\ncat(eq, sep = "\\n")\n')

# ---------------------------------------------------------------- tbl
tbl_sections = [
    section('A table', 'A table sits between ' + c('.TS') + ' and ' + c('.TE') + ' and has three parts: options ending in ' + c(';') + ', one format line per row ending in ' + c('.') + ', and the data, one line per row with entries separated by tabs, or here by ' + c('@') + ', which survives copying from this page.\n\\preformatted{' + esc('.TS\ncenter box tab(@);\ncB cB\nl n.\nState@Income\n_\nAlaska@6315\nMaine@3694\n.TE') + '}\nThe last format line applies to all remaining rows. \\code{\\link{roff_table}} writes tables like this from a data frame.\n'),
    section('Options', table('ll', [
        [c('center'), 'centre the table (otherwise it is at the left margin)'],
        [c('expand'), 'make the table as wide as the line'],
        [c('box') + ', ' + c('doublebox') + ', ' + c('allbox'), 'a box round the table, a double one, or a box round every entry'],
        [c('tab(x)'), 'separate entries with x instead of a tab'],
        [c('linesize(n)'), 'lines n points thick'],
        [c('delim(xy)'), 'eqn delimiters inside the table'],
        [c('decimalpoint(c)') + ', ' + c('nospaces') + ', ' + c('nokeep') + ', ' + c('nowarn'), '(GNU) decimal separator, trim spaces, allow page breaks within rows, quiet'],
    ])),
    section('Format: one letter per column', table('ll', [
        [c('l') + ', ' + c('r') + ', ' + c('c'), 'left, right, centred'],
        [c('n'), 'numbers aligned on the decimal point'],
        [c('a'), 'left-aligned and indented, for sub-entries'],
        [c('s'), 'span: the entry to the left extends into this column'],
        [c('^'), 'span: the entry above extends into this row'],
        [c('_') + ', ' + c('='), 'a single or double rule in place of the entry'],
        [c('|') + ', ' + c('||'), 'a vertical line between columns'],
    ]) + 'After the letter, modifiers: ' + c('b') + ' bold, ' + c('i') + ' italic, ' + c('f(CR)') + ' any font, ' + c('p12') + ' type size, ' + c('w(1i)') + ' minimum width, ' + c('e') + ' equal widths, ' + c('x') + ' expand this column, ' + c('t') + ' top of a vertical span, and a number for the gap to the next column in ens (default 3). Rows of a format can be on separate lines or separated by commas: ' + c('cB cB, l n.') + '\n'),
    section('Data', items([
        (c('_') + ', ' + c('='), 'alone on a line, a horizontal rule across the table; alone in an entry, a rule across that cell.'),
        (c('\\^'), 'in an entry, the entry above spans down into it.'),
        (c('T{') + ' ... ' + c('T}'), 'a text block: an entry of several lines, filled.'),
        (c('\\&'), 'an empty entry made visible, or before a leading . in an entry.'),
        (c('.T&'), 'a new format for the rows that follow, with no more columns than before.'),
        (c('.TS H') + ', ' + c('.TH'), 'with ms, the rows before ' + c('.TH') + ' repeat at the top of each page the table spans.'),
    ])),
]
page('tbl', ['tbl', 'tables'],
     'tbl: tables in knitroff documents',
     'tbl, by Mike Lesk, is the troff preprocessor for tables. \\code{\\link{render_roff}} runs it for every output, the terminal draft included, and \\code{\\link{roff_table}} writes its input from a data frame. This page follows tbl(1) for groff 1.24.1.\n',
     tbl_sections,
     '\\code{\\link{roff_table}}, \\code{\\link{ms}}, \\code{\\link{troff}}, \\code{\\link{eqn}}. In a terminal: \\code{man tbl}; and M. E. Lesk, \\emph{Tbl: A Program to Format Tables}, Bell Laboratories, 1976.\n')
print('written')
