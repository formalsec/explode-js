const esl = require('esl_symbolic');
const a = require("node-latex-pdf");
try {
  a("./", esl.string('payload'), function () {});
} catch (err) {}
