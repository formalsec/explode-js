const esl = require('esl_symbolic');
const a = require("macfromip");
try {
  a.getMacInLinux(esl.string('payload'), function () {});
} catch (e) {}
