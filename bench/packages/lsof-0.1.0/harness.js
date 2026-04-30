const esl = require('esl_symbolic');
const root = require("lsof");
try {
  root.rawTcpPort(esl.string('payload'), function () {});
} catch (err) {}
