const esl = require('esl_symbolic');
const a = require("gitblame");
try {
  a(esl.string('payload'), function () {});
} catch (err) {}
