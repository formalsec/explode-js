const esl = require("esl_symbolic");
const lib = require('kill-process-on-port');
lib.killProcessOnPort(esl.string("port"));
