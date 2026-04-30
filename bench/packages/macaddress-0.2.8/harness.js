const esl = require('esl_symbolic');
try {
  require("macaddress").one(esl.string('payload'), function (err, mac) {});
} catch (e) {}
