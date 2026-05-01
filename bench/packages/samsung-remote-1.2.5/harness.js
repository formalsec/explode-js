const esl = require('esl_symbolic');
const SamsungRemote = require("samsung-remote");
try {
  var remote = new SamsungRemote({ ip: esl.string('payload') });
  remote.isAlive(function (err) {});
} catch (e) {}
