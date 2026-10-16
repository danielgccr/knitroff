## Update

knitroff 0.1.1: `render_roff()` now also runs groff's refer preprocessor (`groff -R`), so
documents can have citations and a bibliography.

## R CMD check results

0 errors | 0 warnings | 0 notes

## Notes for the reviewers

* knitroff typesets with GNU groff, declared in SystemRequirements. `knit_roff()`, which
  writes troff, needs no external program; `render_roff()` needs groff, and stops with a
  clear message when groff is missing or can't typeset. The example and the tests that run
  groff are skipped unless `groff_available()` is TRUE, so the package checks cleanly
  without groff, or with Debian's `groff-base` only.
* For figures in PDF, `render_roff()` runs groff with `-U` (unsafe mode), because groff's
  `.PDFPIC` macro calls `pdfinfo` to read each picture's size. This is documented in
  `?render_roff`.
* Examples and tests write only to `tempdir()`.

## Test environments

* Arch Linux, R 4.6.1, groff 1.24.1: 1 NOTE (days since last update)
