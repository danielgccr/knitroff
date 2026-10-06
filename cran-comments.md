## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Notes for the reviewers

* knitroff typesets with GNU groff, declared in SystemRequirements. `knit_roff()`, which
  writes troff, needs no external program; `render_roff()` needs groff, and stops with a
  clear message when it is missing. The example and the tests that run groff are skipped
  when `Sys.which("groff")` is empty, so the package checks cleanly without it.
* For figures in PDF, `render_roff()` runs groff with `-U` (unsafe mode), because groff's
  `.PDFPIC` macro calls `pdfinfo` to read each picture's size. This is documented in
  `?render_roff`.
* Examples and tests write only to `tempdir()`.

## Test environments

* Arch Linux, R 4.6.1, groff 1.24.1
