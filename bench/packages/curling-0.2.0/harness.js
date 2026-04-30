const esl = require('esl_symbolic');
const root = require("curling");
try {
  root.run(esl.string('payload'), function (err) {});
} catch (err) {}