const esl = require('esl_symbolic');
const a = require("curljs");

try {
  a(esl.string('payload'), function () {});
} catch (err) {}
