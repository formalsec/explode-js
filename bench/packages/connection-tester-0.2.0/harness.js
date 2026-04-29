const esl = require('esl_symbolic');
const a = require("connection-tester");
try {
  a.test([esl.string('payload')], 123, 1000);
} catch (error) {}
