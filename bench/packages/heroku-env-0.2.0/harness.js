const esl = require('esl_symbolic');
const root = require("heroku-env");
try {
  root(esl.string('payload'), "aa", function () {});
} catch (err) {}
