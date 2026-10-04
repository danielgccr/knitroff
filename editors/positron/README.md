# knitroff for Positron and VS Code

Support for [knitroff](https://github.com/danielgccr/knitroff)'s `.Rms` documents: troff
with the ms macros, and R chunks between `.SS` and `.SE`.

- **Highlighting:** requests such as `.PP` and `.NH`, escapes such as `\fB` and `\*[name]`,
  comments and eqn blocks; R chunks, `` `r expr` `` and `.SR` highlighted as R.
- **Insert a chunk:** Ctrl+Alt+I (Cmd+Option+I on a Mac) wraps the selection in `.SS`/`.SE`.
  Snippets: `ss` (chunk), `fig` (figure chunk), `sr` (`.SR`), `eq` (equation).
- **Render:** Ctrl+Shift+K (Cmd+Shift+K), or the PDF button in the editor's title bar, saves
  the document and runs `knitroff::render_roff()`, then opens the PDF. Positron runs it in
  the R console; VS Code runs `Rscript`.

These keys apply only in `.Rms` files. knitroff must be installed in R.
