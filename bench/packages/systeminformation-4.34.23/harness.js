const esl = require("esl_symbolic");
const si = require('systeminformation');

var payload = esl.string("payload");
// Assume all char
esl.assume(payload.length == 16);
si.processLoad(payload)
