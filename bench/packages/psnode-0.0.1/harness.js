const esl = require('esl_symbolic');
const psnode = require("psnode");
try {
  psnode.kill(esl.string('payload'), function () {});
} catch (e) {}
