const esl = require('esl_symbolic');
const portprocesses = require("portprocesses");

try {
  portprocesses.killProcess(esl.string('payload'));
} catch (e) {}
