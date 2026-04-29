const esl = require('esl_symbolic');
const a = require("connection-tester");
a.test([esl.string('payload')], esl.number("port"), esl.number("timeout"));
