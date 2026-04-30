const esl = require('esl_symbolic');
const a = require("get-git-data");
try {
  a.log(esl.string('payload'));
} catch (err) {}
