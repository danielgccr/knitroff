// The Render command: knitroff::render_roff() on the open .Rms file, then the PDF opens.
// In Positron the R console runs it, as RStudio's Knit button would; in VS Code, Rscript.
const vscode = require('vscode');
const { execFile } = require('child_process');

function activate(context) {
  context.subscriptions.push(vscode.commands.registerCommand('knitroff.render', async () => {
    const doc = vscode.window.activeTextEditor?.document;
    if (!doc || doc.isUntitled || doc.languageId !== 'rms') {
      return vscode.window.showErrorMessage('Open a saved .Rms document first.');
    }
    await doc.save();
    // JSON's string syntax is valid R, backslashes on Windows included
    const code = `browseURL(knitroff::render_roff(${JSON.stringify(doc.uri.fsPath)}))`;
    const positron = globalThis.acquirePositronApi?.();
    if (positron) return positron.runtime.executeCode('r', code, true);
    execFile('Rscript', ['-e', code], (err, stdout, stderr) => {
      if (err) vscode.window.showErrorMessage(`knitroff: ${stderr.trim() || err.message}`);
    });
  }));
}

module.exports = { activate, deactivate() {} };
