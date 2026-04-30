const esl = require('esl_symbolic');
const root = require("git-add-remote")();
try {
  root(esl.string('payload'), "", function () {});
} catch (err) {}
