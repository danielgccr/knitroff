## Resubmission

The incoming pre-tests failed on Debian: groff was found, but it was Debian's
`groff-base`, which has no ms macros, so the example and the tests that typeset failed.
They now skip unless the new `groff_available()` can typeset an empty ms document with
groff, and `render_roff()` stops with a message saying to install the full `groff`.
Checked in a Debian container (r-base image) with only `groff-base`: Status OK.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

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

* Arch Linux, R 4.6.1, groff 1.24.1
* win-builder, R-devel (2026-10-05 r90641 ucrt), Windows, without groff: 1 NOTE (new submission)
* Debian testing (Docker r-base), R release, groff-base 1.24.2 only: Status OK
