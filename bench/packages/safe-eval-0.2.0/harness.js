const safeEval = require("safe-eval");
const esl_symbolic = require("esl_symbolic");
var payload = esl_symbolic.string("payload");
safeEval(payload);
