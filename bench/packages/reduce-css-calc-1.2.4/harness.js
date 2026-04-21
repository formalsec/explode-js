const reduceCSSCalc = require("reduce-css-calc");
const esl = require("esl_symbolic");

const payload = esl.string("payload");
reduceCSSCalc(payload, 5);
