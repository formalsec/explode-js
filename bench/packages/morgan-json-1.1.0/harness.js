const PUT = require("morgan-json");
const esl = require("esl_symbolic");
var x = esl.string("x");
esl.assume(x != "");
new PUT(x,{})('');

