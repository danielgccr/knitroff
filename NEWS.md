# knitroff 0.1.0

* First release.
* `knit_roff()` knits an `.Rms` document, troff with the ms macros and R chunks between
  `.SS` and `.SE`, to plain troff; `render_roff()` also typesets it with GNU groff as PDF,
  PostScript or a draft for the terminal.
* Inline results with `` `r expr` `` and `.SR name expr`; chunk listings with R's
  prompts, optionally highlighted in bold and italic; figures with `.PDFPIC` or `.PSPIC`;
  `roff_table()` for tbl tables.
* A vignette engine, `knitroff::roff`, for `.Rms` vignettes.
* Reference help pages for writing documents: `?ms`, `?troff`, `?eqn` and `?tbl`.
* RStudio addins to insert a chunk and to render the open document.
* `groff_available()` tells whether groff can typeset here: finding the program is not
  enough, since Debian's `groff-base` has no ms macros.
