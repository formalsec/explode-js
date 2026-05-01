const esl = require('esl_symbolic');
const ps_kill = require("ps-kill");
try {
  ps_kill.kill(esl.string('payload'), function (error) {});
} catch (e) {}
