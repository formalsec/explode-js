const esl = require('esl_symbolic');
const fix = require("eslint-fixer");
try {
  fix(esl.string('payload'));
} catch (err) {}
