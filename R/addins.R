# RStudio addins, listed in inst/rstudio/addins.dcf. RStudio knows no chunk syntax for .Rms,
# so Insert Chunk and the Knit button do nothing there; these stand in for them. Bind keys in
# Tools > Modify Keyboard Shortcuts: a package can't.

insert_chunk_addin <- function() {
  ctx <- rstudioapi::getSourceEditorContext()
  range <- ctx$selection[[1]]$range
  start <- range$start[["row"]]
  end <- range$end[["row"]]
  if (end > start && range$end[["column"]] == 1) end <- end - 1  # selection ends at a line start
  lines <- c(ctx$contents, "")
  chunk <- chunk_insert(lines, start, end, selected = !identical(range$start, range$end))
  whole <- rstudioapi::document_range(c(start, 1), c(end, nchar(lines[end]) + 1))
  rstudioapi::insertText(whole, paste(chunk$text, collapse = "\n"), id = ctx$id)
  rstudioapi::setCursorPosition(rstudioapi::document_position(chunk$cursor, 1), id = ctx$id)
}

# The lines that replace lines start..end, and the row for the cursor: the selected lines
# wrapped in .SS/.SE, or an empty chunk on a blank line, or below a line with text on it.
chunk_insert <- function(lines, start, end, selected) {
  if (selected) return(list(text = c(".SS", lines[start:end], ".SE"), cursor = start + 1))
  if (!nzchar(trimws(lines[start]))) return(list(text = c(".SS", "", ".SE"), cursor = start + 1))
  list(text = c(lines[start], ".SS", "", ".SE"), cursor = start + 2)
}

render_addin <- function() {
  ctx <- rstudioapi::getSourceEditorContext()
  if (!grepl("[.]Rms$", ctx$path, ignore.case = TRUE)) stop("open a saved .Rms document first")
  rstudioapi::documentSave(ctx$id)
  output <- render_roff(ctx$path)
  message("Wrote ", output)
  utils::browseURL(output)
}
