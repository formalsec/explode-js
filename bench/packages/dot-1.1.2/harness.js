const doT = require("dot");
const esl_symbolic = require("esl_symbolic");

var payload = esl_symbolic.string("payload");
var tempFn = doT.template(payload);
tempFn({})
