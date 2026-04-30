const esl = require('esl_symbolic');
const diskstats = require("diskstats");

try {
  diskstats.check(esl.string('payload'), () => {});
} catch (err) {}
