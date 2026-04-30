const a = require("get-npm-package-version");
const esl = require('esl_symbolic');
try {
  a(esl.string('payload'));
} catch (err) {}
