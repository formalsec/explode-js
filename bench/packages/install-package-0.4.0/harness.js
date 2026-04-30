const esl = require('esl_symbolic');
const install = require('install-package');

try {
  install([esl.string('payload')]);
} catch (e) {}
